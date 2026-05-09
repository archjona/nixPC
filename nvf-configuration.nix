{ pkgs, ... }:

{
  programs.nvf.settings.vim = {

    # ════════════════════════════════════════════════════════════════
    # 🎨 UI / Theme
    # ════════════════════════════════════════════════════════════════

    theme = {
      enable = true;
      name = "gruvbox";
      style = "dark";
    };

    statusline.lualine.enable = true;

    options = {
      number = true;
      relativenumber = false;
    };

    clipboard = {
      enable = true;
      registers = "unnamedplus";
    };

    # ════════════════════════════════════════════════════════════════
    # 🔌 Core Features (LSP, Completion, Telescope, Debugger)
    # ════════════════════════════════════════════════════════════════

    lsp.enable = true;
    autocomplete.nvim-cmp.enable = true;
    telescope.enable = true;

    debugger.nvim-dap = {
      enable = true;
      ui.enable = true;
    };

    # ════════════════════════════════════════════════════════════════
    # 🤖 AI Assistant (GitHub Copilot)
    # ════════════════════════════════════════════════════════════════

    assistant = {
      # Inline Code-Suggestions (Tab zum Akzeptieren)
      copilot = {
        enable = true;
        setupOpts = {
          suggestion = {
            enabled = true;
            auto_trigger = true;
            keymap = {
              accept = "<Tab>";
              accept_word = false;
              accept_line = false;
              next = "<M-]>";
              prev = "<M-[>";
              dismiss = "<C-]>";
            };
          };
          panel.enabled = true;
          filetypes = {
            yaml = true;
            markdown = true;
            help = false;
            gitcommit = true;
            gitrebase = false;
            "*" = true;
          };
        };
      };
    };

    # ════════════════════════════════════════════════════════════════
    # 🌐 Languages & Treesitter
    # ════════════════════════════════════════════════════════════════

    languages = {
      enableTreesitter = true;
      nix.enable = true;
      clang = {
        enable = true;
        lsp.enable = true;
        treesitter.enable = true; # ← NEU: aktiviert C/C++ Highlighting
      };

      lua.enable = true;
    };

    treesitter = {
      enable = true;
      grammars = with pkgs.tree-sitter-grammars; [
        tree-sitter-yaml
        tree-sitter-cmake
      ];
    };

    # ════════════════════════════════════════════════════════════════
    # 🧰 Navigation & Terminal
    # ════════════════════════════════════════════════════════════════

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

    terminal.toggleterm = {
      enable = true;
      lazygit = {
        enable = true;
        direction = "float";
        mappings.open = "<leader>g";
      };
    };

    # ════════════════════════════════════════════════════════════════
    # ⌨️  Globale Keymaps
    # ════════════════════════════════════════════════════════════════

    maps.normal = {
      "gd" = {
        action = "<cmd>lua vim.lsp.buf.definition()<CR>";
        silent = true;
        desc = "Go to definition";
      };
      "<leader>f" = {
        action = "<cmd>lua vim.lsp.buf.format({ async = true })<CR>";
        silent = true;
        desc = "Format buffer with LSP";
      };
      "<leader>gs" = {
        action = "<cmd>Telescope grep_string<CR>";
        silent = true;
        desc = "Grep word under cursor [Telescope]";
      };
    };

    # ════════════════════════════════════════════════════════════════
    # 📦 Extra Plugins
    # ════════════════════════════════════════════════════════════════

    extraPlugins = {

      # ─── LaTeX ──────────────────────────────────────────────────
      vimtex = {
        package = pkgs.vimPlugins.vimtex;
      };

      # ─── DAP Virtual Text (Werte neben dem Code) ────────────────
      nvim-dap-virtual-text = {
        package = pkgs.vimPlugins.nvim-dap-virtual-text;
        setup = ''
          require("nvim-dap-virtual-text").setup({
            enabled = true,
            enabled_commands = true,
            highlight_changed_variables = true,
            highlight_new_as_changed = false,
            show_stop_reason = true,
            commented = false,
            virt_text_pos = "eol",
            all_frames = false,
          })
        '';
      };

      # ─── CMake Tools (Dependency: plenary) ──────────────────────
      plenary-nvim = {
        package = pkgs.vimPlugins.plenary-nvim;
      };

      cmake-tools-nvim = {
        package = pkgs.vimPlugins.cmake-tools-nvim;
        setup = ''
          require("cmake-tools").setup({
            cmake_command = "cmake",
            cmake_build_directory = "build/''${variant:buildType}",
            cmake_generate_options = {
              "-G", "Ninja",
              "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
            },
            cmake_soft_link_compile_commands = true,
            cmake_compile_commands_from_lsp = false,
            cmake_regenerate_on_save = true,

            cmake_executor = {
              name = "toggleterm",
              opts = {
                direction = "float",
                close_on_exit = false,
              },
            },
            cmake_runner = {
              name = "toggleterm",
              opts = {
                direction = "float",
                close_on_exit = false,
              },
            },
            cmake_notifications = {
              enabled = true,
              spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
              refresh_rate_ms = 100,
            },
          })

          -- CMake Keymaps
          local map = vim.keymap.set
          map("n", "<leader>cg", "<cmd>CMakeGenerate<CR>",         { silent = true, desc = "CMake: Generate" })
          map("n", "<leader>cb", "<cmd>CMakeBuild<CR>",            { silent = true, desc = "CMake: Build" })
          map("n", "<leader>cr", "<cmd>CMakeRun<CR>",              { silent = true, desc = "CMake: Run" })
          map("n", "<leader>cd", "<cmd>CMakeDebug<CR>",            { silent = true, desc = "CMake: Debug" })
          map("n", "<leader>cc", "<cmd>CMakeClean<CR>",            { silent = true, desc = "CMake: Clean" })
          map("n", "<leader>ct", "<cmd>CMakeSelectBuildTarget<CR>",{ silent = true, desc = "CMake: Select Target" })
          map("n", "<leader>cv", "<cmd>CMakeSelectBuildType<CR>",  { silent = true, desc = "CMake: Build Type" })
          map("n", "<leader>cq", "<cmd>CMakeStop<CR>",             { silent = true, desc = "CMake: Stop" })
        '';
      };

      # ─── CodeCompanion (Chat-AI mit Copilot) ────────────────────
      codecompanion-nvim = {
        package = pkgs.vimPlugins.codecompanion-nvim;
        setup = ''
          require("codecompanion").setup({
            strategies = {
              chat   = { adapter = "copilot" },
              inline = { adapter = "copilot" },
              agent  = { adapter = "copilot" },
            },
            display = {
              chat = {
                show_settings = false,
              },
            },
          })

          -- AI Keymaps
          local map = vim.keymap.set
          map("n", "<leader>ac", "<cmd>CodeCompanionChat Toggle<CR>",
            { silent = true, desc = "AI: Chat öffnen" })
          map("v", "<leader>ae", "<cmd>'<,'>CodeCompanion /explain<CR>",
            { silent = true, desc = "AI: Code erklären" })
          map("v", "<leader>ao", "<cmd>'<,'>CodeCompanion /optimize<CR>",
            { silent = true, desc = "AI: Code optimieren" })
          map("v", "<leader>at", "<cmd>'<,'>CodeCompanion /tests<CR>",
            { silent = true, desc = "AI: Tests generieren" })
        '';
      };
    };

    # ════════════════════════════════════════════════════════════════
    # 📝 Lua Konfiguration
    # ════════════════════════════════════════════════════════════════

    luaConfigRC = {

      # ─── Leader & VimTeX ────────────────────────────────────────
      vimtex = ''
        vim.g.mapleader = " "
        vim.g.maplocalleader = " "
        vim.g.vimtex_compiler_method = "latexmk"
        vim.g.vimtex_view_method = "zathura"
        vim.g.vimtex_view_automatic = 1
        vim.keymap.set("n", "<leader>ll", "<cmd>VimtexCompile<CR>",
          { silent = true, desc = "Latex kompilieren" })
      '';

      # ─── Clangd: Qt-freundliche Args + Header/Source Switch ─────
      clangd-qt = ''
        vim.api.nvim_create_autocmd("LspAttach", {
          callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client and client.name == "clangd" then
              client.config.cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--header-insertion=iwyu",
                "--completion-style=detailed",
                "--function-arg-placeholders",
                "--fallback-style=llvm",
              }
            end
          end,
        })

        vim.keymap.set("n", "<leader>o", "<cmd>ClangdSwitchSourceHeader<CR>",
          { silent = true, desc = "Switch Header/Source" })
      '';

      # ─── Clangd: Diagnostics deaktivieren ───────────────────────
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

      # ─── DAP: codelldb Adapter + Configs ────────────────────────
      dap-cpp = ''
        local dap = require("dap")

        -- Adapter
        dap.adapters.codelldb = {
          type = "server",
          port = "''${port}",
          executable = {
            command = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb",
            args = { "--port", "''${port}" },
          },
        }

        -- Launch-Configs für C / C++
        local cpp_config = {
          {
            name = "Launch (cmake-tools target)",
            type = "codelldb",
            request = "launch",
            program = function()
              local ok, cmake = pcall(require, "cmake-tools")
              if ok and cmake.get_launch_target then
                local target = cmake.get_launch_target_path and cmake.get_launch_target_path()
                if target and target ~= "" then return target end
              end
              return vim.fn.input("Pfad zur Executable: ", vim.fn.getcwd() .. "/build/", "file")
            end,
            cwd = "''${workspaceFolder}",
            stopOnEntry = false,
            args = {},
            env = function()
              local variables = {}
              for k, v in pairs(vim.fn.environ()) do
                table.insert(variables, string.format("%s=%s", k, v))
              end
              return variables
            end,
          },
          {
            name = "Attach to running process",
            type = "codelldb",
            request = "attach",
            pid = require("dap.utils").pick_process,
            cwd = "''${workspaceFolder}",
          },
        }

        dap.configurations.cpp = cpp_config
        dap.configurations.c   = cpp_config

        -- DAP Signs
        vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DiagnosticError",  numhl = "" })
        vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn",   numhl = "" })
        vim.fn.sign_define("DapLogPoint",            { text = "◉", texthl = "DiagnosticInfo",   numhl = "" })
        vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DiagnosticOk",     numhl = "Visual" })
        vim.fn.sign_define("DapBreakpointRejected",  { text = "✖", texthl = "DiagnosticError",  numhl = "" })
      '';

      # ─── DAP: Keymaps + UI Auto-Toggle ──────────────────────────
      dap-keymaps = ''
        local dap   = require("dap")
        local dapui = require("dapui")
        local map   = vim.keymap.set

        -- F-Tasten (Qt Creator / VS Code Style)
        map("n", "<F5>",  function() dap.continue()         end, { desc = "DAP: Continue" })
        map("n", "<F9>",  function() dap.toggle_breakpoint() end, { desc = "DAP: Breakpoint" })
        map("n", "<F10>", function() dap.step_over()        end, { desc = "DAP: Step Over" })
        map("n", "<F11>", function() dap.step_into()        end, { desc = "DAP: Step Into" })
        map("n", "<F12>", function() dap.step_out()         end, { desc = "DAP: Step Out" })

        -- <leader>d* Mappings
        map("n", "<leader>db", function() dap.toggle_breakpoint() end,
          { desc = "DAP: Toggle Breakpoint" })
        map("n", "<leader>dB", function()
          dap.set_breakpoint(vim.fn.input("Breakpoint Bedingung: "))
        end, { desc = "DAP: Conditional Breakpoint" })
        map("n", "<leader>dl", function() dap.run_last()    end, { desc = "DAP: Run Last" })
        map("n", "<leader>dr", function() dap.repl.toggle() end, { desc = "DAP: REPL" })
        map("n", "<leader>dt", function() dap.terminate()   end, { desc = "DAP: Terminate" })
        map("n", "<leader>du", function() dapui.toggle()    end, { desc = "DAP: Toggle UI" })

        map({ "n", "v" }, "<leader>de", function()
          dapui.eval(nil, { enter = true })
        end, { desc = "DAP: Eval expression" })

        -- UI Auto-Toggle
        dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open()  end
        dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
        dap.listeners.before.event_exited["dapui_config"]     = function() dapui.close() end
      '';

      # ─── Auto-Format beim Speichern (außer in build/) ───────────
      autoformat = ''
        vim.api.nvim_create_autocmd("BufWritePre", {
          pattern = { "*.c", "*.cpp", "*.h", "*.hpp", "*.nix" },
          callback = function(args)
            local fname = vim.api.nvim_buf_get_name(args.buf)
            if fname:match("/build/") or fname:match("/cmake%-build") then
              return
            end
            vim.lsp.buf.format({ async = false })
          end,
        })
      '';
    };
  };
}
