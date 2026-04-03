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
      "gd" = {
        action = "<cmd>lua vim.lsp.buf.definition()<CR>";
        silent = true;
        desc = "Go to definition";
      };
    };

    clipboard = {
      enable = true;
      registers = "unnamedplus";
    };

    options = {
      number = true;
      relativenumber = false;
    };

    # ==============================================
    # 🚀 EXTRA PLUGINS (laut nvf-Dokumentation)
    # ==============================================
    extraPlugins = {
      vimtex = {
        package = pkgs.vimPlugins.vimtex;
      };
      codecompanion-nvim = {
        package = pkgs.vimPlugins.codecompanion-nvim;
        setup = ''
          require("codecompanion").setup({
            adapters = {
              ollama = function()
                return require("codecompanion.adapters").extend("ollama", {
                  name = "deepseek",
                  env = {
                    url = "http://localhost:11434",
                  },
                  schema = {
                    model = {
                      default = "deepseek-coder:6.7b-instruct-q4_K_M",
                    },
                    num_ctx = {
                      default = 8192,
                    },
                  },
                })
              end,
            },
            strategies = {
              chat = { adapter = "ollama" },
              inline = { adapter = "ollama" },
            },
          })
          
          -- Tastenkürzel für AI-Funktionen
          vim.keymap.set("n", "<leader>ac", "<cmd>CodeCompanionChat<CR>", { silent = true, desc = "AI Chat öffnen" })
          vim.keymap.set("v", "<leader>ae", "<cmd>'<,'>CodeCompanion /explain<CR>", { silent = true, desc = "Code erklären" })
          vim.keymap.set("v", "<leader>ao", "<cmd>'<,'>CodeCompanion /optimize<CR>", { silent = true, desc = "Code optimieren" })
          vim.keymap.set("v", "<leader>at", "<cmd>'<,'>CodeCompanion /tests<CR>", { silent = true, desc = "Tests generieren" })
        '';
      };
    };

    # ==============================================
    # 🎯 TREE-SITTER GRAMMATIK (DIREKT UNTER vim!)
    # ==============================================
    treesitter = {
      enable = true;
      grammars = with pkgs.tree-sitter-grammars; [
        tree-sitter-yaml  # YAML für CodeCompanion-Prompts
      ];
    };

    # ==============================================
    # 🌐 LANGUAGES (für LSP, NICHT für Tree-sitter!)
    # ==============================================
    languages = {
      enableTreesitter = true;
      nix.enable = true;
      clang.enable = true;
      clang.lsp.enable = true;
      lua.enable = true;
    };

    # ==============================================
    # 📝 LUA KONFIGURATION
    # ==============================================
    luaConfigRC = {
      vimtex = ''
        vim.g.mapleader = " "
        vim.g.maplocalleader = " "
        vim.g.vimtex_compiler_method = "latexmk"
        vim.g.vimtex_view_method = "zathura"
        vim.g.vimtex_view_automatic = 1
        vim.keymap.set("n", "<leader>ll", "<cmd>VimtexCompile<CR>", { silent = true, desc = "Latex kompilieren" })
      '';
      
      clangd-diagnostics = ''
        vim.api.nvim_create_autocmd("LspAttach", {
          callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client and client.name == "clangd" then
              vim.diagnostic.enable(false, { bufnr = args.buf })
            end
          end,
        })
      '';
    };

    # ==============================================
    # ⚙️ WEITERE PLUGINS
    # ==============================================
    terminal = {
      toggleterm = {
        enable = true;
        lazygit = {
          enable = true;
          direction = "float";
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
  };
}
