" vim: set ts=4 sts=4 sw=4 et:

if exists('g:loaded_matchit')
    let s:sol = '\%(^\)\s*'
    let s:notend = '\%(\<end\s\+\)\@<!'
    let b:match_words = s:notend . '\<if\>:\<end\s\+if\>'
              \ . ',' . s:notend . '\<while\>:\<end\s\+while\>'
              \ . ',' . s:notend . '\<loop\>:\<end\s\+loop\>'
              \ . ',' . s:notend . '\<test\>:\<case\>:\<end\s\+test\>'
              \ . ',' . s:sol    . '\<initialize\>:\<end\s\+initialize\>'
              \ . ',' . s:sol    . '\<event\s\+\w\+\>:\<end\s\+event\>'
              \ . ',' . s:sol    . '\<state\s\+\w\+\>:\<end\s\+state\>'
              \ . ',' . s:sol    . '\<uda\s\+\w\+\>:\<end\s\+uda\>'
              \ . ',' . s:sol    . '\<fsm\s\+\w\+\>:\<end\s\+fsm\>'
              \ . ',' . s:sol    . '\<subroutine\s\+\w\+\>:\<end\s\+subroutine\>'
              \ . ',' . s:sol    . '\<def_function\s\+\w\+\>:\<end\s\+def_function\>'
endif

function! Sll_Match()

    "let pattern_start = "^\\s*\\(if\\|while\\|loop\\|test\\|event\\|state\\|uda\\|fsm\\|subroutine\\|def_function\\|initialize\\)"
    let pattern_start = "^\\s*\\(if\\|while\\|loop\\|test\\|state\\|uda\\|fsm\\|subroutine\\|def_function\\|initialize\\)"
    let pattern_middle = "^\\s*\\(else\\|elif\\|case\\|other\\)"
    "let pattern_end = "^\\s*end \\(if\\|while\\|loop\\|test\\|event\\|state\\|uda\\|fsm\\|subroutine\\|def_function\\|initialize\\)"
    let pattern_end = "^\\s*end \\(if\\|while\\|loop\\|test\\|state\\|uda\\|fsm\\|subroutine\\|def_function\\|initialize\\)"

    let level = 1
    if match(getline('.'), pattern_start) >= 0
        while (level > 0)
            norm j
            let line = getline('.')
            if match(line, pattern_start) >= 0
                let level = level + 1
            elseif match(line, pattern_end) >= 0
                let level = level - 1
            elseif match(line, pattern_middle) >= 0 && level == 1
                break
            endif
        endwhile
    elseif match(getline('.'), pattern_end) >= 0
        while (level > 0)
            norm k
            let line = getline('.')
            if match(line, pattern_start) >= 0
                let level = level - 1
            elseif match(line, pattern_end) >= 0
                let level = level + 1
            endif
        endwhile
    elseif match(getline('.'), pattern_middle) >= 0
        while (level > 0)
            norm j
            let line = getline('.')
            if match(line, pattern_start) >= 0
                let level = level + 1
            elseif match(line, pattern_end) >= 0
                let level = level - 1
            elseif match(line, pattern_middle) >= 0 && level == 1
                break
            endif
        endwhile
    endif
    echo
endfunc

