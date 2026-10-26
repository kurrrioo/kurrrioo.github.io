+++
date = '2026-10-26T20:35:40Z'
draft = false
title = 'GitHub Actions für Einsteiger'
+++

## Wie ich mir einen arm64-Build bauen ließ, ohne einen Compiler anzufassen

*Ein Praxisbericht, Oktober 2026*

Mein Khadas VIM2 mit LibreELEC ist ein tolles kleines Gerät, hat aber ein Problem: Es gibt keinen Paketmanager. Wollte ich dort Transmission als Download-Client haben, musste ich das Programm selbst für arm64 bauen, und das auf einem Intel-Mac mit Catalina, auf dem Docker und ARM-Emulation keine Freude machen. Die Lösung hieß GitHub Actions. Ich kannte die Funktion vorher nicht. Dieser Beitrag erklärt, was dahintersteckt, und zeigt es an einem echten Beispiel.

## Was ist GitHub Actions?

Kurz gesagt: GitHub leiht dir für ein paar Minuten einen Rechner und führt dort Befehle aus, die du in einer Textdatei beschrieben hast. Du musst nichts installieren, und dein eigener Rechner bleibt unberührt.

Diese Textdatei heißt *Workflow*, liegt im Repository unter `.github/workflows/` und ist in YAML geschrieben. Ein paar Begriffe genügen fürs Verständnis:

| Begriff | Bedeutung | In meinem Beispiel |
|---|---|---|
| Workflow | Das Rezept, eine YAML-Datei | `build.yml` |
| Trigger | Was das Rezept auslöst | Knopfdruck und Push |
| Job | Eine Gruppe von Schritten auf einem Rechner | `build` |
| Runner | Der Rechner, den GitHub bereitstellt | `ubuntu-24.04-arm` |
| Step | Ein einzelner Schritt im Job | Container starten, Archiv hochladen |
| Lauf (Run) | Eine einzelne Ausführung des Rezepts | der Eintrag mit dem grünen Häkchen |
| Artifact | Eine Datei, die ein Lauf hinterlässt | `transmission-aarch64.tar.gz` |

**Merksatz:** Der Workflow ist das Rezept, der Lauf ist ein Mal kochen, das Artifact ist das Gericht.

## Der Workflow in 20 Zeilen

```yaml
name: transmission-aarch64-bundle

on:
  workflow_dispatch:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-24.04-arm
    steps:
      - uses: actions/checkout@v4

      - name: Bundle in Alpine-Container bauen
        run: |
          mkdir -p out
          docker run --rm \
            -v "$PWD/out:/out" \
            -v "$PWD/build.sh:/build.sh:ro" \
            alpine:3 sh /build.sh
          tar czf transmission-aarch64.tar.gz -C out bundle

      - uses: actions/upload-artifact@v4
        with:
          name: transmission-aarch64
          path: transmission-aarch64.tar.gz
```

Zeile für Zeile:

- `on` legt die Auslöser fest. `workflow_dispatch` schaltet einen Knopf in der Oberfläche frei, `push` startet den Workflow bei jedem Push auf `main`.
- `runs-on` wählt den Rechner. Hier ist es ein echter ARM-Rechner, deshalb braucht man keine Emulation und keinen Cross-Compiler.
- `actions/checkout` holt den Code des Repositories auf den Runner.
- Der `run`-Schritt startet einen Alpine-Linux-Container und führt darin mein Skript `build.sh` aus. Es installiert Transmission, sammelt die Programme samt aller Bibliotheken ein und packt sie in ein Bundle.
- `actions/upload-artifact` legt das Ergebnis zum Download bereit.

## Der Ablauf in fünf Schritten

1. Ein öffentliches Repository auf GitHub anlegen.
2. `build.sh` und `.github/workflows/build.yml` hineinpushen.
3. Im Tab **Actions** den Workflow starten, oder einfach pushen, wenn der `push`-Trigger gesetzt ist.
4. Nach ein bis zwei Minuten erscheint ein Lauf mit grünem Häkchen. Anklicken und ganz unten unter **Artifacts** herunterladen.
5. Per `scp` auf das Zielgerät kopieren und entpacken.

