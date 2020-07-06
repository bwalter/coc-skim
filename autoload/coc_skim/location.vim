" description: show locations saved by g:coc_jump_locations variable

let s:prompt = 'Coc Location> '

function! coc_skim#location#skim_run() abort
  call coc_skim#common#log_function_call(expand('<sfile>'), a:000)
  " deepcopy() avoids g:coc_jump_locations corruption
  let locs = deepcopy(get(g:, 'coc_jump_locations', ''))
  if !empty(locs)
    let expect_keys = coc_skim#common#get_default_file_expect_keys()
    let opts = {
          \ 'source': s:get_location(locs),
          \ 'sink*': function('s:location_handler'),
          \ 'options': ['--multi','--expect='.expect_keys,
          \ '--ansi', '--prompt=' . s:prompt] + g:coc_skim_opts,
          \ }
    call coc_skim#common#skim_run_with_preview(opts)
    call s:syntax()
  else
    call coc_skim#common#echom_info('location list is empty')
  endif
endfunction

function! s:format_coc_location(item) abort
  " original is: 'filename' |'lnum' col 'col'| 'text'
  " coc skim  is: 'filename':'lnum':'col':'text'
  " reason: this format is needed for skim preview
  let cwd = getcwd()
  let filename = substitute(a:item.filename, l:cwd . "/", "", "")
  return filename . ':' . a:item.lnum . ':' . a:item.col . ':' . a:item.text
endfunction

function! s:relpath(filename)
    return s
endfunction

function! s:get_location(locs) abort
  let locs = a:locs
  return map(locs, 's:format_coc_location(v:val)')
endfunction

function! s:syntax() abort
  if has('syntax') && exists('g:syntax_on')
    syntax case ignore
    " apply syntax on everything but prompt
    exec 'syntax match CocSkim_JumplocationHeader /^\(\(\s*' . s:prompt . '\?.*\)\@!.\)*$/'
    syntax region CocSkim_JumplocationRegion start="^" end="[│╭╰]" keepend contains=CocSkim_JumplocationHeader
    syntax match CocSkim_JumplocationFile /^>\?\s*[^:││╭╰]\+/ contained containedin=CocSkim_JumplocationHeader
    syntax match CocSkim_JumplocationLineNumber /:\d\+:\d\+:/ contained containedin=CocSkim_JumplocationHeader
    highlight default link CocSkim_JumplocationFile Directory
    highlight default link CocSkim_JumplocationLineNumber LineNr
  endif
endfunction

function! s:location_handler(loc) abort
  let parsed_dict_list = s:parse_location(a:loc[1:])
  call coc_skim#common#process_file_action(a:loc[0], parsed_dict_list)
endfunction

function! s:parse_location(loc) abort
  let parsed_dict_list = []
  for str in a:loc
    let parsed_dict = {}
    let match = matchlist(str, '^\(\S\+\):\(\d\+\):\(\d\+\):\(.*\)')[1:4]
    if empty(match) || empty(l:match[0])
      return
    endif
    let parsed_dict['filename'] = match[0]
    let parsed_dict['lnum'] = match[1]
    let parsed_dict['col'] = match[2]
    let parsed_dict['text'] = match[3]
    let parsed_dict_list += [parsed_dict]
  endfor
  return parsed_dict_list
endfunction
