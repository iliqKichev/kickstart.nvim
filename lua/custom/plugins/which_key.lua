return {
  'folke/which-key.nvim',
  event = 'VimEnter',
  dependencies = {
    'echasnovski/mini.nvim',
  },
  config = function()
    local wk = require 'which-key'
    wk.add {
      { '<leader>c', desc = '[C]ode' },
      { '<leader>d', desc = '[D]ocument' },
      { '<leader>r', desc = '[R]edesc' },
      { '<leader>s', desc = '[S]earch' },
      { '<leader>w', desc = '[W]orkspace' },
      { '<leader>t', desc = '[T]oggle' },
      { '<leader>h', desc = 'Git [H]unk', mode = { 'n', 'v' } },
    }
  end,
}
