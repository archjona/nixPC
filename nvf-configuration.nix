{ pkgs, ... }:

{
  programs.nvf.settings.vim = {
    theme = {
      enable = true;
      name = "gruvbox";
      style = "dark";
    };

    statusline.lualine.enable = true;
    telescope.enable = true;
    autocomplete.nvim-cmp.enable = true;
    lsp.enable = true;

    # Keymaps für nvf
    maps.normal = {
      # gd für go to definition
      "gd" = {
        action = "<cmd>lua vim.lsp.buf.definition()<CR>";
        silent = true;
        desc = "Go to definition";
      };
    };

    # Zeilennummern absolut statt relativ
    options = {
      number = true;      # Zeilennummern anzeigen
      relativenumber = false;  # relative Nummern ausschalten
    };

    extraPlugins = {
      vimtex = {
        package = pkgs.vimPlugins.vimtex;
      };
    };

    luaConfigRC = {
      vimtex = ''
        vim.g.mapleader = " "
        vim.g.maplocalleader = " "
        vim.g.vimtex_compiler_method = "latexmk"
        vim.g.vimtex_view_method = "zathura"
        vim.g.vimtex_view_automatic = 1
      '';

      # Diagnostics für clangd ausschalten - aktualisierte Version ohne deprecated Funktion
      clangd-diagnostics = ''
        -- Clangd Diagnostics deaktivieren (aktualisierte Methode)
        vim.api.nvim_create_autocmd("LspAttach", {
          callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client and client.name == "clangd" then
              -- Neue Methode: Diagnostics für diesen Buffer deaktivieren
              vim.diagnostic.enable(false, { bufnr = args.buf })
            end
          end,
        })
      '';
    };

    terminal = {
      toggleterm = {
        enable = true;

        lazygit = {
          enable = true;
          direction = "float";   # optional, default ist "float"
          mappings = {
            open = "<leader>g";
          };
        };
      };
    };

    navigation.harpoon = {
      enable = true;
      mappings = {
        markFile = "<leader>a";
        listMarks = "<C-e>";
        file1 = "<leader>1";
        file2 = "<leader>2";
        file3 = "<leader>3";
        file4 = "<leader>4";
      };
    };

    languages = {
      enableTreesitter = true;
      nix.enable = true;
      clang.enable = true;
      clang.lsp.enable = true;
      lua.enable = true;
    };
  };
}
