function coc_skim#common#coc_has_extension(ext) abort
  return len(filter(CocAction('extensionStats'), {key, val -> val.id == a:ext}))
endfunction

function! coc_skim#common#remap_enter_to_save_skim_selector() abort
  tnoremap <silent> <buffer> <CR> <C-\><C-n>:call coc_skim#common#skim_selector_save()<CR>i<CR>
endfunction

function! coc_skim#common#skim_selector_save() abort
  let cmd = 'g/^>/#'
  let t:skim_selector_line_nb = split(s:redir_exec(cmd))[0]
endfunction

function! coc_skim#common#skim_selector_restore() abort
  " TODO: normal gg
  if exists('t:skim_selector_line_nb')
    let c = 1
    while c < t:skim_selector_line_nb
      call feedkeys("\<Down>")
      let c += 1
    endwhile
  endif
endfunction

" [function_name, args_string]
let s:last_func_call = []

function! coc_skim#common#log_function_call(sfile, args_list) abort
  let func_name = substitute(a:sfile, '.*\(\.\.\|\s\)', '', '')
  let s:last_func_call = [func_name, a:args_list]
endfunction

function! coc_skim#common#call_last_logged_function() abort
  if !empty(s:last_func_call)
    call call(s:last_func_call[0], s:last_func_call[1])
  endif
endfunction

function! s:redir_exec(command) abort
    redir =>output
    silent exec a:command
    redir END
    return output
endfunction

function coc_skim#common#get_list_names(...) abort
  let opt = a:0 ? ' ' . a:1 . ' ' : ' '
  return systemlist(g:coc_skim_plugin_dir . '/script/get_lists.sh' . opt . join(coc#rpc#request('listNames', [])))
endfunction

let coc_skim#common#kinds = ['File', 'Module', 'Namespace', 'Package', 'Class', 'Method',
      \ 'Property', 'Field', 'Constructor', 'Enum', 'Interface', 'Function',
      \ 'Variable', 'Constant', 'String', 'Number', 'Boolean', 'Array',
      \ 'Object', 'Key', 'Null', 'EnumMember', 'Struct', 'Event', 'Operator',
      \ 'TypeParameter']

function coc_skim#common#list_options(ArgLead, CmdLine, CursorPos) abort
  let diagnostics_opts = ['--current-buf']
  let symbols_opts = ['--kind']
  let CmdLineList = split(a:CmdLine)
  let source = len(l:CmdLineList) >= 2 ? l:CmdLineList[1] : ''
  if source == 'diagnostics'
    return join(diagnostics_opts, "\n")
  elseif source == 'symbols'
    if index(CmdLineList[-2:-1], '--kind') >= 0
      return join(g:coc_skim#common#kinds, "\n")
    endif
    return join(symbols_opts, "\n")
  endif
  let sources_list = coc_skim#common#get_list_names('--no-description')
  if index(sources_list, source) < 0
    return join(sources_list, "\n")
  endif
  return ''
endfunction

function coc_skim#common#echom_error(msg) abort
  exe "echohl Error | echom '[coc-skim] " . a:msg . "' | echohl None"
endfunction

function coc_skim#common#echom_info(msg) abort
  exe "echohl MoreMsg | echom '[coc-skim] " . a:msg . "' | echohl None"
endfunction

function coc_skim#common#with_preview(opts, ...) abort
  let custom_preview_command = a:0 ? a:1 : ''
  let wrapped_opts = {}

  if g:coc_skim_preview_available
    let preview_window = g:coc_skim_preview
    if empty(preview_window)
      let preview_window = get(g:, 'skim_preview_window', &columns >= 120 ? 'right': '')
    endif
    if len(preview_window)
      let wrapped_opts = skim#vim#with_preview(a:opts, preview_window, g:coc_skim_preview_toggle_key)
      if strlen(custom_preview_command)
        let preview_command_index = index(wrapped_opts.options, '--preview') + 1
        let wrapped_opts.options[preview_command_index] = custom_preview_command
      endif
    endif
  endif

  return wrapped_opts
endfunction

function coc_skim#common#skim_run_with_preview(opts, ...) abort
  let preview_opts = a:0 ? a:1 : {}
  let extra = coc_skim#common#with_preview(preview_opts)
  let eopts  = has_key(extra, 'options') ? remove(extra, 'options') : ''
  let merged = extend(copy(a:opts), extra)
  call coc_skim#common_skim_vim#merge_opts(merged, eopts)
  call skim#run(skim#wrap(merged))
endfunction

let s:default_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit'}

function coc_skim#common#get_default_file_expect_keys() abort
  return join(keys(get(g:, 'skim_action', s:default_action)), ',')
endfunction

function coc_skim#common#get_action_from_key(key) abort
  return get(get(g:, 'skim_action', s:default_action), a:key)
endfunction

function coc_skim#common#process_file_action(key, parsed_dict_list) abort
  if empty(a:parsed_dict_list)
    return
  endif

  let cmd = coc_skim#common#get_action_from_key(a:key)
  let first = a:parsed_dict_list[0]

  if !empty(cmd) && stridx('edit', cmd) < 0
    execute 'silent' cmd first["filename"]
  else
    execute 'buffer' bufnr(first["filename"], 1)
  endif
  if type(first) == v:t_dict
    mark '
    call cursor(first["lnum"], first["col"])
    normal! zz
  endif

  if len(a:parsed_dict_list) > 1
    call setqflist(a:parsed_dict_list)
    copen
    wincmd p
  endif

endfunction
