" description: search workspace symbols

let s:prompt = 'Coc Symbols> '

function! coc_skim#symbols#skim_run(...) abort
  if !has('nvim')
    " get_workspace_symbols.py only supports nvim, PR are welcome
    call coc_skim#common#echom_error('symbols are only supported with neovim')
    return
  endif

  call coc_skim#common#log_function_call(expand('<sfile>'), a:000)
  let python3 = get(g:, 'python3_host_prog', 'python3')
  if !executable(python3)
    call coc_skim#common#echom_error(string(python3) . ' is not executable.')
    call coc_skim#common#echom_error('You need to set g:python3_host_prog.')
    return
  endif

  if !CocHasProvider('workspaceSymbols')
    call coc_skim#common#echom_info('Workspace symbols provider not found for current document')
    return
  endif
  let ws_symbols_opts = []
  let kind_idx = index(a:000, '--kind')
  if kind_idx >= 0
    if len(a:000) < kind_idx+2
      call coc_skim#common#echom_error('Missing kind argument')
      return
    elseif index(g:coc_skim#common#kinds, a:000[kind_idx+1]) < 0
      call coc_skim#common#echom_error('Kind ' . a:000[kind_idx+1] . ' does not exist')
      return
    endif
    let ws_symbols_opts += a:000[l:kind_idx : l:kind_idx+1]
  endif
  let expect_keys = coc_skim#common#get_default_file_expect_keys()
  let command_fmt = python3 . ' ' . g:coc_skim_plugin_dir . '/script/get_workspace_symbols.py %s %s %s %s'
  let initial_command = printf(command_fmt, join(ws_symbols_opts), v:servername, bufnr(), "''")
  let reload_command = printf(command_fmt, join(ws_symbols_opts), v:servername, bufnr(), '{q}')
  let opts = {
        \ 'source': initial_command,
        \ 'sink*': function('s:symbol_handler'),
        \ 'options': ['--multi','--expect='.expect_keys, '--bind', 'change:reload:'.reload_command,
        \ '--ansi', '--prompt=' . s:prompt] + g:coc_skim_opts,
        \ }
  call coc_skim#common#skim_run_with_preview(opts, {'placeholder': '{-1}'})
  call s:syntax()
endfunction

function! s:syntax() abort
  if has('syntax') && exists('g:syntax_on')
    syntax case ignore
    " apply syntax on everything but prompt
    exec 'syntax match CocSkim_SymbolsHeader /^\(\(\s*' . s:prompt . '\?.*\)\@!.\)*$/'
    syntax match CocSkim_SymbolsSymbol /\v^>\?\s*\S\+/ contained containedin=CocSkim_SymbolsHeader
    syntax match CocSkim_SymbolsType /\v\s\[.*\]/ contained containedin=CocSkim_SymbolsHeader
    syntax match CocSkim_SymbolsFile /\s\S*:\d\+:\d\+$/ contained containedin=CocSkim_SymbolsHeader
    syntax match CocSkim_SymbolsLine /:\d\+/ contained containedin=CocSkim_SymbolsFile
    syntax match CocSkim_SymbolsColumn /:\d\+$/ contained containedin=CocSkim_SymbolsFile
    highlight default link CocSkim_SymbolsSymbol Normal
    highlight default link CocSkim_SymbolsType Typedef
    highlight default link CocSkim_SymbolsFile Comment
    highlight default link CocSkim_SymbolsLine Ignore
    highlight default link CocSkim_SymbolsColumn Ignore
  endif
endfunction

function! s:symbol_handler(sym) abort
  let parsed_dict_list = s:parse_symbol(a:sym[1:])
  call coc_skim#common#process_file_action(a:sym[0], parsed_dict_list)
endfunction

function! s:parse_symbol(sym) abort
  let parsed_dict_list = []
  for str in a:sym
    let parsed_dict = {}
    let match = matchlist(str, '^\(.* \[[^[]*\]\) \(.*\):\(\d\+\):\(\d\+\)')[1:4]
    if empty(match) || empty(l:match[0])
      return
    endif
    let parsed_dict['text'] = match[0]
    let parsed_dict['filename'] = match[1]
    let parsed_dict['lnum'] = match[2]
    let parsed_dict['col'] = match[3]
    let parsed_dict_list += [parsed_dict]
  endfor
  return parsed_dict_list
endfunction
