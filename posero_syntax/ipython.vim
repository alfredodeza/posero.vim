" File:        ipython.vim
" Description: Syntax File for IPython terminal sessions
" Maintainer:  Alfredo Deza <alfredodeza AT gmail.com>
" License:     MIT
"============================================================================

function! s:IPython() abort
  let b:current_syntax = 'ipython'
  syn match IPythonLineStart            '\v^In\s+\[\d+\]:'
  syn match IPythonLineOut              '\v^Out\[\d+\]:'
  syn match IPythonExcDelimeter         "\v\-{22,}"

  hi def link IPythonLineStart          Identifier
  hi def link IPythonExcDelimeter       Error
  hi def link IPythonLineOut            Error
endfunction

" I am cheating here
set filetype=python
call s:IPython()
