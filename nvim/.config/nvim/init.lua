-- options
vim.opt.clipboard = 'unnamedplus'
vim.opt.relativenumber = true
vim.opt.number = true          -- absolute number on current line
vim.opt.smartcase = true
vim.opt.ignorecase = true      -- needed for smartcase to work
vim.opt.hlsearch = true
vim.opt.autowrite = true
vim.opt.autoread = true
vim.opt.scrolloff = 8          -- keep 8 lines above/below cursor
vim.opt.signcolumn = 'yes'     -- always show gutter (for LSP/git signs)
vim.opt.expandtab = true       -- spaces instead of tabs
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.wrap = false           -- no line wrapping
vim.opt.termguicolors = true   -- full color support
vim.opt.autochdir = true

-- keymaps
vim.g.mapleader = ' '
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

vim.pack.add({'https://github.com/folke/tokyonight.nvim'})
vim.cmd('colorscheme tokyonight-night')

vim.pack.add({
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
})

require('telescope').setup({})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

vim.pack.add({
    'https://github.com/nvim-tree/nvim-web-devicons',
    'https://github.com/nvim-lualine/lualine.nvim'
})
require('lualine').setup()

vim.pack.add({'https://github.com/nvim-treesitter/nvim-treesitter'})
require('nvim-treesitter').install({
    'javascript',
    'python',
    'php',
    'html',
    'css',
    'c',
    'cpp',
    'java',
    'lua'
})

vim.lsp.enable('clangd')        -- c, c++
vim.lsp.enable('pyright')       -- python
vim.lsp.enable('intelephense')  -- php
vim.lsp.enable('ts_ls')  

vim.lsp.config('clangd', {
    cmd = { 'clangd' },
    filetypes = { 'c', 'cpp' },
    root_markers = { 'compile_commands.json', '.git' }
})

vim.lsp.config('pyright', {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', '.git' }
})

vim.lsp.config('intelephense', {
    cmd = { 'intelephense', '--stdio' },
    filetypes = { 'php' },
    root_markers = { 'composer.json', '.git' }
})

vim.lsp.config('ts_ls', {
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = { 'javascript', 'typescript' },
    root_markers = { 'package.json', '.git' }
})

vim.diagnostic.config({
    float = { border = 'rounded' },
})

vim.api.nvim_create_autocmd('CursorHold', {
    callback = function()
        vim.diagnostic.open_float()
    end
})

vim.opt.updatetime = 500

vim.pack.add({'https://github.com/lewis6991/gitsigns.nvim'})
require('gitsigns').setup()

vim.api.nvim_set_hl(0, 'GitSignsAdd', { fg = '#98c379' })
vim.api.nvim_set_hl(0, 'GitSignsChange', { fg = '#ffff00' })
vim.api.nvim_set_hl(0, 'GitSignsDelete', { fg = '#ff0000' })

vim.pack.add({
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/NeogitOrg/neogit'
})
require('neogit').setup()
vim.keymap.set('n', '<leader>g', ':Neogit<CR>')

vim.pack.add({'https://github.com/stevearc/oil.nvim'})
require('oil').setup({
    view_options = {
        show_hidden = true,
    }
})
vim.keymap.set('n', '<leader>e', ':Oil<CR>')

vim.api.nvim_create_autocmd('BufEnter', {
  pattern = 'oil://*',
  callback = function()
    require('oil.actions').cd.callback()
  end,
})

vim.pack.add({'https://github.com/lukas-reineke/indent-blankline.nvim.git'})
require('ibl').setup()

vim.pack.add({ 
    'https://github.com/rafamadriz/friendly-snippets.git',
    'https://github.com/saghen/blink.cmp.git' 
})

require('blink.cmp').setup( {
    keymap = {
        preset = 'super-tab',
        ['<CR>'] = { 'accept', 'fallback' },
    },
})
