+++
date = '2026-10-24T14:24:54Z'
draft = false
title = 'Experiment PPPoE ohne "FRITZ"'
+++
Der Router meines ISP ist eine FRITZ!Box. Das FRITZ!OS ist ein wenig beschränkt für mein Homelab. Daher suche ich *verkrampft* nach einem Router der PPPoE-Support (inklusive VLAN-Tagging) reibungslos mit Sachsen Gigabit ermöglichen kann.

**"An der Wand"**
... Ist ein FiberTwist-XGS2120 – ein reiner Layer-2-ONT “Medienwandler” von Glasfaser auf Ethernet, ohne eigenes Routing/PPPoE – das PPPoE-Handshake wird komplett vom Router gemacht über den 2,5G-LAN-Port (kein XPS oder GPON-Modul).

### Open source firwmare
- OpenWrt, Gargoyle, OpenWrt One
- DD-WRT
- FreshTomato

### Cloced source firmware
- GL.iNet (OpenWrt fork)
- UniFi OS
- FRITZ!OS
- Tenda (zum Beispiel )
- TP-Link (auf OpenWrt basiert?): Omada SDN (Software-Defined Networking), Standalone Mode - Web-UI direkt auf dem Router oder Controller Mode - Zentrale Steuerung über den Omada Software Controller, Hardware Controller (OC200/OC300) oder Cloud-Controller
- Zyxel
- Speedport (Telekom)

## x86 und Co
Gehe ich weg von ARM, Lantiq, MIPS oder anderen Architekturen könnte ich ein uraltes Alix 2D versuchen oder eine etwas neuere Sophos Box mit derzeit OPNsense/pfSense (könnte aber auch VyOS betreiben).

Interessant wäre das Experiment auch mit RISC-V:
- Banana Pi BPI-RV2 | SF21H8898 | RISC-V Router-Board
- SMARC, Computer-on-Module-Standard (314-Pin)