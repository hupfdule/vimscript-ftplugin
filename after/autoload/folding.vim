""
" Foldexpression for vimscript.
"
" This foldexpression folds
"  - functions
"  - foldmarkers (with and without explicit level)
"  - vimdoc
"
" vimdoc is always 2 levels deeper than its preceding lines to have it
" lower priority than the following function definition. That means if a
" function definition has fold level 2, the corresponding vimdoc has fold
" level 3.
function! folding#foldExpr(lnum) abort
  " Fold vimdoc
  if getline(a:lnum) =~# '^\s*""'
        \ && getline(a:lnum + 1) =~# '^\s*"'
    return 'a2'
  endif

  " The last line of a vimdoc ends the fold
  if getline(a:lnum) =~# '^\s*"'
        \ && getline(a:lnum + 1) !~# '^\s*"'
        \ && s:is_vimdoc(a:lnum)
    return 's2'
  endif

  " The first line of a functions content is the start of a level 1 fold
  " But avoid folding empty functions
  if getline(a:lnum - 1) =~# '^\s*function[! ]'
        \ && getline(a:lnum) !~# '^\s*endfunction'
    return 'a1'
  endif

  " The end of function is the end of the level 1 fold
  if getline(a:lnum) =~# '^\s*endfunction'
    return 's1'
  endif

  " Fold markers are also recognized
  let l:foldmarkers = split(&foldmarker, ',')
  if type(l:foldmarkers) == v:t_list && len(l:foldmarkers) == 2
    let l:line = getline(a:lnum)
    let l:openfoldmatch = matchlist(l:line, '\({{{\)\(\d\+\)\?')
    if !empty(l:openfoldmatch)
      if !empty(l:openfoldmatch[2])
        return '>' . l:openfoldmatch[2]
      else
        return 'a1'
      endif
    endif

    let l:closefoldmatch = matchlist(l:line, '\(}}}\)\(\d\+\)\?')
    if !empty(l:closefoldmatch)
      if !empty(l:closefoldmatch[2])
        return '<' . l:closefoldmatch[2]
      else
        return 's1'
      endif
    endif
  endif

  return '='
endfunction


""
" Foldtext expression for vimscript.
"
" For vimdoc the first non-empty line is displayed. […] is appended to it
" to indicate the folded text
"
" All other folds use the default foldtext() function.
function! folding#foldText() abort
  let l:fold_line = getline(v:foldstart)
  let l:folded_lines = v:foldend - v:foldstart
  " if the foldstart contains only the vimdoc starttags, display the next line
  if l:fold_line =~# '^\s*""\s*$'
    return getline(v:foldstart + 1) . (l:folded_lines > 1 ? ' […]' : '')
  " otherwise display the vimdocs first line
  elseif l:fold_line =~# '^\s*""'
    return l:fold_line . (l:folded_lines > 0 ? ' […]' : '')
    "return substitute(l:fold_line, '^\s*""\s*', '', '')
  endif

  " in all other cases fall back to vims default
  return foldtext()
endfunction


""
" Check whether line {lnum} is part of a vimdoc.
"
" It is considered part of a vimdoc if it is part of a comment block
" (multiple adjacent lines that all start with a quote mark) and one of the
" preceding lines in that comment block starts with 2 quote marks.
function! s:is_vimdoc(lnum) abort
  let l:lnum = a:lnum
  while l:lnum > 0
    let l:line = getline(l:lnum)
    if l:line =~# '^\s*""'
      return v:true
    elseif l:line !~# '^\s*"'
      return v:false
    endif

    let l:lnum -= 1
  endwhile

  return v:false
endfunction