function! Sll_Parent()
    "save current position for jumpping back later.
    normal m`
    echo

    "generate the search pattern for all segment supported.
    let seglist = ['fsm', 'uda', 'state', 'event', 'def_function', 'subroutine', 'initialize', 'client', 'server']
    let seghead = '^\s*\(' . join(seglist, "\\|") . '\)\(\s\+\a[\w!\?]*\|\s*$\)'
    let endlist = deepcopy(seglist)
    let segtail = '^\s*\(' . join(map(endlist, '"end\\s*" . v:val'), "\\|") . '\)\s*'
    let segpattern = '\(' . seghead . '\|' . segtail . '\)'

    "firstly, go to the head statement if we are at tail.
    let line = getline('.')
    if match(line, segtail) >= 0
        for seg in seglist
            if match(line, '^\s*end\s*'. seg .'.*') >= 0
                let skipitem = substitute(line, '^\s*end\s*'.seg.'\s*', '', '')
                let skipitem = substitute(skipitem, '\s*', '', 'g')
                let skipitem = substitute(skipitem, '#.*', '', 'g')
                if len(skipitem) > 0
                    if search('^\s*'.seg.'\s\+' . skipitem, 'bW') == 0
                        echohl WarningMsg
                        echo 'No starting statement for ' . seg . " " . skipitem . '. Search result may not be accurate.'
                        echohl None
                    endif
                else
                    call search('^\s*'.seg.'\(\s\+\a[\w!\?]*\|\s*$\)', 'bW')
                endif
                normal ^
                break
            endif
        endfor
    endif

    "now, go to the parent statement
    while(1)
        "search above for head or tail statement
        normal 0
        if search(segpattern,'bW') == 0
            echohl WarningMsg
            echo 'No SLL parent statement found'
            echohl None
            normal ''
            return
        endif

        "got the parent if we found head statement
        let line = getline('.')
        if match(line, seghead) >= 0
            normal ^
            return
        endif

        "skip any neighbor statement
        if match(line, segtail) >= 0
            for seg in seglist
                if match(line, '^\s*end\s*'. seg .'.*') >= 0
                    let skipitem = substitute(line, '^\s*end\s*'.seg.'\s*', '', '')
                    let skipitem = substitute(skipitem, '\s*', '', 'g')
                    let skipitem = substitute(skipitem, '#.*', '', 'g')
                    if len(skipitem) > 0
                        if search('^\s*'.seg.'\s\+' . skipitem, 'bW') == 0
                            echohl WarningMsg
                            echo 'No starting statement for ' . seg . " " . skipitem . '. Search result may not be accurate.'
                            echohl None
                        endif
                    else
                        call search('^\s*'.seg.'\(\s\+\a[\w!\?]*\|\s*$\)', 'bW')
                    endif
                    normal ^
                    break
                endif
            endfor
        endif
    endwhile
endfun

function! Log_Find_SrcLine()
    let Source_Line=0
    let lineno=matchstr(getline("."),"at_line:.*\\d\\+$")
    if lineno != ""
        let lineno = matchstr(lineno,"\\d\\+$")+0
        if lineno > 0
            let Source_Line = lineno
            exe "norm \<c-w>\<c-w>" . Source_Line . "G"
            "Pattern \%23l indicate that match 23th line
            exe 'match Todo /\%' . line('.') . 'l.*/'
            exe "norm \<c-w>\<c-w>"
            exe 'match Todo /\%' . line('.') . 'l.*/'
        endif
    endif
endfun

function! Log_Trace_Downward()
    normal j
    call Log_Find_SrcLine()
endfunction

function! Log_Trace_Upward()
    normal k
    call Log_Find_SrcLine()
endfunction

function! Log_Function_Match()
    let pattern_call = 'FUNC\s*CALLED'
    let pattern_retn = 'FUNC\s*RTNED'
    let line = getline('.')
    if match(line, pattern_call) >= 0
        let func_name = substitute(line, '^.*FUNC\s\+CALLED\s*', '', '')
        call search('FUNC\s\+RTNED\s*'.func_name, 'W')
    elseif match(line, pattern_retn) >= 0
        let func_name = substitute(line, '^.*FUNC\s\+RTNED\s*', '', '')
        call search('FUNC\s\+CALLED\s*'.func_name, 'bW')
    endif
endfunction

function! Log_Which_Event()
    let pattern_event_entry = '^++\sSYM'
    call search(pattern_event_entry, 'bW')
endfunction

nmap <silent> <buffer> <F1> :call Sll_Match()<CR>
nmap <silent> <buffer> <F2> :call Sll_Parent()<CR>

nmap <silent> <F4> :call Log_Trace_Downward()<CR>
nmap <silent> <F5> :call Log_Trace_Upward()<CR>
nmap <silent> <F7> :call Log_Function_Match()<CR>
nmap <silent> <F8> :call Log_Which_Event()<CR>
