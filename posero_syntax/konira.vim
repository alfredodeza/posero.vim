" File:        konira.vim
" Description: Syntax File for Konira
" Maintainer:  Alfredo Deza <alfredo at deza.pe>
" License:     MIT
"============================================================================


function! s:KoniraSyntax() abort
    let b:current_syntax = 'konira'
    syn match KoniraIt                   '\v^\s+it\s+'
    syn match KoniraLet                  '\v^\s+let\s+'
    syn match KoniraSkipIf               '\v^\s+skip\s+if'
    syn match KoniraDescribe             '\v^describe\s+'
    syn match KoniraRaises               '\v^\s+raises\s+'
    syn match KoniraBeforeAll            '\v^\s+before\s+all'
    syn match KoniraBeforeEach           '\v^\s+before\s+each'
    syn match KoniraAfterEach            '\v^\s+after\s+each'
    syn match KoniraAfterAll             '\v^\s+after\s+all'

    hi def link KoniraSkipIf             Statement
    hi def link KoniraIt                 Statement
    hi def link KoniraLet                Statement
    hi def link KoniraDescribe           Statement
    hi def link KoniraRaises             Identifier
    hi def link KoniraBeforeAll          Statement
    hi def link KoniraBeforeEach         Statement
    hi def link KoniraAfterAll           Statement
    hi def link KoniraAfterEach          Statement
endfunction

" I am cheating here
set filetype=python
call s:KoniraSyntax()
