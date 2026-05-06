{ config, pkgs, ... }:

let
  # DEFINITIONEN VOR DEM CONFIG-BLOCK
  nix-search-script = pkgs.writeShellApplication {
    name = "ns";
    runtimeInputs = with pkgs; [
      fzf
      nix-search-tv
    ];
    text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
  };

  # VESKTOP MIT FLAGS - ALS WRAPPER SKRIPT (OHNE eigenes bin/vesktop)
  vesktop-fixed = pkgs.writeShellScriptBin "vesktop-fixed" ''
    # Prüfe ob Flags schon gesetzt sind (um Dopplung zu vermeiden)
    if [[ "$*" != *"--disable-gpu"* ]]; then
      exec ${pkgs.vesktop}/bin/vesktop \
        --disable-gpu \
        --disable-accelerated-2d-canvas \
        --disable-gpu-compositing \
        --disable-gpu-rasterization \
        --ozone-platform-hint=wayland \
        "$@"
    else
      exec ${pkgs.vesktop}/bin/vesktop "$@"
    fi
  '';

  # CUSTOM DESKTOP ENTRY FÜR VESKTOP
  vesktop-desktop = pkgs.makeDesktopItem {
    name = "vesktop-fixed";
    desktopName = "Vesktop";
    exec = "vesktop-fixed %U";
    icon = "vesktop";
    categories = [
      "Network"
      "InstantMessaging"
    ];
    mimeTypes = [ "x-scheme-handler/discord" ];
    startupWMClass = "Vesktop";
  };
in

