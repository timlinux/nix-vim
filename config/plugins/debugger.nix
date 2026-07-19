{ ... }:
{
  vim.debugger = {
    nvim-dap = {
      enable = true;

      ui = {
        enable = true;
        autoStart = true;
      };

      mappings = {
        continue = "<leader>dc";
        goDown = "<leader>dj";
        goUp = "<leader>dk";
        hover = "<leader>dh";
        restart = "<leader>dR";
        runLast = "<leader>d.";
        runToCursor = "<leader>dt";
        stepBack = "<leader>do";
        stepInto = "<leader>dn";
        stepOver = "<leader>dv";
        terminate = "<leader>dq";
        toggleBreakpoint = "<leader>db";
        toggleDapUI = "<leader>du";
        toggleRepl = "<leader>dr";
      };

    };
  };

  # Custom DAP configurations for remote debugging
  vim.luaConfigRC.dap-remote = ''
    local dap = require('dap')

    -- Setup Python adapter with comprehensive error handling
    local function setup_python_adapter()
      -- Try to find Python executable
      local python_cmd = vim.fn.exepath('python3') or vim.fn.exepath('python')
      
      if python_cmd == "" then
        vim.notify('Python executable not found in PATH', vim.log.levels.ERROR)
        return false
      end

      -- Check if debugpy is available
      local handle = io.popen(python_cmd .. ' -c "import debugpy; print(debugpy.__version__)" 2>/dev/null')
      local result = ""
      if handle then
        result = handle:read("*a") or ""
        handle:close()
      end

      if result == "" then
        vim.notify('debugpy not installed. Install with: pip install debugpy', vim.log.levels.ERROR)
        return false
      else
        local version = vim.trim and vim.trim(result) or result
        vim.notify('Found debugpy version: ' .. version, vim.log.levels.INFO)
      end

      -- Setup the executable adapter (for launch configurations)
      dap.adapters.python = {
        type = 'executable',
        command = python_cmd,
        args = { '-m', 'debugpy.adapter' },
        options = {
          source_filetype = 'python',
        },
        -- Add environment for better compatibility
        env = {
          PYTHONPATH = vim.fn.getcwd(),
        },
      }
      
      -- Setup a direct server adapter that bypasses the executable adapter
      dap.adapters.python_direct = function(cb, config)
        cb({
          type = 'server',
          host = '127.0.0.1',
          port = config.port or tonumber(vim.g.dap_python_port) or 9000,
        })
      end

      return true
    end

    -- Initialize Python adapter
    if not setup_python_adapter() then
      vim.notify('Python DAP adapter setup failed', vim.log.levels.ERROR)
    end

    -- Python configurations
    dap.configurations.python = dap.configurations.python or {}

    -- Direct server connection (bypasses executable adapter)
    table.insert(dap.configurations.python, {
      type = 'python_direct',
      request = 'attach',
      name = 'Attach to Debug Server',
      pathMappings = {
        {
          localRoot = vim.fn.getcwd(),
          remoteRoot = vim.fn.getcwd()
        }
      },
      justMyCode = false,
    })

    -- Fallback standard attach configuration
    table.insert(dap.configurations.python, {
      type = 'python',
      request = 'attach',
      name = 'Standard Attach',
      connect = {
        host = '127.0.0.1',
        port = tonumber(vim.g.dap_python_port) or 9000
      },
      pathMappings = {
        {
          localRoot = vim.fn.getcwd(),
          remoteRoot = vim.fn.getcwd()
        }
      },
      justMyCode = false,
    })

    -- Add custom debug functions
    local function test_debug_connection(port)
      local handle = io.popen('timeout 5 nc -z localhost ' .. port .. ' 2>/dev/null && echo "CONNECTION_OK" || echo "CONNECTION_FAILED"')
      local result = ""
      if handle then
        result = handle:read("*a") or ""
        handle:close()
      end
      
      return vim.trim(result) == "CONNECTION_OK"
    end

    local function attach_remote_debugger()
      local ok, dap = pcall(require, 'dap')
      if not ok then
        vim.notify('DAP not available', vim.log.levels.ERROR)
        return
      end

      local default_port = vim.g.dap_python_port or "9000"
      vim.ui.input({ prompt = "Python debug port: ", default = default_port }, function(input)
        if not input or input == "" then return end
        local port = tonumber(input)
        if not port then
          vim.notify('Invalid port number', vim.log.levels.ERROR)
          return
        end
        vim.g.dap_python_port = tostring(port)

        vim.notify('Testing connection to port ' .. port .. '...', vim.log.levels.INFO)
        if not test_debug_connection(port) then
          vim.notify('Cannot connect to port ' .. port .. '. Make sure your Python script is running with debugpy.listen().', vim.log.levels.ERROR)
          return
        end

        vim.notify('Connection OK. Attaching...', vim.log.levels.INFO)
        dap.run({
          type = 'python_direct',
          request = 'attach',
          name = 'Remote Attach (' .. port .. ')',
          port = port,
          pathMappings = {
            {
              localRoot = vim.fn.getcwd(),
              remoteRoot = vim.fn.getcwd()
            }
          },
          justMyCode = false,
        })
      end)
    end

    local function start_local_debugging()
      local ok, dap = pcall(require, 'dap')
      if not ok then
        vim.notify('DAP not available', vim.log.levels.ERROR)
        return
      end

      dap.continue()
    end

    local function show_debug_status()
      local ok, dap = pcall(require, 'dap')
      if not ok then
        vim.notify('DAP not available', vim.log.levels.ERROR)
        return
      end

      local session = dap.session()
      if session then
        vim.notify('DAP session active', vim.log.levels.INFO)
      else
        vim.notify('No active DAP session', vim.log.levels.WARN)
      end
    end

    -- Check debugpy installation
    local function check_debugpy_installation()
      local python_cmd = vim.fn.exepath('python3') or vim.fn.exepath('python')
      
      if python_cmd == "" then
        vim.notify('Python executable not found in PATH', vim.log.levels.ERROR)
        return
      end

      local handle = io.popen(python_cmd .. ' -c "import debugpy; print(debugpy.__version__)" 2>/dev/null')
      local result = ""
      if handle then
        result = handle:read("*a") or ""
        handle:close()
      end

      if result == "" then
        vim.notify('debugpy not installed. Run: pip install debugpy', vim.log.levels.WARN)
        -- Optionally try to install it
        vim.ui.input({ prompt = 'Install debugpy now? (y/N): ' }, function(input)
          if input and (input:lower() == 'y' or input:lower() == 'yes') then
            vim.fn.system(python_cmd .. ' -m pip install debugpy')
            vim.notify('debugpy installation attempted. Restart Neovim.', vim.log.levels.INFO)
          end
        end)
      else
        local version = vim.trim and vim.trim(result) or result
        vim.notify('debugpy is installed. Version: ' .. version, vim.log.levels.INFO)
      end
    end

    -- Show debug port in message bar when session starts
    dap.listeners.before.event_initialized.dap_port_listener = function(session)
      local adapter = session and session.adapter
      local port = adapter and adapter.port
      if port then
        vim.api.nvim_echo({{'Debug Port ' .. port, 'WarningMsg'}}, false, {})
      end
    end

    -- Setup DAP event listeners for better error handling
    dap.listeners.before.attach.dap_attach_listener = function()
      vim.notify('Initiating debug attach...', vim.log.levels.INFO)
    end

    dap.listeners.after.attach.dap_attach_listener = function()
      vim.notify('Successfully attached to debugger!', vim.log.levels.INFO)
    end

    dap.listeners.before.disconnect.dap_disconnect_listener = function()
      vim.notify('Disconnecting from debugger...', vim.log.levels.INFO)
    end

    dap.listeners.after.disconnect.dap_disconnect_listener = function()
      vim.notify('Disconnected from debugger', vim.log.levels.INFO)
    end

    -- Add error handling for failed connections
    dap.listeners.before.event_terminated.dap_terminated_listener = function()
      vim.notify('Debug session terminated', vim.log.levels.WARN)
    end

    -- Kill any hanging debug processes function
    local function kill_debug_processes()
      vim.fn.system('pkill -f "debugpy.adapter"')
      local port = vim.g.dap_python_port or "9000"
      vim.fn.system('pkill -f "debugpy.*' .. port .. '"')
      vim.notify('Killed debug processes', vim.log.levels.INFO)
    end

    -- Register keymaps with which-key integration
    vim.keymap.set('n', '<leader>da', attach_remote_debugger, { desc = '󰌠 Attach to Python Debugger' })
    vim.keymap.set('n', '<leader>dl', start_local_debugging, { desc = '󰐊 Start/Continue local debugging' })
    vim.keymap.set('n', '<leader>ds', show_debug_status, { desc = '󰋼 Show debug status' })
    vim.keymap.set('n', '<leader>di', check_debugpy_installation, { desc = '󰏗 Check debugpy installation' })
    vim.keymap.set('n', '<leader>dk', kill_debug_processes, { desc = '󰅗 Kill hanging debug processes' })

    -- Standard F-key debug shortcuts (single keypress)
    vim.keymap.set('n', '<F5>', function() dap.continue() end, { desc = '󰐊 Debug: Continue (F5)' })
    vim.keymap.set('n', '<F8>', function() dap.toggle_breakpoint() end, { desc = '󰃤 Debug: Toggle Breakpoint (F8)' })
    vim.keymap.set('n', '<F9>', function() dap.step_over() end, { desc = '󰆹 Debug: Step Over (F9)' })
    vim.keymap.set('n', '<F10>', function() dap.step_into() end, { desc = '󰆸 Debug: Step Into (F10)' })
    vim.keymap.set('n', '<F11>', function() dap.step_out() end, { desc = '󰆺 Debug: Step Out (F11)' })
    vim.keymap.set('n', '<F12>', function() dap.run_to_cursor() end, { desc = '󰆾 Debug: Run to Cursor (F12)' })

    -- Shift+F-key combinations for additional debug functions
    vim.keymap.set('n', '<S-F5>', function() dap.terminate() end, { desc = '󰅗 Debug: Terminate (S-F5)' })
    vim.keymap.set('n', '<S-F8>', function() dap.clear_breakpoints() end, { desc = '󰹍 Debug: Clear All Breakpoints (S-F8)' })
    vim.keymap.set('n', '<S-F9>', function()
      local dapui = require('dapui')
      dapui.toggle()
    end, { desc = '󰕮 Debug: Toggle UI (S-F9)' })

    -- Override NVF leader mappings to include F-key hints in which-key
    vim.keymap.set('n', '<leader>dc', function() dap.continue() end, { desc = '󰐊 Continue (F5)' })
    vim.keymap.set('n', '<leader>dv', function() dap.step_over() end, { desc = '󰆹 Step Over (F9)' })
    vim.keymap.set('n', '<leader>dn', function() dap.step_into() end, { desc = '󰆸 Step Into (F10)' })
    vim.keymap.set('n', '<leader>db', function() dap.toggle_breakpoint() end, { desc = '󰃤 Toggle Breakpoint (F8)' })
    vim.keymap.set('n', '<leader>dq', function() dap.terminate() end, { desc = '󰅗 Terminate (S-F5)' })
    vim.keymap.set('n', '<leader>dt', function() dap.run_to_cursor() end, { desc = '󰆾 Run to Cursor (F12)' })
    vim.keymap.set('n', '<leader>du', function()
      local dapui = require('dapui')
      dapui.toggle()
    end, { desc = '󰕮 Toggle DAP UI (S-F9)' })

    -- Go: override NVF's adapter to use a hardcoded port (Nix escaping breaks port substitution)
    local delve_cmd = vim.fn.exepath('dlv')
    if delve_cmd ~= "" then
      dap.adapters.go = function(cb, config)
        local port = config.port or tonumber(vim.g.dap_go_port) or 38697
        vim.g.dap_go_port = tostring(port)
        cb({
          type = 'server',
          port = port,
          executable = {
            command = delve_cmd,
            args = { 'dap', '-l', '127.0.0.1:' .. port },
            detached = vim.fn.has("win32") == 0,
          },
        })
      end
    end
  '';
}
