{ pkgs, flakePath, ... }:

{
  environment.systemPackages = [
    # Skript zum Erstellen neuer Qt-Projekte
    (pkgs.writeShellScriptBin "qt-new" (builtins.readFile ./qt-new.sh))

    # Wrapper, damit du nicht den vollen Flake-Pfad eintippen musst
    (pkgs.writeShellScriptBin "qt-dev" ''
      exec ${pkgs.nix}/bin/nix develop ${flakePath}#qt "$@"
    '')
  ];
}