{
  home.username = "jona";
  home.homeDirectory = "/home/jona";
  home.stateVersion = "24.11";

  # PAKETE
  home.packages = with pkgs; [
    zoxide
    nix-search-tv # Basis-Paket
    fzf # Für Fuzzy-Finding
    nix-search-script # Dein ns-Befehl
    pkgs.vesktop # Das originale Vesktop (wird vom Skript benötigt)
    vesktop-fixed # Dein gefixtes Vesktop-Skript (heißt jetzt vesktop-fixed)
    vesktop-desktop # Custom Desktop Entry
  ];

  # ZUSÄTZLICH: Electron Flags als Environment Variables
  home.sessionVariables = {
    ELECTRON_USE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    NIXOS_OZONE_WL = "1";
  };

  home.sessionPath = [ "$HOME/.local/bin" ];

  # GTK & Icons
  gtk = {
    enable = true;
    theme = {
      name = "Gruvbox-Dark";
      package = pkgs.gruvbox-gtk-theme;
    };
    iconTheme = {
      name = "Gruvbox-Plus-Dark";
      package = pkgs.gruvbox-plus-icons;
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
    };
  };

  # Unerwünschte Desktop-Einträge ausblenden
  xdg.desktopEntries = {
    # Original Vesktop ausblenden
    "vesktop" = {
      name = "Vesktop";
      exec = "vesktop";
      noDisplay = true;
    };

    # XTerm
    "xterm" = {
      name = "XTerm";
      exec = "kitty";
      noDisplay = true;
      terminal = false;
    };

    # Color Profile Viewer
    "org.gnome.ColorProfileViewer" = {
      name = "Color Profile Viewer";
      exec = "org.gnome.ColorProfileViewer";
      noDisplay = true;
    };

    # IBus Einträge
    "org.freedesktop.IBus.Setup" = {
      name = "IBus Setup";
      exec = "ibus-setup";
      noDisplay = true;
    };
    "org.freedesktop.IBus.Panel.Emojier" = {
      name = "IBus Emojier";
      exec = "ibus-setup";
      noDisplay = true;
    };
    "org.freedesktop.IBus.Panel.Extension.Gtk3" = {
      name = "IBus Extension";
      exec = "ibus-setup";
      noDisplay = true;
    };
    "org.freedesktop.IBus.Panel.Wayland.Gtk3" = {
      name = "IBus Wayland";
      exec = "ibus-setup";
      noDisplay = true;
    };

    # Rygel
    "rygel" = {
      name = "Rygel";
      exec = "rygel";
      noDisplay = true;
    };
    "rygel-preferences" = {
      name = "Rygel Preferences";
      exec = "rygel-preferences";
      noDisplay = true;
    };

    # Rofi
    "rofi" = {
      name = "Rofi";
      exec = "rofi";
      noDisplay = true;
    };
    "rofi-theme-selector" = {
      name = "Rofi Theme Selector";
      exec = "rofi-theme-selector";
      noDisplay = true;
    };

    # NVIDIA
    "nvidia-settings" = {
      name = "NVIDIA Settings";
      exec = "nvidia-settings";
      noDisplay = true;
    };

    # GNOME Color Manager
    "gcm-calibrate" = {
      name = "Color Calibrate";
      exec = "gcm-calibrate";
      noDisplay = true;
    };
    "gcm-import" = {
      name = "Color Import";
      exec = "gcm-import";
      noDisplay = true;
    };
    "gcm-picker" = {
      name = "Color Picker";
      exec = "gcm-picker";
      noDisplay = true;
    };
    "gnome-color-panel" = {
      name = "Color Panel";
      exec = "gnome-color-panel";
      noDisplay = true;
    };
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      # Wichtig: --cmd cd direkt beim init übergeben
      eval "$(zoxide init bash --cmd cd)"

      # Alias für einfacheren Zugriff
      alias discord='vesktop-fixed'
    '';
  };

  home.activation.hideAllUnwanted =
    let
      desktopUtils = "${pkgs.desktop-file-utils}/bin";
    in
    ''
      echo "Stelle Verzeichnisberechtigungen sicher..."

      if [ ! -w "/home/jona/.local/share/applications" ]; then
        echo "WARNUNG: /home/jona/.local/share/applications ist nicht beschreibbar!"
        echo "Bitte führe manuell aus:"
        echo "  mkdir -p /home/jona/.local/share/applications"
        exit 1
      fi

      echo "Verstecke unerwünschte Desktop-Einträge mit exakten Namen..."

      # Liste ALLER unerwünschter Desktop-Dateien
      unwanted=(
        "xterm"
        "org.gnome.ColorProfileViewer"
        "org.freedesktop.IBus.Setup"
        "org.freedesktop.IBus.Panel.Emojier"
        "org.freedesktop.IBus.Panel.Extension.Gtk3"
        "org.freedesktop.IBus.Panel.Wayland.Gtk3"
        "rygel"
        "rygel-preferences"
        "rofi"
        "rofi-theme-selector"
        "nvidia-settings"
        "gcm-calibrate"
        "gcm-import"
        "gcm-picker"
        "gnome-color-panel"
      )

      for app in "''${unwanted[@]}"; do
        if [ -f "/run/current-system/sw/share/applications/$app.desktop" ]; then
          echo "  Verstecke: $app.desktop"
          install -m 644 "/run/current-system/sw/share/applications/$app.desktop" "/home/jona/.local/share/applications/$app.desktop"
          echo "NoDisplay=true" >> "/home/jona/.local/share/applications/$app.desktop"
          echo "Hidden=true" >> "/home/jona/.local/share/applications/$app.desktop"
        fi
      done

      # Zusätzlich: Original Vesktop verstecken falls vorhanden
      if [ -f "${pkgs.vesktop}/share/applications/vesktop.desktop" ]; then
        echo "  Verstecke: original Vesktop"
        install -m 644 "${pkgs.vesktop}/share/applications/vesktop.desktop" "/home/jona/.local/share/applications/vesktop.desktop"
        echo "NoDisplay=true" >> "/home/jona/.local/share/applications/vesktop.desktop"
        echo "Hidden=true" >> "/home/jona/.local/share/applications/vesktop.desktop"
      fi

      ${desktopUtils}/update-desktop-database /home/jona/.local/share/applications || true

      echo "Fertig! Alle unerwünschten Einträge sollten jetzt verschwunden sein."
    '';

  # Dotfiles Verknüpfungen
  home.file = {
    ".config/hypr" = {
      source = ./config/hypr;
      recursive = true;
      force = true;
    };
    ".config/waybar" = {
      source = ./config/waybar;
      recursive = true;
      force = true;
    };
    ".config/ghostty" = {
      source = ./config/ghostty;
      recursive = true;
      force = true;
    };
    ".config/rofi" = {
      source = ./config/rofi;
      recursive = true;
      force = true;
    };
    ".config/kitty" = {
      source = ./config/kitty;
      recursive = true;
      force = true;
    };
    ".config/zathura" = {
      source = ./config/zathura;
      recursive = true;
      force = true;
    };
    ".config/btop" = {
      source = ./config/btop;
      recursive = true;
      force = true;
    };
    ".config/mango" = {
      source = ./config/mango;
      recursive = true;
      force = true;
    };
  };

  programs.home-manager.enable = true;

}
