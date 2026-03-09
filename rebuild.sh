#!/usr/bin/env bash

# NixOS Update Script
# Automatisiert nixos-rebuild mit Flake-Unterstützung

# Farben für bessere Lesbarkeit
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fehlermodus aktivieren
set -e

# Funktion für Logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Prüfe ob wir im richtigen Verzeichnis sind
if [[ ! -f "flake.nix" ]] && [[ ! -f "flake.lock" ]]; then
    log_error "Keine flake.nix oder flake.lock im aktuellen Verzeichnis gefunden!"
    log_info "Bitte führe das Skript aus dem Verzeichnis mit deiner Flake-Konfiguration aus."
    exit 1
fi

# Zeige aktuelles Verzeichnis
log_info "Führe Update aus in: $(pwd)"

# Frage nach Bestätigung
echo ""
read -p "$(echo -e ${YELLOW}Möchtest du fortfahren? [y/N]${NC}) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Update abgebrochen."
    exit 0
fi

log_info "Starte nixos-rebuild mit Flake..."

# Zeitmessung starten
start_time=$(date +%s)

# Führe den eigentlichen Befehl aus
if sudo nixos-rebuild switch --flake . --impure; then
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    log_success "System erfolgreich aktualisiert!"
    log_info "Benötigte Zeit: ${duration} Sekunden"
    
    # Zeige Generationen-Information
    echo ""
    log_info "Aktuelle Generation:"
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -n 1
else
    log_error "Update fehlgeschlagen!"
    exit 1
fi
