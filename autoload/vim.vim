""
" Print the result of the current 'foldexpr' applied to the current buffer.
"
" This prints the line number, the result of calling 'foldexpr' and the
" actual content of each line.
"
" If errors occur when applying the 'foldexpr' these errors will get
" displayed.
function! vim#debug_foldexpr() abort
  if &foldexpr !~# '.\+(v:lnum)$'
    echohl ErrorMsg | echo 'current foldexpr doesn\'t seems to be a function: ' . &foldexpr | echohl Normal
    return
  endif

  let l:foldfun=substitute(&foldexpr, '(v:lnum)', '', '')
  let l:fold_levels = map(range(1, line('$')), 'v:val . "\t" . ' . l:foldfun . '(v:val) . "\t" . getline(v:val)')
  for l:fl in l:fold_levels
    echo l:fl
  endfor
endfunction

