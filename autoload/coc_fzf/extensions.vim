" description: manage coc extensions

let s:prompt = 'Coc Extensions> '

function! coc_skim#extensions#skim_run(...) abort
  call coc_skim#common#log_function_call(expand('<sfile>'), a:000)
  let first_call = a:0 ? a:1 : 1
  let exts = CocAction('extensionStats')
  if !empty(exts)
    let expect_keys = coc_skim#common#get_default_file_expect_keys()
    let opts = {
          \ 'source': s:get_extensions(exts),
          \ 'sink*': function('s:extension_handler'),
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
    call coc_skim#common#echom_info('extensions list is empty')
  endif
endfunction

function! s:format_coc_extension(item) abort
  " state id version root
  let state = '+'
  if a:item.state == 'activated'
    let state = '*'
  elseif a:item.state == 'disabled'
    let state = '-'
  endif
  let local = a:.item.isLocal ? ' [RTP] ' : ' '
  return state . ' ' . a:item.id . local .  a:item.version . ' ' . a:item.root
endfunction

function! s:get_extensions(exts) abort
  let exts_activated = filter(copy(a:exts), {key, val -> val.state == 'activated'})
  let exts_loaded = filter(copy(a:exts), {key, val -> val.state == 'loaded'})
  let exts_disabled = filter(copy(a:exts), {key, val -> val.state == 'disabled'})
  let exts = extend(l:exts_activated, l:exts_loaded)
  let exts = extend(l:exts, l:exts_disabled)
  return map(exts, 's:format_coc_extension(v:val)')
endfunction

function! s:syntax() abort
  if has('syntax') && exists('g:syntax_on')
    syntax case ignore
    " apply syntax on everything but prompt
    exec 'syntax match CocSkim_ExtensionHeader /^\(\(\s*' . s:prompt . '\?.*\)\@!.\)*$/'
    syntax match CocSkim_ExtensionRoot /\v\s*\f+$/ contained containedin=CocSkim_ExtensionHeader
    syntax match CocSkim_ExtensionActivited /\v^\>?\s+\*/ contained containedin=CocSkim_ExtensionHeader
    syntax match CocSkim_ExtensionLoaded /\v^\>?\s+\+\s/ contained containedin=CocSkim_ExtensionHeader
    syntax match CocSkim_ExtensionDisabled /\v^\>?\s+-\s/ contained containedin=CocSkim_ExtensionHeader
    syntax match CocSkim_ExtensionName /\v%5c\S+/ contained containedin=CocSkim_ExtensionHeader
    syntax match CocSkim_ExtensionsLocal /\v\[RTP\]/ contained containedin=CocSkim_ExtensionHeader
    highlight default link CocSkim_ExtensionRoot Comment
    highlight default link CocSkim_ExtensionDisabled Comment
    highlight default link CocSkim_ExtensionActivited MoreMsg
    highlight default link CocSkim_ExtensionLoaded Normal
    highlight default link CocSkim_ExtensionName String
    highlight default link CocSkim_ExtensionsLocal MoreMsg
  endif
endfunction

function! s:extension_handler(ext) abort
  let parsed = s:parse_extension(a:ext[1:])
  if type(parsed) == v:t_dict
    if parsed.state == '*'
      silent call CocAction('deactivateExtension', parsed.id)
    elseif parsed.state == '+'
      silent call CocAction('activeExtension', parsed.id)
    endif
    call coc_skim#extensions#skim_run(0)
  endif
endfunction

function! s:parse_extension(ext) abort
  let match = matchlist(a:ext, '\v^(.)\s(\S*)\s(.*)')[1:4]
  if empty(match) || empty(l:match[0])
    return
  endif
  return ({'state' : match[0], 'id' : l:match[1], 'root' : l:match[2]})
endfunction
