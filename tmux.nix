{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    clock24 = true;
    shortcut = "space"; 
    
    # Hier nur die Pakete auflisten, keine Sets mit 'plugin ='
    plugins = with pkgs.tmuxPlugins; [
      gruvbox
    ];

    extraConfig = ''
      # Plugin-Konfiguration direkt hier rein
      set -g @tmux-gruvbox 'dark'

      # Restliche Einstellungen
      set -g base-index 1
      setw -g pane-base-index 1
      set -g renumber-windows on
      set -g mouse on

      # Farben für NVF/Neovim
      set -g default-terminal "screen-256color"
      set -as terminal-features ",xterm-256color:RGB"

      # Shortcuts für Windows
      bind 1 select-window -t 1
      bind 2 select-window -t 2
      bind 3 select-window -t 3
      bind 4 select-window -t 4
      bind 5 select-window -t 5
    '';
  };
}
