""
" Execute the vimscript in some lines of the current buffer.
"
" If the optional [range] is given it must be a list with exactly two
" entries. The first being the first line to execute, the second being the
" last line to execute.
"
" If the optional [range] is /not/ given the whole buffer is sources.
" This requires writing the file first. A warning message is displayed if
" the current buffer is modified.
"
" FIXME:
" To allow sourcing a modified file without having to write it first, it
" needs to be written to a temporary file and that one is executed.
" That still doesn't work for autoload scripts as their function names need
" to match the file name. Therefore the temporary name should resemble the
" autoload name
function! vimscript#run(...) range abort
  if a:0 > 1
    throw 'VimscriptFT001: Only one optional parameter [range] is allowed, but ' . a:0 . ' were given: '
          \ . string(a:000)
  endif

  if a:0 ==# 1 && type(a:1) !=# v:t_list
    throw 'VimscriptFT002: Optional parameter [range] must be a list'
  endif

  if a:0 ==# 1 && len(a:1) !=# 2
    throw 'VimscriptFT003: Optional parameter [range] must have exactly 2 elements, but ' . len(a:1) . ' were given: '
          \ . string(a:1)
  endif

  if a:0 ==# 1
    let l:lines = getline(a:1[0], a:1[1])
    call execute(s:preprocess(l:lines), '')
  else
    if &modified
      echohl WarningMsg | echo "Current buffer is modified! :write it to execute the current content." | echohl None
    endif
    source %
  endif
endfunction


""
" Preprocess VimScript to allow :h line-continuation and :h line-continuation-comment
"
" Workaround for line-continuations when executing vimscript via register.
" Taken from https://vi.stackexchange.com/a/25020/21417
"
" @param {script} a list with the lines of code to execute
function! s:preprocess(script)
    if stridx(&cpo, 'C') < 0
        let [l:curr, l:last] = [1, len(a:script) - 1]
        while l:curr <= l:last
            " match line-continuation or line-continuation-comment
            let l:cont = matchlist(a:script[l:curr], '\v^\s*(\\|"\\ )(.*)')
            if empty(l:cont)
                " skip over normal line
                let l:curr += 1
            else
                " join line-continuation
                if l:cont[1] ==# '\'
                    let a:script[l:curr - 1] .= l:cont[2]
                endif
                unlet a:script[l:curr]
                let l:last -= 1
            endif
        endwhile
    endif
    return a:script
endfunction

function! s:source(first, last) range
  let l:tmpfile = tempname()
  call writefile(get(a:first, a:last), l:tmpfile)
  execute "source " . l:tmpfile
  call delete(l:tmpfile)
endfunction
