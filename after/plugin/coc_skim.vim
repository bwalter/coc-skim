" test other plugins availability

let g:coc_skim_preview_available = 1
try
  call skim#vim#with_preview()
catch
  let g:coc_skim_preview_available = 0
endtry

if g:coc_skim_preview_available
  augroup CocSkimLocation
    autocmd!
    let g:coc_enable_locationlist = 0
    autocmd User CocLocationsChange call coc_skim#location#skim_run()
  augroup END
endif
