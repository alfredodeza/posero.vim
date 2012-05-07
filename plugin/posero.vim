" File:        posero.vim
" Description: A presentation plugin for vim
" Maintainer:  Alfredo Deza <alfredodeza AT gmail.com>
" License:     MIT
"============================================================================


if exists("g:loaded_posero") || &cp
  finish
endif


" Globals
let g:posero_presentation = {}
let g:posero_current_slide = 1
let g:posero_current_line = 1
let g:posero_total_slides = 1


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
            "normal z. FIXME this would center the screen, we want that?
            if c !~ '\s'
                sleep 25m
                redraw
            endif
        endfor
        let lineno += 1
        normal $
    endfor
    execute 'normal o'
endfun

function! s:CreateBuffer()
    enew
	setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap number
    "autocmd! BufEnter LastSession.pytest call s:CloseIfLastWindow()
    nnoremap <silent><script> <buffer> <left>  :call <sid>Previous()<CR>
    nnoremap <silent><script> <buffer> h       :call <sid>Previous()<CR>
    nnoremap <silent><script> <buffer> <right> :call <sid>Next(g:posero_current_line+1)<CR>
    nnoremap <silent><script> <buffer> l       :call <sid>Next(g:posero_current_line+1)<CR>
    nnoremap <silent><script> <buffer> L       :call <sid>NextSlide(g:posero_current_slide+1)<CR>
    nnoremap <silent><script> <buffer> H       :call <sid>PreviousSlide(g:posero_current_slide-1)<CR>
endfunction


"check if a syntax file exists for the given filetype - and attempt to
"load one
function! s:Checkable(ft)
    if !exists("g:loaded_" . a:ft . "_syntax_checker")
        exec "runtime syntax_checkers/" . a:ft . ".vim"
    endif

    return exists("*SyntaxCheckers_". a:ft ."_GetLocList")
endfunction

function! s:LoadSyntax(ft)
    exec "runtime posero_syntax/" . a:ft . ".vim"
endfunction


function! s:SourceOptions()
    for line in g:posero_presentation[g:posero_current_slide]["options"]
        execute line
    endfor
endfunction


function! s:NextSlide(slide_number)
    if a:slide_number > g:posero_total_slides
        let msg = "Already at last slide? slide_number was: " . a:slide_number
        call s:Echo(msg)
        return
    endif
    call s:ClearBuffer()
    let g:posero_current_slide = a:slide_number
    let g:posero_current_line = 1
endfunction


function! s:ClearBuffer()
    " This is *very* naive but I assume
    " that if we are not at the very first line
    " in the very first column I need to keep
    " undoing until I am.
    let current_line = line('.')
    let current_column = col('.')
    execute "silent normal 300u"
    if (current_line != 1) || (current_column != 1)
        call s:ClearBuffer()
    endif
endfunction


function! s:PreviousSlide(slide_number)
    call s:ClearBuffer()
    if a:slide_number > 0
        let g:posero_current_slide = a:slide_number
    endif
    let g:posero_current_line = 1
endfunction


function! s:Next(number)
    let slide = g:posero_presentation[g:posero_current_slide]
    if !has_key(slide, a:number)
        let msg = "Already at the end of current slide"
        call s:Echo(msg, 1)
        return
    endif
    if (exists('b:posero_fake_type')) && (slide[a:number] =~ b:posero_fake_type)
        call s:FakeTyping(slide[a:number])
    elseif slide[a:number] =~ "^\s*$"
        execute "normal o"
    else
        execute "normal a" . slide[a:number]. "\<CR>"
    endif
    if (exists("b:posero_push_on_non_fake")) && (slide[a:number] !~ b:posero_fake_type)
        let g:posero_current_line = a:number + 1
        call s:Next(a:number+1)
    else
        let g:posero_current_line = a:number
    endif
endfunction


function! s:Previous()
    execute "silent normal u"
    let g:posero_current_line = line('.')
endfunction


function! s:LoadFile(file_path)
    let contents = readfile(a:file_path)
    let slide_number = 1
    let line_number = 1
    let new_presentation = {}
    let slide = {}
    let slide_options = []
    for line in contents
        if line =~ '\v^\>{79,}'
            let slide["options"] = slide_options
            let new_presentation[slide_number] = slide
            let slide_number = slide_number + 1
            let line_number = 1
            let g:posero_total_slides = g:posero_total_slides + 1
            let slide = {}
            let slide_options = []
            let new_presentation[slide_number] = slide
        elseif line =~ '\v^POSERO\>\>'
            let sourceable_line = split(line, "POSERO>>")[0]
            call add(slide_options, sourceable_line)
        else
            let slide[line_number] = line
            let line_number = line_number + 1
        endif
    endfor
    let g:posero_presentation =  new_presentation
endfunction

function! s:SetSyntax()
   call s:LoadSyntax(b:posero_syntax)
endfunction

function! s:Completion(ArgLead, CmdLine, CursorPos)
    " I can't make this work for files and custom arguments
    " FIXME should revisit this at some point.
    let _version = "version\n"
    let file_list = split(globpath(&path, a:ArgLead), "\n")
    return file_list
endfunction


function! s:Version()
    call s:Echo("posero.vim version 0.0.1dev", 1)
endfunction


function! s:Proxy(action)
    if filereadable(a:action)
        call s:LoadFile(a:action)
        call s:CreateBuffer()
        call s:SourceOptions()
        call s:SetSyntax()
    elseif (a:action == "version")
        call s:Version()
    else
        call s:Echo("Posero: not a valid file or option ==> " . a:action)
    endif
endfunction


command! -nargs=+ -complete=file Posero call s:Proxy(<f-args>)
