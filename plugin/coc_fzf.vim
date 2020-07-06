" coc-skim - use SKIM for CocList sources
" Maintainer:   Antoine Madec <aja.madec@gmail.com>
" Version:      0.1

if exists('g:loaded_coc_skim')
  finish
else
  let g:loaded_coc_skim = 'yes'
endif

if !exists("g:coc_skim_preview_toggle_key")
    let g:coc_skim_preview_toggle_key = '?'
endif
if !exists("g:coc_skim_preview")
    let g:coc_skim_preview = 'up:50%'
endif
if !exists("g:coc_skim_opts")
    let g:coc_skim_opts = ['--layout=reverse-list']
endif

let g:coc_skim_plugin_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let g:coc_skim_plugin_dir = fnamemodify(g:coc_skim_plugin_dir, ':h')

command! -nargs=* -complete=custom,coc_skim#common#list_options CocSkimList call coc_skim#lists#skim_run(<f-args>)
command CocSkimListResume call coc_skim#common#call_last_logged_function()
