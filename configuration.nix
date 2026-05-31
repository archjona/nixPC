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

  # ===========================================================================
  # >>> GRAFIKKARTE: NVIDIA RTX 3060 Ti <<<
  # Dieser gesamte Block ist NVIDIA-spezifisch und muss bei einem
  # GPU-Wechsel ersetzt werden. Siehe AMD-Block weiter unten.
  # ===========================================================================

  # Proprietäre NVIDIA-Treiber erfordern unfree packages.
  # Bei AMD nicht nötig (amdgpu ist vollständig open-source).
  nixpkgs.config.allowUnfree = true;

  # Lädt den proprietären NVIDIA-Kernel-Treiber.
  # AMD-Alternative: [ "amdgpu" ] — kein weiterer hardware.nvidia-Block nötig.
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    # Power Management kann bei Hyprland/Wayland Flackern verursachen.
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    # 'false' = proprietärer Treiber. Für die 3060 Ti stabiler als open= true.
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Kernel-Parameter für NVIDIA DRM/KMS unter Wayland.
  # AMD benötigt das nicht — amdgpu aktiviert KMS automatisch.
  boot.kernelParams = [
    "nvidia_drm.modeset=1"
    "nvidia_drm.fbdev=1"
  ];

  # NVIDIA-spezifische Wayland/Vulkan-Umgebungsvariablen.
  # Bei AMD müssen diese Zeilen entfernt oder durch AMD-Varianten ersetzt werden
  # (siehe AMD-Block weiter unten).
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Erzwingt Wayland für Electron Apps (GPU-unabhängig, behalten)
    WLR_NO_HARDWARE_CURSORS = "1"; # NVIDIA: Behebt unsichtbaren Cursor — bei AMD entfernen
    LIBVA_DRIVER_NAME = "nvidia"; # NVIDIA VA-API — bei AMD: "radeonsi" oder weglassen
    GBM_BACKEND = "nvidia-drm"; # NVIDIA GBM — bei AMD entfernen
    __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # NVIDIA GLX — bei AMD entfernen
    PATH = [ "$HOME/.local/bin" ]; # GPU-unabhängig, behalten
  };

  # ===========================================================================
  # >>> ENDE: NVIDIA-BLOCK <<<
  # ===========================================================================

  # ///////////////////////////////////////////////////////////////////////////
  # >>> [AUSKOMMENTIERT] AMD RX 9070 XT — Als Ersatz für den NVIDIA-Block <<<
  # ///////////////////////////////////////////////////////////////////////////
  # Wenn du auf die RX 9070 XT wechselst:
  #   1. Den gesamten NVIDIA-Block oben LÖSCHEN (nixpkgs.allowUnfree darf bleiben
  #      falls andere unfree-Pakete vorhanden sind).
  #   2. Diesen Block einkommentieren.
  #
  # nixpkgs.config.allowUnfree = true; # Nur nötig für andere unfree-Pakete (Steam etc.)
  #
  # # amdgpu ist im Kernel integriert — kein proprietärer Treiber nötig.
  # services.xserver.videoDrivers = [ "amdgpu" ];
  #
  # # RX 9070 XT (RDNA 4) — benötigt Linux 6.14+ und Mesa 25.0+ für vollen Support.
  # # NixOS 25.05 / unstable bringen beides mit.
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  #
  # hardware.amdgpu = {
  #   initrd.enable = true;     # früher KMS-Start, verhindert Flackern beim Booten
  #   opencl.enable = true;     # ROCm/OpenCL für GPU-Compute (optional)
  #   amdvlk = {
  #     enable = true;          # AMDs eigener Vulkan-Treiber (Alternative zu RADV/Mesa)
  #     support32Bit.enable = true; # 32-Bit Vulkan für Steam/Proton
  #   };
  # };
  #
  # # Für maximale Gaming-Performance: RADV (Mesa) bevorzugen, nicht amdvlk.
  # # RADV ist für die meisten Spiele schneller und besser gepflegt.
  # # Du kannst beide installieren und per Env-Variable zwischen ihnen wählen:
  # #   AMD_VULKAN_ICD=RADV   → Mesa RADV  (empfohlen für Gaming)
  # #   AMD_VULKAN_ICD=AMDVLK → AMDs Treiber
  #
  # # Kernel-Parameter für RDNA 4 Performance & Features.
  # boot.kernelParams = [
  #   "amdgpu.ppfeaturemask=0xffffffff" # Entsperrt alle PowerPlay-Features (OC/Lüfterkurven)
  #   "amdgpu.dcdebugmask=0x10"         # Verbessert Wayland/Display-Stabilität
  # ];
  #
  # # AMD-Umgebungsvariablen für Wayland & Vulkan.
  # environment.sessionVariables = {
  #   NIXOS_OZONE_WL       = "1";       # Wayland für Electron Apps
  #   # WLR_NO_HARDWARE_CURSORS NICHT setzen — bei AMD nicht nötig
  #   LIBVA_DRIVER_NAME    = "radeonsi"; # VA-API Hardware-Dekodierung via Mesa
  #   VDPAU_DRIVER         = "radeonsi"; # VDPAU (Fallback-Dekodierung)
  #   # GBM_BACKEND und __GLX_VENDOR_LIBRARY_NAME NICHT setzen — amdgpu braucht das nicht
  #   AMD_VULKAN_ICD       = "RADV";    # RADV als Standard-Vulkan-Treiber erzwingen
  #   PATH = [ "$HOME/.local/bin" ];
  # };
  # ///////////////////////////////////////////////////////////////////////////
  # >>> ENDE: AMD-Block <<<
  # ///////////////////////////////////////////////////////////////////////////

  # ===========================================================================
  # Grafik-Grundkonfiguration (GPU-unabhängig — für NVIDIA und AMD gleich)
  # ===========================================================================

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Wichtig für Steam/Proton!
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      zstd
      stdenv.cc.cc.lib
      zlib
    ];
  };

  # ===========================================================================
  # Steam & Gaming
  # ===========================================================================

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  programs.gamemode.enable = true;

  # ===========================================================================
  # Bootloader
  # ===========================================================================

  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
    useOSProber = true;
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

  # ===========================================================================
  # System-Einstellungen
  # ===========================================================================

  networking.hostName = "nixos";
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.networkmanager.enable = true;
  networking.firewall.checkReversePath = "loose";

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

  time.timeZone = "Europe/Berlin";

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

  # ===========================================================================
  # Display Manager & Desktop
  # ===========================================================================

  services.xserver = {
    enable = true;
    displayManager.sessionCommands = ''
      export XCURSOR_THEME=Adwaita
      export XCURSOR_SIZE=24
    '';
    xkb = {
      layout = "de";
      variant = "";
    };
  };

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.gnome.core-apps.enable = false;
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;

  environment.gnome.excludePackages = with pkgs; [
    xterm
    gnome-terminal
    gnome-console
    epiphany
    geary
    gnome-software
    gnome-tour
    gnome-connections
    gnome-contacts
    gnome-characters
    gnome-font-viewer
    simple-scan
    evince
    gnome-calculator
    gnome-calendar
    gnome-clocks
    cheese
    baobab
    gnome-disk-utility
    seahorse
    eog
    totem
  ];

  # ===========================================================================
  # Dienste
  # ===========================================================================

  services.tailscale.enable = true;
  services.ivpn.enable = true;
  services.flatpak.enable = true;
  services.printing.enable = false;

  # ===========================================================================
  # Audio
  # ===========================================================================

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ===========================================================================
  # Virtualisierung
  # ===========================================================================

  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;

  # ===========================================================================
  # Benutzer
  # ===========================================================================

  console.keyMap = "de";

  environment.variables = {
    TERMINAL = "kitty";
  };

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
    users."jona" = import ./home.nix;
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
  };

  # ===========================================================================
  # Programme & Pakete
  # ===========================================================================

  programs.nvf = {
    enable = true;
    defaultEditor = true;
  };

  programs.mango.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.geist-mono
  ];

  environment.systemPackages = with pkgs; [
    wget
    git
    kitty
    gcc
    cmake
    clang
    python3
    tmux
    lazygit
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
    cmake
    ninja
    gcc
    clang-tools
    qt6.qtbase
    qt6.qttools
    qt6.qmake
    qtcreator
    pkg-config
    vscode-extensions.vadimcn.vscode-lldb
    lldb
    thunderbird
    protontricks
    freetype
    appimage-run
    grim
    slurp
    wl-clipboard
    satty
    yazi
    playerctl
    quickshell
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    libreoffice
    wlr-randr
  ];

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  system.stateVersion = "24.11";
}
