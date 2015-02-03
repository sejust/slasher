"syntax on
set term=ansi
set fileencoding=utf-8
color ron
set nocp
set hlsearch
"set ru

set tabstop=4
"set softtabstop=4
"set shiftwidth=4
"set expandtab
"自动缩进
set autoindent
"显示行号：
set number
"set nu

"显示当前的行号列号：
"set ruler
"在状态栏显示正在输入的命令
set showcmd

"自动检测文件类型并加载相应的设置
filetype plugin indent on
"Python文件中用空格代替Tab，且缩进应为四个空格
autocmd FileType c setlocal et sta sw=4 sts=4
autocmd FileType sh setlocal et sta sw=4 sts=4
autocmd FileType lua setlocal et sta sw=4 sts=4
autocmd FileType html setlocal et sta sw=4 sts=4
autocmd FileType python setlocal et sta sw=4 sts=4

"光标回到上次退出的位置
au BufReadPost * if line("'\"") > 0 | if line("'\"") <= line("$") | exe("norm '\"") | else | exe "norm $" | endif | endif

"显示TAB键和行尾空格
set list
set listchars=tab:>-,trail:-

"映射 "\p" 为在单词两端加圆括号, 而映射 "\c" 为加花括号
map \p i(<Esc>ea)<Esc>
map \l i[<Esc>ea]<Esc>
map \c i{<Esc>ea}<Esc>

"Vim 通常会对长行自动回绕，以便你可以看见所有的文字。但有时最好还是能让文字在一
"行中显示完。这样，你需要左右移动才能看到一整行。以下命令可以关闭行的回绕
"set nowrap

function! VCpy() range
  execute ":'<,'> s/\\v^(.)/#\\1/g"
endfunction
map <C-I> :call VCpy()<CR>

function! VUCpy() range
  execute ":'<,'> s/\\v^( *)(#*)/\\1/g"
endfunction
map <C-O> :call VUCpy()<CR>
