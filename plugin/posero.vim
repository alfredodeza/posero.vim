" File:        posero.vim
" Description: A presentation plugin for vim
" Maintainer:  Alfredo Deza <alfredodeza AT gmail.com>
" License:     MIT
"============================================================================


if exists("g:loaded_posero") || &cp
  finish
endif


function! s:Echo(msg, ...)
    redraw!
    let x=&ruler | let y=&showcmd
    set noruler noshowcmd
    if (a:0 == 1)
        echo a:msg
    else
        echohl WarningMsg | echo a:msg | echohl None
    endif

    let &ruler=x | let &showcmd=y
endfun

function! s:GoToError(error_line)
    let split_line    = matchlist(a:error_line, '\v(line\s+)(\d+)')
    let split_column  = matchlist(a:error_line, '\v(column\s+)(\d+)')
    let line_number   = split_line[2]
    let column_number = split_column[2]
    execute line_number
    execute "normal " . column_number . "|"
    let g:posero_has_errors = 1
endfunction!

function! s:FakeTyping(text)
    let lineno = line('.')
    let lines = split(a:text, "\n")
    for line in lines
        call setline(lineno, '')
        let chars = split(line, '.\zs')
        let words = ''
        for c in chars
            let words .= c
            call setline(lineno, words)
            call cursor(lineno, 0)
            normal z.
            if c !~ '\s'
                sleep 25m
                redraw
            endif
        endfor
        let lineno += 1
    endfor
endfun

function! s:CreateBuffer()
    enew
	"silent! execute  winnr < 0 ? 'botright new ' . 'LastSession.pytest' : winnr . 'wincmd w'
	setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap number filetype=posero
    autocmd! BufEnter LastSession.pytest call s:CloseIfLastWindow()
    nnoremap <script> <buffer> <left>  :call <sid>Previous(g:current_slide-1)<CR>
    nnoremap <script> <buffer> h       :call <sid>Previous(g:current_slide-1)<CR>
    nnoremap <script> <buffer> <right> :call <sid>Next(g:current_slide+1)<CR>
    nnoremap <script> <buffer> l       :call <sid>Next(g:current_slide+1)<CR>

endfunction

let g:presentation = {}
let g:current_slide = 0

function! s:StartSlide()
    call s:LoadFile("/Users/adeza/tmp/ipython.posero")
    "for line in g:presentation
        "call s:FakeTyping(line)
    "endfor
endfunction

function! s:Next(number)
    execute "normal a" . g:presentation[a:number]. "\<CR>"
    let g:current_slide = a:number
endfunction

function! s:Previous(number)
    execute "normal u"
    let g:current_slide = a:number
endfunction

function! s:LoadFile(file_path)
    let contents = readfile(a:file_path)
    let slide_number = 1
    let line_number = 1
    let new_presentation = {}
    for line in contents
        let new_presentation[line_number] = line
        let line_number = line_number + 1
    endfor
    let g:presentation =  new_presentation
endfunction

function! s:Completion(ArgLead, CmdLine, CursorPos)
    let actions = "goto\n"
    let _version = "version\n"
    return actions . _version
endfunction


function! s:Version()
    call s:Echo("posero.vim version 0.0.1dev", 1)
endfunction


function! s:Proxy(action)
    if (a:action == "goto")
        echo "NotImplemented"
    elseif (a:action == "start")
        call s:CreateBuffer()
        call s:StartSlide()
    elseif (a:action == "version")
        call s:Version()
    else
        call s:Echo("Not a valid Posero option ==> " . a:action)
    endif
endfunction

command! -nargs=+ -complete=custom,s:Completion Posero call s:Proxy(<f-args>)


