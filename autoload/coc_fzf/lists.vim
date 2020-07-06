" description: coc-skim available list sources

let s:prompt = 'Coc Lists> '

function! coc_skim#lists#skim_run(...) abort
  if a:0
    " execute one source/list
    let src = a:000[0]
    let src_opts = a:000[1:]
    let sources_list = coc_skim#common#get_list_names('--no-description')
    if index(sources_list, src) < 0
      call coc_skim#common#echom_error('List ' . src . ' does not exist')
      return
    endif
    call call('coc_skim#' . src . '#skim_run', l:src_opts)
  else
    " prompt all available lists
    call coc_skim#common#log_function_call(expand('<sfile>'), a:000)
    let expect_keys = coc_skim#common#get_default_file_expect_keys()
    let opts = {
          \ 'source': coc_skim#common#get_list_names(),
          \ 'sink*': function('s:list_handler'),
          \ 'options': ['--multi','--expect='.expect_keys,
          \ '--ansi', '--prompt=' . s:prompt] + g:coc_skim_opts,
          \ }
    call skim#run(skim#wrap(opts))
    call s:syntax()
  endif
endfunction

function! s:syntax() abort
  if has('syntax') && exists('g:syntax_on')
    syntax case ignore
    " apply syntax on everything but prompt
    exec 'syntax match CocSkim_ListsHeader /^\(\(\s*' . s:prompt . '\?.*\)\@!.\)*$/'
    syntax match CocSkim_ListsDescription /\s.*$/ contained containedin=CocSkim_ListsHeader
    syntax match CocSkim_ListsList /^>\?\s*\S\+/ contained containedin=CocSkim_ListsHeader
    highlight default link CocSkim_ListsList Normal
    highlight default link CocSkim_ListsDescription Comment
  endif
endfunction

function! s:list_handler(list) abort
  let cmd = coc_skim#common#get_action_from_key(a:list[0])
  if !empty(cmd) && stridx('edit', cmd) < 0
    if stridx('edit', cmd) < 0
      execute 'silent' cmd
    endif
  endif
  let src = split(a:list[1])[0]
  if !empty(src)
    execute 'call coc_skim#' . src . '#skim_run()'
    if &ft == 'skim'
      call feedkeys('i')
    endif
  endif
endfunction
