setlocal foldexpr=folding#foldExpr(v:lnum)
setlocal foldtext=folding#foldText()
setlocal foldmethod=expr
call folding#set_fold_mappings()

setlocal fillchars=fold:\                                   " space character.
" Specify typical vimdoc comment chars
setlocal comments=s:\"\",m:\",e:\",:\"


" junegunn/vader.vim integration
if exists(':Vader')
endif

" junegunn/limelight.vim integration
if exists(':Limelight')
  " FIXME: It would be nice to include an (optional) vimdoc header as well
  let b:limelight_bop = '^\s*function'
  let b:limelight_eop = '^\s*endfunction'
endif



"" Execute the whole current buffer.
nnoremap <buffer> go :call vimscript#run([0, line('$')])<cr>
"" Execute the visually selected lines.
vnoremap <buffer> go :call vimscript#run()<cr>
