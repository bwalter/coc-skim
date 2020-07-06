" description: code actions of selected range

let s:prompt = 'Coc Actions> '

function! coc_skim#actions#skim_run() abort
  call coc_skim#common#log_function_call(expand('<sfile>'), a:000)
  let g:coc_skim_actions = CocAction('codeActions')
  if !empty(g:coc_skim_actions)
    let expect_keys = coc_skim#common#get_default_file_expect_keys()
    let opts = {
          \ 'source': s:get_actions(),
          \ 'sink*': function('s:action_handler'),
          \ 'options': ['--multi', '--expect='.expect_keys,
          \ '--ansi', '--prompt=' . s:prompt] + g:coc_skim_opts,
          \ }
    call skim#run(skim#wrap(opts))
    call s:syntax()
  else
    call coc_skim#common#echom_info('actions list is empty')
  endif
endfunction

function! s:format_coc_action(item) abort
  " title [clientId] (kind)
  let str = a:item.title . ' [' . a:item.clientId . ']'
  if exists('a:item.kind')
    let str .=  ' (' . a:item.kind . ')'
  endif
  return str
endfunction

function! s:get_actions() abort
  let entries = map(copy(g:coc_skim_actions), 's:format_coc_action(v:val)')
  let index = 0
  while index < len(entries)
     let entries[index] .= ' ' . index
     let index = index + 1
  endwhile
  return entries
endfunction

function! s:syntax() abort
  if has('syntax') && exists('g:syntax_on')
    syntax case ignore
    " apply syntax on everything but prompt
    exec 'syntax match CocSkim_ActionHeader /^\(\(\s*' . s:prompt . '\?.*\)\@!.\)*$/'
    syntax match CocSkim_ActionKind /([^)]\+)/ contained containedin=CocSkim_ActionHeader
    syntax match CocSkim_ActionId /\[[^\]]\+\]/ contained containedin=CocSkim_ActionHeader
    syntax match CocSkim_ActionTitle /^>\?\s*[^\[]\+/ contained  containedin=CocSkim_ActionHeader
    syntax match CocSkim_ActionIndex /\d\+$/ contained containedin=CocSkim_ActionHeader
    highlight default link CocSkim_ActionIndex Ignore
    highlight default link CocSkim_ActionTitle Normal
    highlight default link CocSkim_ActionId Type
    highlight default link CocSkim_ActionKind Comment
  endif
endfunction

function! s:action_handler(act) abort
  let cmd = coc_skim#common#get_action_from_key(a:act[0])
  if !empty(cmd) && stridx('edit', cmd) < 0
    execute 'silent' cmd
  endif
  let index = s:parse_action(a:act[1:])
  if type(index) == v:t_number
    call CocAction('doCodeAction', g:coc_skim_actions[index])
  endif
endfunction

function! s:parse_action(act) abort
  let match = matchlist(a:act, '^.* \(\d\+\)$')[1]
  if empty(match)
    return
  endif
  return str2nr(match)
endfunction
