" File:        posero.vim
" Description: A presentation plugin for vim
" Maintainer:  Alfredo Deza <alfredodeza AT gmail.com>
" License:     MIT
"============================================================================


if exists("g:loaded_posero") || &cp
  finish
endif


function! s:PoseroSyntax() abort
  let b:current_syntax = 'posero'
  syn match PoseroDelimeter            '\v\>{70,}'
  syn match PoseroOptions              '\v^POSERO\>\>'

  hi def link PoseroDelimeter          Error
  hi def link PoseroOptions            Statement
endfunction


function! s:SetStatusLine() abort
    set statusline = ""
    set statusline+=Line:
    set statusline+=[
    set statusline+=%{g:posero_current_line}
    set statusline+=/
    set statusline+=%{posero#GetTotalLines()}
    set statusline+=]
    set statusline+=%=
    set statusline+=\ Slide:
    set statusline+=[
    set statusline+=%{g:posero_current_slide}
    set statusline+=/
    set statusline+=%{g:posero_total_slides}
    set statusline+=]
endfunction


au BufEnter *.posero call s:PoseroSyntax()


function! s:SetGlobals() abort
    " Globals
    let g:posero_presentation = {}
    let g:posero_current_slide = 1
    let g:posero_current_line = 1
    let g:posero_total_slides = 1
    let g:posero_faked_last = 0
endfunction


function! s:ResetBufferVars() abort
    let b:posero_fake_type = '\v(.*)@!'
    let b:posero_syntax = 0
    unlet! b:posero_push_all
    unlet! b:posero_push_on_non_fake
    unlet! b:posero_auto_next_line
endfunction


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


function! posero#GetTotalLines() abort
    return len(g:posero_presentation[g:posero_current_slide])-1
endfunction


function! s:FakeTyping(text)
    let fake_delay = {'a': '50m', 'e': '90m', 'i': '80m', 'o': '70m', 'u': '3m'}
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
            if c !~ '\s'
                let sleep_time = get(fake_delay, c, '10m')
                execute "sleep " . sleep_time
                redraw
            endif
        endfor
        let lineno += 1
        normal $
    endfor
    let g:posero_faked_last = 1
endfun

function! s:CreateBuffer()
    enew
	setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap number
    if exists("g:posero_default_mappings")
        if g:posero_default_mappings == 1
            nnoremap <silent> <buffer> <C-h> :call posero#PreviousSlide()<CR>
            nnoremap <silent> <buffer> <C-l> :call posero#NextSlide()<CR>
            nnoremap <silent> <buffer> <C-j> :call posero#NextLine()<CR>
            nnoremap <silent> <buffer> <C-k> :call posero#PreviousLine()<CR>
        endif
    else
        call s:Echo("Posero has no current mappings for flow control! Use `let g:posero_default_mappings = 1` in your .vimrc")
    endif
endfunction


" Helper Mappings for Flow control

function! posero#NextSlide()
    call s:NextSlide(g:posero_current_slide + 1)
endfunction

function! posero#PreviousSlide()
    call s:PreviousSlide(g:posero_current_slide - 1)
endfunction

function! posero#NextLine()
    call s:Next(g:posero_current_line + 1)
endfunction

function! posero#PreviousLine()
    call s:Previous()
endfunction


function! s:SourceOptions()
    for line in get(g:posero_presentation[g:posero_current_slide], "options", [])
        try
            execute line
        catch /(.*)/
            let msg = "Exception raised: " . v:exception . " Executing line >> " . line
            call s:Echo(msg)
        endtry
    endfor
endfunction


function! s:NextSlide(slide_number)
    call s:ResetBufferVars()
    if a:slide_number > g:posero_total_slides
        let msg = "Already at the last slide"
        call s:Echo(msg)
        return
    endif
    call s:ClearBuffer()
    let g:posero_current_slide = a:slide_number
    let g:posero_current_line = 1
    call s:SourceOptions()
    call s:SetSyntax()
    call s:AutoNextLine()
    redraw!
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
    call s:ResetBufferVars()
    call s:ClearBuffer()
    if a:slide_number > 0
        let g:posero_current_slide = a:slide_number
    endif
    let g:posero_current_line = 1
    call s:SourceOptions()
    call s:SetSyntax()
    call s:AutoNextLine()
endfunction

function! s:AutoNextLine()
    if exists("b:posero_auto_next_line") && b:posero_auto_next_line == 1
        call s:Next(g:posero_current_line+1)
    endif
endfunction


function! s:Next(number)
    if g:posero_faked_last == 1
        put = ''
        let g:posero_faked_last = 0
    endif
    let slide = g:posero_presentation[g:posero_current_slide]
    if !has_key(slide, a:number)
        let msg = "Already at the end of current slide"
        call s:Echo(msg, 1)
        return
    endif
    let g:posero_current_line = a:number
    " Make sure we go to the actual line if we are about to write
    execute a:number
    if (exists('b:posero_fake_type')) && (slide[a:number] =~ b:posero_fake_type)
        call s:FakeTyping(slide[a:number])
        if (exists("b:posero_push_all"))
            if has_key(slide, a:number+1)
                call s:Next(a:number+1)
            endif
        endif
        " we return here because we don't want to mix with block pushes
        return
    elseif slide[a:number] =~ "^\s*$"
        put = ''
    else
        execute "normal a" . slide[a:number]
        put = ''
    endif

    " This pushes blocks of text that do not match fake_typing if both
    " fake_type and push_on_non_fake are set, we basically call ourselves
    " again so that the lines above can take care of inserting whatever
    " we need. Note how this portion does not introduce text, it just calls
    " itself.
    if (exists("b:posero_push_on_non_fake")) && (exists('b:posero_fake_type')) && has_key(slide, a:number+1) && (slide[a:number+1] !~ b:posero_fake_type)
        redraw
        if has_key(slide, a:number+1)
            call s:Next(a:number+1)
        endif
    elseif (exists("b:posero_push_all"))
        if has_key(slide, a:number+1)
            call s:Next(a:number+1)
        endif
    endif
endfunction


function! s:Previous()
    execute "silent normal u"
    let g:posero_current_line = line('.')
endfunction


function! s:LoadFile(file_path)
    let contents = readfile(a:file_path)
    let content_len = len(contents)
    let slide_number = 1
    let line_number = 1
    let new_presentation = {}
    let slide = {}
    let slide_options = []
    let loop_count = 0
    for line in contents
        let loop_count = loop_count + 1
        if line =~ '\v^\>{79,}' || (loop_count == content_len)
            if (loop_count == content_len)
                let slide[line_number] = line
                let g:posero_total_slides = g:posero_total_slides
            else
                let g:posero_total_slides = g:posero_total_slides + 1
            endif
            let slide["options"] = slide_options
            let new_presentation[slide_number] = slide
            let line_number = 1
            let slide_number = slide_number + 1
            let slide = {}
            let slide_options = []
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
    if exists("b:posero_syntax")
       call s:LoadSyntax(b:posero_syntax)
    endif
endfunction


function! s:LoadSyntax(ft)
    exec "runtime posero_syntax/" . a:ft . ".vim"
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
        call s:SetGlobals()
        call s:LoadFile(a:action)
        call s:CreateBuffer()
        call s:SourceOptions()
        call s:SetSyntax()
        call s:SetStatusLine()
        call s:AutoNextLine()
    elseif (a:action == "version")
        call s:Version()
    else
        call s:Echo("Posero: not a valid file or option ==> " . a:action)
    endif
endfunction


command! -nargs=+ -complete=file Posero call s:Proxy(<f-args>)
