-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'theHamsta/nvim-dap-virtual-text',

    -- Add your own debuggers here
    -- 'leoluz/nvim-dap-go',
    'mfussenegger/nvim-dap-python',
  },

  keys = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    return {
      { '<F5>', dap.continue, mode = 'n', desc = 'Debug: Start/Continue' },
      { '<F1>', dap.step_into, mode = 'n', desc = 'Debug: Step Into' },
      { '<F1>', dap.step_over, mode = 'n', desc = 'Debug: Step Over' },
      { '<F3>', dap.step_out, mode = 'n', desc = 'Debug: Step Out' },
      { '<leader>b', dap.toggle_breakpoint, desc = 'Debug: Toggl Breakpoint' },
      {
        '<leader>B',
        function()
          dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        desc = 'Debug: Set Breakpoint',
      },
      { '<F7>', dapui.toggle, mode = 'n', desc = 'Debug: See last session result' },
    }
  end,

  config = function()
    local mason_dap = require 'mason-nvim-dap'
    local dap = require 'dap'
    local dapui = require 'dapui'
    local dap_virtual_text = require 'nvim-dap-virtual-text'

    -- DAP Virtual Text default setup
    dap_virtual_text.setup()

    mason_dap.setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {
        function(config)
          mason_dap.default_setup(config)
        end,
      },

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'cppdbg', -- C/C++
        'debugpy', -- Python
      },
    }

    -- Dap Configs
    dap.configurations = {
      -- As taken from https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#c-c-rust-via-gdb
      c = {
        {
          name = 'Launch',
          type = 'gdb',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          args = {},
          cwd = '${workspaceFolder}',
          stopAtBeginningOfMainProgram = false,
        },
        {
          name = 'Select and Attach to process',
          type = 'gdb',
          request = 'attach',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          pid = function()
            local name = vim.fn.input 'Executable name (filter): '
            return require('dap.utils').pick_process { filter = name }
          end,
          cwd = '${workspaceFolder}',
        },
        {
          name = 'Attach to gdbserver :1234',
          type = 'gdb',
          request = 'attach',
          target = 'localhost:1234',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
        },
      },
      python = {
        name = 'Launch File',
        type = 'python',
        reques = 'launch',

        program = '${file}',
        pythonPath = function()
          -- use the Virtual environment if such exists otherwise it uses the default path
          local env = os.getenv 'VIRTUAL_ENV'
          if vim.fn.executable(env .. '/bin/python') then
            return env .. '/bin/python'
          else
            return '/usr/bin/python'
          end
        end,
      },
    }

    -- Have the same configs for C++ and Rust
    dap.configurations.cpp = dap.configurations.c
    dap.configurations.rust = dap.configurations.c

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '', collapsed = '', current_frame = '*' },
      controls = {
        icons = {
          pause = '',
          play = '',
          step_into = '',
          step_over = '',
          step_out = '',
          step_back = '',
          run_last = '',
          terminate = '',
          disconnect = '',
        },
      },
    }

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    -- vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    -- require('dap-go').setup {
    --   delve = {
    --    -- On Windows delve must be run attached or it crashes.
    --    -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
    --    detached = vim.fn.has 'win32' == 0,
    --  },
    -- }
  end,
}
