"syntax on
set term=ansi
set fileencoding=utf-8
color ron
set nocp
set hlsearch
"set ru
set list
set listchars=tab:>-,trail:-

set tabstop=4
"set softtabstop=4
"set shiftwidth=4
"set expandtab
"自动缩进
set autoindent
"显示行号：
set number
"set nu
"为方便复制，用<F2>开启/关闭行号显示:
"nnoremap <F2> :set nonumber!<CR>:set foldcolumn=0<CR>

"显示当前的行号列号：
"set ruler
"在状态栏显示正在输入的命令
set showcmd

"光标回到上次退出的位置
au BufReadPost * if line("'\"") > 0 | if line("'\"") <= line("$") | exe("norm '\"") | else | exe "norm $" | endif | endif

"自动检测文件类型并加载相应的设置
filetype plugin indent on
"Python文件中用空格代替Tab，且缩进应为四个空格
autocmd FileType c setlocal et sta sw=4 sts=4
autocmd FileType sh setlocal et sta sw=4 sts=4
autocmd FileType lua setlocal et sta sw=4 sts=4
autocmd FileType python setlocal et sta sw=4 sts=4
