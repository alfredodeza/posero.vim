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
    execute 'normal o'
endfun

function! s:CreateBuffer()
    enew
	"silent! execute  winnr < 0 ? 'botright new ' . 'LastSession.pytest' : winnr . 'wincmd w'
	setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap number filetype=posero
    autocmd! BufEnter LastSession.pytest call s:CloseIfLastWindow()
    nnoremap <script> <buffer> <left>  :call <sid>Previous(g:posero_current_line-1)<CR>
    nnoremap <script> <buffer> h       :call <sid>Previous(g:posero_current_line-1)<CR>
    nnoremap <script> <buffer> <right> :call <sid>Next(g:posero_current_line+1)<CR>
    nnoremap <script> <buffer> l       :call <sid>Next(g:posero_current_line+1)<CR>
    nnoremap <script> <buffer> L       :call <sid>NextSlide(g:posero_current_slide+1)<CR>
    nnoremap <script> <buffer> H       :call <sid>PreviousSlide(g:posero_current_slide-1)<CR>
endfunction

let g:posero_presentation = {}
let g:posero_current_slide = 1
let g:posero_current_line = 0
let g:posero_total_slides = 1

function! s:StartSlide()
    call s:LoadFile("/Users/adeza/tmp/ipython.posero")
endfunction

function! s:NextSlide(slide_number)
    if a:slide_number > g:posero_total_slides
        let msg = "Already at last slide? slide_number was: " . a:slide_number
        call s:Echo(msg)
        return
    endif
    " FIXME how can we clear all of our changes? tracking every time? noooo
    execute "silent normal 300u"
    let g:posero_current_slide = a:slide_number
    let g:posero_current_line = 0
endfunction

function! s:PreviousSlide(slide_number)
    " FIXME how can we clear all of our changes? tracking every time? noooo
    execute "silent normal 300u"
    if a:slide_number > 0
        let g:posero_current_slide = a:slide_number
    endif
    let g:posero_current_line = 0

endfunction

function! s:Next(number)
    let slide = g:posero_presentation[g:posero_current_slide]
    if !has_key(slide, a:number)
        let msg = "Already at the end of current slide? " . a:number
        call s:Echo(msg, 1)
        return
    endif
    if slide[a:number] =~ "^\s*$"
        execute "normal o"
    elseif slide[a:number] =~ '\v^In\s+'
        call s:FakeTyping(slide[a:number])
    else
        execute "normal a" . slide[a:number]. "\<CR>"
    endif
    let g:posero_current_line = a:number
endfunction

function! s:Previous(number)
    execute "normal u"
    if a:number > 0
        let g:posero_current_line = a:number
    endif
endfunction

function! s:LoadFile(file_path)
    let contents = readfile(a:file_path)
    let slide_number = 1
    let line_number = 1
    let new_presentation = {}
    let slide = {}
    for line in contents
        if line =~ '\v^\>{79,}'
            let new_presentation[slide_number] = slide
            let slide_number = slide_number + 1
            let line_number = 1
            let g:posero_total_slides = g:posero_total_slides + 1
            let slide = {}
            let new_presentation[slide_number] = slide
        else
            let slide[line_number] = line
            let line_number = line_number + 1
        endif
    endfor
    let g:posero_presentation =  new_presentation
endfunction

function! s:Completion(ArgLead, CmdLine, CursorPos)
    let actions = "goto\nstart\n"
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


