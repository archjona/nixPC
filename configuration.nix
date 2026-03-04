{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [ 
      /etc/nixos/hardware-configuration.nix # Nutzt die Datei im selben Ordner
      ./nvf-configuration.nix      # Bindet deine Neovim-Config ein
    ];


        environment.sessionVariables = {
  NIXOS_OZONE_WL = "1";
};

 boot.loader.grub.device = "/dev/nvme0n1";
boot.loader.grub.enable = true;
boot.loader.grub.useOSProber = true;

hardware.graphics = {
  enable = true;
  enable32Bit = true;
};

  networking.hostName = "nixos";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Netzwerkkonfiguration
  networking.networkmanager.enable = true;

  # Zeitkonfiguration
  time.timeZone = "Europe/Berlin";

services.xserver = {
  enable = true;
  displayManager.sessionCommands = ''
    export XCURSOR_THEME=Adwaita
    export XCURSOR_SIZE=24
  '';
};

  # Internationalisierung
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

  # X11- und Desktopumgebung (GNOME als Fallback)
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Virtualisierung
  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;

  # Benutzer hinzufügen
  users.users.jona = {
    isNormalUser = true;
    description = "Jona-Elia";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  # Home-Manager Konfiguration
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "jona" = import ./home.nix;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  # NVF Aktivierung (Wichtig für deine nvf-configuration.nix)
  programs.nvf = {
    enable = true;
    defaultEditor = true;
  };

  # Audio mit Pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  console.keyMap = "de";
  services.printing.enable = true;

  # Programme installieren
  environment.systemPackages = with pkgs; [
    wget
    git
    hyprpaper
    waybar
    kitty
    foot
    ghostty
    # neovim wurde hier entfernt, da nvf nvim bereitstellt!
    swww
    pywal
    gcc
    cmake
    clang
    python3
    nerd-fonts.jetbrains-mono
    tmux
    lazygit
    hyprshot
    hyprlock
    hypridle
    alsa-utils
    rofi
    btop
    librewolf
    steam
    spotify
    discord
    flatpak
    zoxide
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
  ];

  nixpkgs.config.allowUnfree = true;

  # Hyprland-Konfiguration
  programs.hyprland.enable = true;
  programs.hyprland.package = inputs.hyprland.packages."${pkgs.system}".hyprland;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  system.stateVersion = "24.11"; # Stabilere Version für Config-Pfade
}