## Stolpersteine aus erster Hand

Diese Dinge haben mich Zeit gekostet. Vielleicht sparst du sie dir.

**1. `git commit -am` reicht für neue Dateien nicht.** Die Option `-a` nimmt nur Dateien mit, die Git schon kennt. Neue Dateien müssen erst mit `git add` hinzugefügt werden. Sonst gibt es keinen Commit und auch keinen Branch, den man pushen könnte.

**2. Das GitHub-Passwort funktioniert beim Push nicht mehr.** Git verlangt ein *Personal Access Token*. Wer eine Workflow-Datei pushen will, braucht dafür neben `repo` auch die Berechtigung `workflow`. Eine kurze Laufzeit von ein paar Tagen reicht.

**3. Der Tab Actions bleibt leer.** Ein Workflow mit nur `workflow_dispatch` muss auf dem Standard-Branch liegen, bevor der Knopf erscheint. Bei mir half ein zusätzlicher `push`-Trigger: Der nächste Push hat den Lauf sofort gestartet.

**4. Die Node.js-Warnung ist harmlos.** Nach dem ersten Lauf stand dort eine Annotation zu Node.js 20. Sie betrifft nur GitHubs eigene Bausteine und nicht den eigenen Code.

**5. „Lauf“ ist einfach eine Ausführung.** Ich musste selbst nachfragen, was damit gemeint ist. Jeder Eintrag in der Liste unter Actions ist ein Lauf. Das Ergebnis hängt immer am Lauf, nicht am Workflow.

## Warum nicht lokal bauen?

Mein Ziel war ein Programm für eine ARM-Architektur, mein Rechner ist ein Intel-Mac. Lokal hätte ich einen Cross-Compiler oder einen emulierten ARM-Container gebraucht, beides langsam und fehleranfällig. Ein Runner mit echtem ARM-Prozessor erspart das. Der Nebeneffekt: Der Build ist reproduzierbar. Wer das Repository klont, bekommt dasselbe Ergebnis.

## Was Actions noch kann

Das Beispiel kratzt nur an der Oberfläche. Typische Einsatzzwecke:

- Tests automatisch bei jedem Pull Request laufen lassen
- Releases erzeugen und Dateien daran anhängen
- Zeitgesteuerte Aufgaben mit `schedule` (Cron-Syntax), etwa nächtliche Backups oder Datenabrufe
- Dasselbe Programm für mehrere Betriebssysteme und Versionen bauen (Matrix-Builds)
- Webseiten automatisch veröffentlichen

## Sicherheit und Kosten

- **Öffentlich heißt öffentlich.** In einem öffentlichen Repository sind Code und Logs für alle sichtbar. Passwörter und Schlüssel gehören nie in die Dateien, sondern in die *Secrets* des Repositories.
- **Drittanbieter-Bausteine prüfen.** Jede `uses:`-Zeile führt fremden Code aus. In den Einstellungen unter *Actions → General* gibt es die Option, nur Bausteine mit festem Commit-Hash zuzulassen. Das ist die strengste Variante.
- **Tokens kurz halten.** Ein Token mit kurzer Laufzeit und nur den nötigen Rechten begrenzt den Schaden, falls er verloren geht.
- **Kontingente beachten.** Für öffentliche Repositories sind Actions in der Regel kostenlos, für private gelten Minutenkontingente. Die aktuellen Grenzen stehen in der GitHub-Dokumentation. Das gilt auch für die ARM-Runner, deren Verfügbarkeit sich ändern kann.

## Fazit

GitHub Actions ist im Kern eine einfache Idee: eine Textdatei, die beschreibt, was GitHub für dich ausführen soll. Für mich war es die Abkürzung zu einem Programm, das ich lokal nur mühsam hätte bauen können. Wer einen kleinen Rechner wie den VIM2 betreibt, auf dem es keinen Paketmanager gibt, bekommt damit ein Werkzeug, das auch bei anderen Projekten weiterhilft. Der erste Lauf mit grünem Häkchen ist übrigens ein ziemlich gutes Gefühl.
