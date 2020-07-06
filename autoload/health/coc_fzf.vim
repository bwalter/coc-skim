function s:check_ctags() abort
  call health#report_start('ctags (optional)')
  if executable('ctags')
    call health#report_ok('ctag found')
  else
    call health#report_warn("ctags not found, outline won't work if symbols are not supported",
          \ ['git clone https://github.com/universal-ctags/ctags.git',
          \ 'cd ctags',
          \ './autogen.sh',
          \ './configure',
          \ 'make',
          \ 'sudo make install'
          \ ])
  endif
endfunction

function s:check_skim_vim() abort
  call health#report_start('skim.vim (optional)')
  let got_skim_vim = 1
  try
    call skim#vim#with_preview()
  catch
    let got_skim_vim = 0
  endtry
  if got_skim_vim
    call health#report_ok('skim.vim found')
  else
    call health#report_warn("skim.vim not found. 'location' won't work, previews won't be available",
          \ ['Install the following vim plugin', "  Plug 'junegunn/skim.vim'"])
  endif
endfunction

function! health#coc_skim#check() abort
  call s:check_ctags()
  call s:check_skim_vim()
endfunction
