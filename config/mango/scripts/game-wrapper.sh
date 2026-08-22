#!/usr/bin/env bash
set -e

# Skalierung auf 1.0 setzen
wlr-randr --output DP-2 --scale 1

# Kurze Pause, damit Wayland/XWayland den Change verarbeitet
sleep 1

# Spiel starten
"$@"

# Skalierung zurücksetzen
wlr-randr --output DP-2 --scale 1.3
