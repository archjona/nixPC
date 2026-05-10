{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./nvf-configuration.nix
    ./qt-dev.nix
  ];

  # --- NVIDIA & Grafik Konfiguration ---
  nixpkgs.config.allowUnfree = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Wichtig für Steam!
  };

  # Lade den NVIDIA Treiber
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    # Power Management kann bei Hyprland manchmal Flackern verursachen,
    # daher auf 'false' oder experimentell testen.
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # Für die 3060 Ti ist 'false' (proprietär) aktuell stabiler für Gaming.
    open = false;

    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.ivpn.enable = true;
  # Kernel-Parameter für Wayland & NVIDIA
  boot.kernelParams = [
    "nvidia_drm.modeset=1"
    "nvidia_drm.fbdev=1"
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Erzwingt Wayland für Electron Apps
    WLR_NO_HARDWARE_CURSORS = "1"; # Behebt unsichtbaren Cursor bei NVIDIA
    LIBVA_DRIVER_NAME = "nvidia"; # Hardware-Beschleunigung
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    PATH = [ "$HOME/.local/bin" ];
  };

  # --- Steam & Gaming ---
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true; # Optional: Für bessere Upscaling-Optionen
  };

  programs.gamemode.enable = true; # Optimiert CPU/Prioritäten beim Zocken

  # --- Bootloader ---
  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
    useOSProber = true;

    # Das Gruvbox-Theme mit dem goldenen NixOS-Logo
    theme =
      pkgs.fetchFromGitHub {
        owner = "Atif-Mahmud";
        repo = "nix-gruv-grub";
        rev = "269507de98ecd4fd9c57aa06bf5d8132d6949a06";
        sha256 = "sha256-UEPZxyT09Z0PiOka/Dh4m8VvqF4l+01eZVbRkPJduDk=";
      }
      + "/tartarus";
  };
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  # --- System-Einstellungen ---
  networking.hostName = "nixos";
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "jona"
    ];
  };
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Berlin";

  services.xserver = {
    enable = true;
    displayManager.sessionCommands = ''
      export XCURSOR_THEME=Adwaita
      export XCURSOR_SIZE=24
    '';
  };

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.tailscale.enable = true;
  # KEINE GNOME-Apps installieren!
  services.gnome.core-apps.enable = false; # Keine Basis-Apps
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;

  environment.gnome.excludePackages = with pkgs; [
    # Terminals
    xterm
    gnome-terminal
    gnome-console

    # GNOME Apps (ALLE direkt, ohne "gnome." Prefix)
    epiphany # Web Browser
    geary # Email Client
    gnome-software # Software Center
    gnome-tour
    gnome-connections
    gnome-contacts
    gnome-characters
    gnome-font-viewer
    simple-scan
    evince # Document Viewer
    gnome-calculator
    gnome-calendar
    gnome-clocks
    cheese # Camera
    baobab # Disks Usage Analyzer
    gnome-disk-utility
    seahorse
    eog # Image Viewer
    totem # Videos
  ];

  # Printing deaktivieren (wenn nicht benötigt)
  services.printing.enable = false;

  # Optional: Kitty als Standard-Terminal setzen
  environment.variables = {
    TERMINAL = "kitty";
  };

  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Virtualisierung
  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;

  # Benutzer
  users.users.jona = {
    isNormalUser = true;
    description = "Jona-Elia";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "dialout"
      "tty"
    ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "jona" = import ./home.nix;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
  };

  programs.nvf = {
    enable = true;
    defaultEditor = true;
  };

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  console.keyMap = "de";

  fonts.packages = with pkgs; [
    nerd-fonts.geist-mono
  ];

  # System Pakete
  environment.systemPackages = with pkgs; [
    wget
    git
    hyprpaper
    waybar
    kitty
    swww
    pywal
    gcc
    cmake
    clang
    python3
    tmux
    lazygit
    hyprshot
    hyprlock
    hypridle
    alsa-utils
    rofi
    btop
    spotify
    flatpak
    dolphin-emu
    fzf
    zathura
    texlivePackages.latexmk
    texliveFull
    docker
    lazydocker
    distrobox
    fastfetch
    adwaita-icon-theme
    pavucontrol
    nautilus
    loupe
    obs-studio
    celluloid
    nix-search-tv
    wl-clipboard
    ripgrep
    fd
    vesktop
    shotcut
    ivpn
    ivpn-service
    ivpn-ui
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    zed-editor
    nextcloud-client
    foot
    cmake
    ninja # schneller als make
    gcc # oder clang
    clang-tools # liefert clangd + clang-format
    qt6.qtbase
    qt6.qttools # Qt Designer, lupdate, lrelease
    qt6.qmake
    qtcreator # nur für den UI-Designer (.ui Files)
    pkg-config
    vscode-extensions.vadimcn.vscode-lldb
    lldb
    thunderbird
    protontricks
  ];

  # Hyprland
  programs.hyprland.enable = true;
  programs.hyprland.package = inputs.hyprland.packages."${pkgs.system}".hyprland;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  #mango
  programs.mango.enable = true;
  networking.firewall.checkReversePath = "loose";
  system.stateVersion = "24.11";
}
