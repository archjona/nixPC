{
  description = "Nixos config flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    nvf.url = "github:notashelf/nvf";
    mangowc = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      nvf,
      home-manager,
      mangowc,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Pfad zur Flake selbst, damit qt-dev und qt-new ihn kennen
      flakePath = "~/nixPC";
    in
    {
      # --- DEIN SYSTEM ---
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          flakePath = flakePath;
        };
        modules = [
          { nixpkgs.hostPlatform = system; }
          ./configuration.nix
          ./tmux.nix
          ./qt-dev.nix
          home-manager.nixosModules.default
          nvf.nixosModules.default
          mangowc.nixosModules.mango

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
        # ESP-IDF Shell
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
            export NIX_LD=$(nix eval --raw nixpkgs#stdenv.cc.bintools.dynamicLinker)
            export LD_LIBRARY_PATH="${
              pkgs.lib.makeLibraryPath [
                pkgs.stdenv.cc.cc
                pkgs.zlib
                pkgs.libusb1
              ]
            }"
            echo "--- ESP-IDF Umgebung bereit ---"
            echo "1. ./install.sh (nur beim ersten Mal)"
            echo "2. . ./export.sh"
          '';
        };

        # Qt6 Dev-Shell — Aufruf via 'qt-dev' oder 'nix develop /etc/nixos#qt'
        qt = pkgs.mkShell {
          name = "qt-dev-env";
          packages = with pkgs; [
            cmake
            ninja
            gcc
            clang-tools # clangd, clang-format
            pkg-config
            qt6.qtbase
            qt6.qttools # Designer, lupdate, lrelease
            qt6.qmake
            qt6.qtsvg # häufig benötigt
            qt6.qtdeclarative # falls QML
          ];
          # qtbase setzt seine Setup-Hooks selbst, das macht moc/uic/rcc auffindbar
          shellHook = ''
            echo "--- Qt6 Entwicklungsumgebung bereit ---"
            echo "  cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug"
            echo "  oder in nvim: <leader>cg → <leader>cb → <leader>cr"
          '';
        };

        default = self.devShells.${system}.esp;
      };
    };
}
