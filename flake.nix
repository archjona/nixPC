{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    nvf.url = "github:notashelf/nvf";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nvf, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # --- DEIN SYSTEM ---
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.hostPlatform = system; }
          ./configuration.nix
          ./tmux.nix
          home-manager.nixosModules.default
          nvf.nixosModules.default
          
          # Ermöglicht das Ausführen von Binaries aus der "Außenwelt"
          {
            programs.nix-ld.enable = true;
            programs.nix-ld.libraries = with pkgs; [
              stdenv.cc.cc
              zlib
              libusb1
              libgcrypt
              ncurses
              expat
            ];
          }
        ];
      };

      # --- ENTWICKLUNGS-UMGEBUNGEN (SHELLS) ---
      devShells.${system} = {
        # ESP-IDF Shell: Aufruf mit 'nix develop' oder 'nix develop .#esp'
        esp = pkgs.mkShell {
          name = "esp-idf-env";
          buildInputs = with pkgs; [
            cmake
            ninja
            python3
            git
            wget
            flex
            bison
            gperf
            pkg-config
            libusb1
          ];

          shellHook = ''
            # Dynamic Linker Pfad setzen, damit xtensa-tools starten können
            export NIX_LD=$(nix eval --raw nixpkgs#stdenv.cc.bintools.dynamicLinker)
            export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc pkgs.zlib pkgs.libusb1 ]}"
            
            echo "--- ESP-IDF Umgebung bereit ---"
            echo "1. ./install.sh (nur beim ersten Mal)"
            echo "2. . ./export.sh"
          '';
        };

        /* # Beispiel für weitere Shells:
        web = pkgs.mkShell {
          name = "web-dev";
          buildInputs = with pkgs; [ nodejs yarn ];
          shellHook = "echo 'Web-Development aktiv!'";
        };
        */

        # Setzt die ESP-Shell als Standard, wenn du nur 'nix develop' tippst
        default = self.devShells.${system}.esp;
      };
    };
}
