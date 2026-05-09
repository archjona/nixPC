{ pkgs, ... }:

{
  programs.nvf.settings.vim = {
    theme = {
      enable = true;
      name = "gruvbox";
      style = "dark";
    };

    statusline.lualine.enable = true;
    autocomplete.nvim-cmp.enable = true;
    telescope.enable = true;
    lsp.enable = true;

    debugger = {
      nvim-dap = {
        enable = true;
        ui.enable = true;
      };
    };

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

    clipboard = {
      enable = true;
      registers = "unnamedplus";
    };

    options = {
      number = true;
      relativenumber = false;
    };

    extraPlugins = {
      vimtex = {
        package = pkgs.vimPlugins.vimtex;
      };

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

      # Plenary als Dependency für cmake-tools
      plenary-nvim = {
        package = pkgs.vimPlugins.plenary-nvim;
      };

      # CMake Integration für Qt/C++
      cmake-tools-nvim = {
        package = pkgs.vimPlugins.cmake-tools-nvim;
        setup = ''
          require("cmake-tools").setup({
            cmake_command = "cmake",
            cmake_build_directory = "build/''${variant:buildType}",
            cmake_generate_options = {
              "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
              "-DCMAKE_BUILD_TYPE=Debug",
            },
            cmake_soft_link_compile_commands = true,  -- symlinkt compile_commands.json ins Projekt-Root für clangd
            cmake_compile_commands_from_lsp = false,
            cmake_regenerate_on_save = true,
            cmake_executor = {
              name = "toggleterm",  -- nutzt dein vorhandenes toggleterm
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

          -- Tastenkürzel für CMake/Qt Workflow
          vim.keymap.set("n", "<leader>cg", "<cmd>CMakeGenerate<CR>",        { silent = true, desc = "CMake: Generate" })
          vim.keymap.set("n", "<leader>cb", "<cmd>CMakeBuild<CR>",            { silent = true, desc = "CMake: Build" })
          vim.keymap.set("n", "<leader>cr", "<cmd>CMakeRun<CR>",              { silent = true, desc = "CMake: Run" })
          vim.keymap.set("n", "<leader>cd", "<cmd>CMakeDebug<CR>",            { silent = true, desc = "CMake: Debug" })
          vim.keymap.set("n", "<leader>cc", "<cmd>CMakeClean<CR>",            { silent = true, desc = "CMake: Clean" })
          vim.keymap.set("n", "<leader>ct", "<cmd>CMakeSelectBuildTarget<CR>",{ silent = true, desc = "CMake: Select Target" })
          vim.keymap.set("n", "<leader>cv", "<cmd>CMakeSelectBuildType<CR>",  { silent = true, desc = "CMake: Build Type (Debug/Release)" })
          vim.keymap.set("n", "<leader>cq", "<cmd>CMakeStop<CR>",             { silent = true, desc = "CMake: Stop" })
        '';
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
            display = {
              chat = {
                show_settings = false,
              },
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
    # 🎯 TREE-SITTER GRAMMATIK
    # ==============================================
    treesitter = {
      enable = true;
      grammars = with pkgs.tree-sitter-grammars; [
        tree-sitter-yaml
        tree-sitter-cpp
        tree-sitter-c
        tree-sitter-cmake
      ];
    };

    # ==============================================
    # 🌐 LANGUAGES (für LSP)
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

      # NEU: DAP für C/C++ mit codelldb
      dap-cpp = ''
        local dap = require("dap")

        -- Adapter Definition
        dap.adapters.codelldb = {
          type = "server",
          port = "''${port}",
          executable = {
            command = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb",
            args = { "--port", "''${port}" },
          },
        }

        -- Launch-Configurations für C, C++ und Rust (nutzen denselben Adapter)
        local cpp_config = {
          {
            name = "Launch (cmake-tools target)",
            type = "codelldb",
            request = "launch",
            -- cmake-tools.nvim liefert die Executable automatisch:
            program = function()
              local ok, cmake = pcall(require, "cmake-tools")
              if ok and cmake.get_launch_target then
                local target = cmake.get_launch_target_path and cmake.get_launch_target_path()
                if target and target ~= "" then return target end
              end
              -- Fallback: Pfad manuell angeben
              return vim.fn.input("Pfad zur Executable: ", vim.fn.getcwd() .. "/build/", "file")
            end,
            cwd = "''${workspaceFolder}",
            stopOnEntry = false,
            args = {},
            -- Qt-Plugin/Lib Pfad falls nötig:
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

        dap.configurations.cpp  = cpp_config
        dap.configurations.c    = cpp_config

        -- Bessere Visuals: rote Punkte für Breakpoints, Pfeil für aktuelle Zeile
        vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DiagnosticError",  numhl = "" })
        vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn",   numhl = "" })
        vim.fn.sign_define("DapLogPoint",            { text = "◉", texthl = "DiagnosticInfo",   numhl = "" })
        vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DiagnosticOk",     numhl = "Visual" })
        vim.fn.sign_define("DapBreakpointRejected",  { text = "✖", texthl = "DiagnosticError",  numhl = "" })
      '';

      # NEU: DAP Tastenkürzel
      dap-keymaps = ''
        local dap = require("dap")
        local dapui = require("dapui")

        -- Standardisierte F-Tasten (wie Qt Creator / VS Code)
        vim.keymap.set("n", "<F5>",  function() dap.continue()        end, { desc = "DAP: Continue / Start" })
        vim.keymap.set("n", "<F9>",  function() dap.toggle_breakpoint() end, { desc = "DAP: Toggle Breakpoint" })
        vim.keymap.set("n", "<F10>", function() dap.step_over()       end, { desc = "DAP: Step Over" })
        vim.keymap.set("n", "<F11>", function() dap.step_into()       end, { desc = "DAP: Step Into" })
        vim.keymap.set("n", "<F12>", function() dap.step_out()        end, { desc = "DAP: Step Out" })

        -- <leader>d* Mappings (passt zu deinem CMake <leader>c* Schema)
        vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end,
          { desc = "DAP: Toggle Breakpoint" })
        vim.keymap.set("n", "<leader>dB", function()
          dap.set_breakpoint(vim.fn.input("Breakpoint Bedingung: "))
        end, { desc = "DAP: Conditional Breakpoint" })
        vim.keymap.set("n", "<leader>dl", function() dap.run_last()      end, { desc = "DAP: Run Last" })
        vim.keymap.set("n", "<leader>dr", function() dap.repl.toggle()   end, { desc = "DAP: REPL" })
        vim.keymap.set("n", "<leader>dt", function() dap.terminate()     end, { desc = "DAP: Terminate" })
        vim.keymap.set("n", "<leader>du", function() dapui.toggle()      end, { desc = "DAP: Toggle UI" })

        -- Variable unter Cursor inspizieren (Hover)
        vim.keymap.set({ "n", "v" }, "<leader>de", function()
          require("dapui").eval(nil, { enter = true })
        end, { desc = "DAP: Eval expression" })

        -- UI auto-open/close
        dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open()  end
        dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
        dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end
      '';

      clangd-qt = ''
        -- clangd mit Qt-freundlichen Argumenten starten
        vim.api.nvim_create_autocmd("LspAttach", {
          callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client and client.name == "clangd" then
              -- Qt-Header sichtbar machen (falls clangd sie nicht autom. findet)
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

        -- Header/Source Switch (wie F4 in Qt Creator)
        vim.keymap.set("n", "<leader>o", "<cmd>ClangdSwitchSourceHeader<CR>",
          { silent = true, desc = "Switch Header/Source" })
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

      # Automatische Formatierung beim Speichern für C/C++ und Nix
      autoformat = ''
             vim.api.nvim_create_autocmd("BufWritePre", {
          pattern = { "*.c", "*.cpp", "*.h", "*.hpp", "*.nix" },
          callback = function(args)
            -- Skip files inside build directories
            local fname = vim.api.nvim_buf_get_name(args.buf)
            if fname:match("/build/") or fname:match("/cmake%-build") then
              return
            end
            vim.lsp.buf.format({ async = false })
          end,
        })
      '';
    };

    # ==============================================
    # WEITERE PLUGINS
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
