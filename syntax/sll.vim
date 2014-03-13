" vim: set ts=4 sts=4 sw=4 et:
"
" Vim syntax file
" Language:     Service Logic Language
" Maintainer:   Rita Pan (rita.pan AT alcatel-lucent DOT com)

" For version 5.x: Clear all syntax items
" For version 6.x: Quit if a syntax file is already loaded
if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

syntax case ignore

syn keyword sllKeyword          set reset return incr true false

syn match sllDefine             "\<client\>"
syn match sllDefine             "\<end\s\+client\>"
syn match sllDefine             "\<server\>"
syn match sllDefine             "\<end\s\+server\>"
syn match sllDefine             "\<fsm\>"
syn match sllDefine             "\<end\s\+fsm\>"
syn match sllDefine             "\<uda\>"
syn match sllDefine             "\<end\s\+uda\>"
syn match sllDefine             "\<state\>"
syn match sllDefine             "\<end\s\+state\>"
syn match sllDefine             "\<event\>"
syn match sllDefine             "\<end\s\+event\>"

syn match sllDefine             "\<dynamic\>"
syn match sllDefine             "\<end\s\+dynamic\>"

syn match sllDefine             "\<def_function\>"
syn match sllDefine             "\<end\s\+def_function\>"
syn match sllDefine             "\<subroutine\>"
syn match sllDefine             "\<end\s\+subroutine\>"
syn match sllDefine             "\<initialize\>"
syn match sllDefine             "\<end\s\+initialize\>"

syn match sllConditional        "\<if\>"
syn match sllConditional        "\<then\>"
syn match sllConditional        "\<end\s\+if\>"
syn match sllConditional        "\<else\>"
syn match sllConditional        "\<elif\>"

syn match sllConditional        "\<test\>"
syn match sllConditional        "\<case\>"
syn match sllConditional        "\<other\>"
syn match sllConditional        "\<end\s\+test\>"

syn match sllRepeat             "\<while\>"
syn match sllRepeat             "\<do\>"
syn match sllRepeat             "\<end\s\+while\>"
syn match sllRepeat             "\<loop\>"
syn match sllRepeat             "\<end\s\+loop\>"

syn match sllComment            "#.*" contains=sllTodo

syn keyword sllTodo             contained TODO FIXME XXX

syn region sllString            start=+"+ skip=+\\"+ end=+"+

hi def link sllConditional      Conditional
hi def link sllRepeat           Repeat
hi def link sllComment          Comment
hi def link sllTodo             Todo
hi def link sllString           String
hi def link sllDefine           Type
hi def link sllKeyword          Keyword

let b:current_syntax = "sll"
