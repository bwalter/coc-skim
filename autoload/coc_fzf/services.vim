" description: registered services of coc.nvim

let s:prompt = 'Coc Services> '

function! coc_skim#services#skim_run(...) abort
  call coc_skim#common#log_function_call(expand('<sfile>'), a:000)
  let first_call = a:0 ? a:1 : 1
  let serv = CocAction('services')
  if !empty(serv)
    let expect_keys = coc_skim#common#get_default_file_expect_keys()
    let opts = {
          \ 'source': s:get_services(serv),
          \ 'sink*': function('s:service_handler'),
          \ 'options': ['--multi','--expect='.expect_keys,
          \ '--ansi', '--prompt=' . s:prompt] + g:coc_skim_opts,
          \ }
    call skim#run(skim#wrap(opts))
    call coc_skim#common#remap_enter_to_save_skim_selector()
    call s:syntax()
    if (!first_call)
      call feedkeys('i')
      call coc_skim#common#skim_selector_restore()
    endif
  else
    call coc_skim#common#echom_info('services list is empty')
  endif
endfunction

function! s:format_coc_service(item) abort
  " state id [state] languages
  let state = ' '
  if a:item.state == 'running'
    let state = '*'
  endif
  let languages = join(a:item.languageIds, ', ')
  return state . ' ' . a:item.id . ' [' . a:item.state . '] '. l:languages
endfunction

function! s:get_services(serv) abort
  return map(a:serv, 's:format_coc_service(v:val)')
endfunction

function! s:syntax() abort
  if has('syntax') && exists('g:syntax_on')
    syntax case ignore
    " apply syntax on everything but prompt
    exec 'syntax match CocSkim_ExtensionHeader /^\(\(\s*' . s:prompt . '\?.*\)\@!.\)*$/'
    syntax match CocSkim_ServiceStar /\v^\>?\s+\*/ contained containedin=CocSkim_ExtensionHeader
    syntax match CocSkim_ServiceName /\v%4c[^[]*(\[)@=/ contained containedin=CocSkim_ExtensionHeader
    syntax match CocSkim_ServiceState /\v\[[^[\]]*\]/ contained containedin=CocSkim_ExtensionHeader
    syntax match CocSkim_ServiceLanguages /\v(\])@<=.*$/ contained containedin=CocSkim_ExtensionHeader
    highlight default link CocSkim_ServiceStar Special
    highlight default link CocSkim_ServiceName Type
    highlight default link CocSkim_ServiceState Statement
    highlight default link CocSkim_ServiceLanguages Comment
  endif
endfunction

function! s:service_handler(ext) abort
  let parsed = s:parse_service(a:ext[1:])
  if type(parsed) == v:t_dict
    silent call CocAction('toggleService', parsed.id)
    call coc_skim#services#skim_run(0)
  endif
endfunction

function! s:parse_service(ext) abort
  let match = matchlist(a:ext, '^\(\*\?\)\s*\(\S*\)\s\[\(\S*\)\]\s\(\S*\)')[1:4]
  if empty(match) || empty(l:match[1])
    return
  endif
  return ({'state' : match[2], 'id' : l:match[1], 'languages' : l:match[3]})
endfunction
