-- Vim Plug
vim.cmd([[
" Download Plug if needed
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall
endif

" Begin Plug block
call plug#begin('~/.config/nvim/plugged')
Plug 'sainnhe/edge'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-fugitive'
Plug 'let-def/vimbufsync'
Plug 'vim-scripts/a.vim'
Plug 'bohlender/vim-smt2'
Plug 'ARM9/arm-syntax-vim'
Plug 'jparise/vim-graphql'
Plug 'rhysd/rust-doc.vim'
Plug 'CraneStation/cranelift.vim'
Plug 'neomake/neomake'
Plug 'whonore/Coqtail'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-compe'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" Plug 'nvim-treesitter/playground'
Plug 'rhysd/vim-llvm'
" dependencies
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
" telescope
Plug 'nvim-telescope/telescope.nvim'
Plug 'ziglang/zig.vim'
Plug 'BeneCollyridam/futhark-vim'
Plug 'simrat39/rust-tools.nvim'
call plug#end()
]])

-- General config
vim.cmd([[
set number
set hidden
set incsearch
set hlsearch
set autoread
set wrap
set ruler
set ai
set si
set smarttab
set expandtab
set notimeout
set tabstop=2
set shiftwidth=2
set laststatus=2
set cmdheight=2
set backupdir=/tmp
set mouse=a
set ttimeoutlen=2
set noerrorbells visualbell t_vb= "dont beep

" Use F12 to toggle paste mode
set pastetoggle=<F12>

" Map to avoid shift
map ; :
map ' :

" Use space as leader
map <Space> <Leader>

" Strip trailing whitespace on write
fun! StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
autocmd BufWritePre * :call StripTrailingWhitespaces()

" Fix backspace
set backspace=eol,start,indent
set whichwrap+=<,>,h,l
]])



-- Filetype
vim.cmd([[
filetype plugin on
filetype indent on
syntax enable

" Expand tabs
autocmd FileType ocaml set tabstop=2|set shiftwidth=2|set expandtab

" Use tabs in Makefiles
autocmd FileType make setlocal tabstop=4|set shiftwidth=4|set noexpandtab

" Use 4 spaces in some languages
autocmd FileType python set tabstop=4|set shiftwidth=4|set expandtab
autocmd FileType rust set tabstop=4|set shiftwidth=4|set expandtab
autocmd FileType javascript set tabstop=4|set shiftwidth=4|set expandtab

au BufRead,BufNewFile *.why,*.mlw set filetype=why3
let why3_path=substitute(system('why3 --print-datadir'), '\n', '', 'g')

if why3_path
execute 'set rtp+=' . why3_path  . '/vim'
endif

au BufRead,BufNewFile *.fountain set filetype=fountain
autocmd BufNewFile,BufRead *.md set ft=markdown spell
autocmd BufNewFile,BufRead *.fountain set ft=fountain spell

autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
]])

-- Colorscheme
vim.cmd([[
function! Edge_custom() abort
  let l:palette = edge#get_palette('default')
  highlight! link TSSymbol Blue
  highlight! link TSConstant Blue
  highlight! link TSParameter White
  highlight! link TSParameterReference White
  highlight! link TSVariable White
  highlight! link TSField White
  highlight! link TSProperty White
  highlight! link TSNamespace White
endfunction

augroup EdgeCustom
  autocmd!
  autocmd ColorScheme edge call Edge_custom()
augroup END


let g:edge_disable_italic_comment = 1
let g:edge_diagnostic_line_highlight = 1
let g:edge_diagnostic_virtual_text = 'colored'
colorscheme edge
]])

vim.g['lightline'] = {
  active = {
    left = {{'mode', 'paste'}, {'gitbranch', 'readonly', 'absolutepath', 'modified'}}
  },
  component_expand = {
    buffers = 'lightline#bufferline#buffers'
  },
  component_type = {
    buffers = 'tabsel'
  },
  component_function = {
    gitbranch = 'FugitiveHead'
  }
}

-- Nerdtree
vim.cmd([[
" NerdTree
autocmd StdinReadPre * let std_in=1
if argc() == 0 && !exists("std_in")
    autocmd VimEnter * NERDTree
endif
map <C-f> :NERDTreeToggle<CR>
nmap <F8> :TagbarToggle<CR>
]])

-- Compe
require'compe'.setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 2;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = true;

  source = {
    path = true;
    nvim_lsp = true;
  };
}

-- Compe key bindings
vim.cmd([[
set completeopt=menuone,noselect

inoremap <silent><expr> <C-Space> compe#complete()
inoremap <silent><expr> <CR>      compe#confirm('<CR>')
inoremap <silent><expr> <C-e>     compe#close('<C-e>')
inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })
]])

-- Telescope
vim.cmd([[
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
]])

-- Formatting
vim.cmd([[
autocmd BufWritePre * lua vim.lsp.buf.formatting_sync(nil, 750)
]])
vim.api.nvim_set_keymap("i", "<CR>", "compe#confirm({ 'keys': '<CR>', 'select': v:true })", { expr = true })

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  else
    -- If <S-Tab> is not working in your terminal, change it to <C-h>
    return t "<S-Tab>"
  end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

require'nvim-treesitter.configs'.setup {
  ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ignore_install = {  }, -- List of parsers to ignore installing
  highlight = {
    enable = true,  -- false will disable the whole extension
    disable = { },  -- list of language that will be disabled
  },
}
-- Language servers
local nvim_lsp = require('lspconfig')
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  buf_set_keymap('n', '<space>F', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

local servers = {
    'pylsp',
    --'rust_analyzer',
    'denols', --'tsserver',
    'ocamllsp',
    'clangd',
    'zls',
    'gopls',
    'hls',
    'bashls',
    'fstar'
}
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 250,
    }
  }
end

local nvim_lsp = require'lspconfig'

local opts = {
    tools = {
        autoSetHints = true,
        hover_with_actions = true,
        runnables = {
            use_telescope = true
        },
        inlay_hints = {
            show_parameter_hints = false,
            parameter_hints_prefix = "",
            other_hints_prefix = "",
        },
    },

    -- all the opts to send to nvim-lspconfig
    -- these override the defaults set by rust-tools.nvim
    -- see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer
    server = {
        -- on_attach is a callback called when the language server attachs to the buffer
        on_attach = on_attach,
        settings = {
            -- to enable rust-analyzer settings visit:
            -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
            ["rust-analyzer"] = {
                -- enable clippy on save
                checkOnSave = {
                    command = "clippy"
                },
            }
        }
    },
}

require('rust-tools').setup(opts)
