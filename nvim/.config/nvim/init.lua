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
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldenable = false
vim.opt.foldlevelstart = 99
vim.opt.foldtext = ''
vim.opt.cursorline = true
vim.opt.cursorlineopt = 'number'

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

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'qf',
    callback = function()
        vim.cmd('wincmd L')
    end,
})

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

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function()
        vim.keymap.set('n', 'gd',  vim.lsp.buf.definition,  { buf = 0 })
        vim.keymap.set('n', 'gr',  vim.lsp.buf.references,  { buf = 0 })
        vim.keymap.set('n', 'grn', vim.lsp.buf.rename,      { buf = 0 })
    end,
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
    'https://github.com/sindrets/diffview.nvim.git',
    'https://github.com/NeogitOrg/neogit'
})
require('neogit').setup()
vim.keymap.set('n', '<leader>g', ':Neogit<CR>')

vim.api.nvim_set_hl(0, 'NeogitHunkHeader',          { fg = '#a9b1d6', bg = '#3d4a7a', bold = true })
vim.api.nvim_set_hl(0, 'NeogitHunkHeaderHighlight', { fg = '#c0caf5', bg = '#4a58a0', bold = true })
vim.api.nvim_set_hl(0, 'NeogitDiffAdd',          { fg = '#a8d870', bg = '#264020' })
vim.api.nvim_set_hl(0, 'NeogitDiffAddHighlight', { fg = '#a8cc6a', bg = '#2e4d25', bold = true })
vim.api.nvim_set_hl(0, 'NeogitDiffDelete',          { fg = '#ff4f4f', bg = '#591a1a' })
vim.api.nvim_set_hl(0, 'NeogitDiffDeleteHighlight', { fg = '#ff2020', bg = '#681c1c', bold = true })

vim.pack.add({'https://github.com/stevearc/oil.nvim'})
require('oil').setup({
    view_options = {
        show_hidden = true,
    }
})
vim.keymap.set('n', '<leader>e', ':Oil<CR>')

vim.pack.add({'https://github.com/lukas-reineke/indent-blankline.nvim.git'})
require('ibl').setup({
    scope = {
        enabled = false,
    },
})

vim.pack.add({
    "https://github.com/rafamadriz/friendly-snippets.git",
    { src = "https://github.com/saghen/blink.cmp.git", version = vim.version.range("1.*") },
})

require('blink.cmp').setup({
    keymap = {
        preset = 'super-tab',
        ['<CR>'] = { 'accept', 'fallback' },
    },

    cmdline = {
        keymap = { preset = 'inherit' },
        completion = { 
            menu = {  
                auto_show = function()
                    if vim.fn.getcmdtype() ~= ':' then
                        return false
                    end

                    local cmd = vim.fn.getcmdline()

                    if cmd == 'w' or cmd == 'q' or cmd == 'restart' then
                        return false
                    end

                    return true
                end         
            },
        },
    },
})

vim.keymap.set('c', '<M-BS>', '<C-w>')

vim.pack.add({
  'https://github.com/nvim-treesitter/nvim-treesitter-context'
})

require('treesitter-context').setup({
    mode = 'cursor',
    max_lines = 5,
    trim_scope = 'inner',
})

vim.api.nvim_set_hl(0, 'DiffviewDiffDelete', {
    bg = '#591a1a'
})

vim.api.nvim_set_hl(0, 'DiffviewDiffDeleteDim', {
    bg = '#681c1c'
})

vim.api.nvim_set_hl(0, 'DiffviewDiffChange', {
    bg = '#1f3328'
})

vim.api.nvim_set_hl(0, 'DiffviewDiffAdd', {
    bg = '#264020'
})

vim.api.nvim_set_hl(0, 'DiffviewDiffText', {
    bg = '#2e4d25',
    bold = true
})

if vim.g.neovide then
    vim.g.neovide_cursor_animation_length = 0
    vim.g.neovide_cursor_trail_size = 0
end
