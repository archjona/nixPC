{ config, pkgs, ... }:

{
  home.username = "jona";
  home.homeDirectory = "/home/jona";
  home.stateVersion = "24.11";

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

  # Dotfiles Verknüpfungen
  home.file = {
    ".config/hypr" = { source = ./config/hypr; recursive = true; force = true; };
    ".config/waybar" = { source = ./config/waybar; recursive = true; force = true; };
    ".config/ghostty" = { source = ./config/ghostty; recursive = true; force = true; };
    ".config/rofi" = { source = ./config/rofi; recursive = true; force = true; };
    ".config/kitty" = { source = ./config/kitty; recursive = true; force = true; };
    ".config/zathura" = { source = ./config/zathura; recursive = true; force = true; };
    ".config/btop" = { source = ./config/btop; recursive = true; force = true; };
  };

  programs.home-manager.enable = true;
}
