vim9script

var loaded_mark = 0
var matchid = []
var index = 0
var over = 0

if loaded_mark == 1
	finish
endif

loaded_mark = 1

def GetVisualSelection(): string
	var save_clipboard = &clipboard
	g:clipboard = ""
	var save_reg = getreg('"')
	var save_regmode = getregtype('"')
	silent normal! gvy
	var res = getreg('"')
	setreg('"', save_reg, save_regmode)
	&clipboard = save_clipboard
	return res
enddef


def EscapeText(text: string): string
	return substitute( escape(text, '\' .. '^$.*[~'), "\n", '\\n', 'ge' )
enddef

def Process(expr: string)
	if index > 5
		over = 1
		index = 0
	endif

	if over == 1
		matchdelete(matchid[index])
	endif

	matchid[index] = matchadd('MarkWord' .. index, expr)
	index += 1
enddef

def g:MarkCurrentWord()
	var cword = expand('<cword>')
	var regexp: string
	if !empty(cword)
		regexp = EscapeText(cword)
		if cword =~# '^\k\+$'
			regexp = '\<' .. regexp .. '\>'
		endif
	endif

	var expr = ((&ignorecase && regexp !~# '\\\@<!\\C') ? '\c' .. regexp : regexp)

	Process(expr)
enddef

def g:MarkVisualWord()
	var cword = GetVisualSelection()
	var regexp: string
	if !empty(cword)
		regexp = EscapeText(cword)
	endif

	var expr = ((&ignorecase && regexp !~# '\\\@<!\\C') ? '\c' .. regexp : regexp)

	Process(expr)
enddef

def g:ClearAll()
	if index > 0
		for id in matchid
			matchdelete(id)
		endfor
		index = 0
	endif
enddef

def DefaultHighlighting()
	highlight def MarkWord0  ctermbg=Cyan     ctermfg=Black  guibg=#8CCBEA    guifg=Black
	highlight def MarkWord1  ctermbg=Green    ctermfg=Black  guibg=#A4E57E    guifg=Black
	highlight def MarkWord2  ctermbg=Yellow   ctermfg=Black  guibg=#FFDB72    guifg=Black
	highlight def MarkWord3  ctermbg=Red      ctermfg=Black  guibg=#FF7272    guifg=Black
	highlight def MarkWord4  ctermbg=Magenta  ctermfg=Black  guibg=#FFB3FF    guifg=Black
	highlight def MarkWord5  ctermbg=Blue     ctermfg=Black  guibg=#9999FF    guifg=Black
enddef

DefaultHighlighting()

nnoremap <silent> <Plug>MarkSet  :<C-u> call MarkCurrentWord()<CR>
vnoremap <silent> <Plug>MarkSet <C-\><C-n>  :<C-u> call MarkVisualWord()<CR>
nnoremap <silent> <Plug>MarkAllClear :<C-u> call ClearAll()<CR>

