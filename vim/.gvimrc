
" 日本語フォントを全角分のスペースにする
set ambiwidth=double

" 背景を透明にする
if executable("vimtweak64.dll")
    autocmd guienter * call libcallnr("vimtweak64","SetAlpha",221)
endif

colorscheme darkblue

" 最初に追加
gui

" ダークモードのタイトルバー
set guioptions+=d

" UIを消す
set guioptions-=m " remove menu bar
set guioptions-=T " remove tool bar
set guioptions-=r " remove right-hand scroll bar
set guioptions-=L " remove left-hand scroll bar
