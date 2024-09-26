" =============================================================================
" File:          autoload/ctrlp/buffilter.vim
" Description:   BufFilter extension
"								 modified based on CtrlPLine
" Author:        Troy Daniel <github.com/TroyDanielFZ>
" =============================================================================

" Init {{{1
if exists('g:loaded_ctrlp_buffilter') && g:loaded_ctrlp_buffilter
	fini
en
let g:loaded_ctrlp_buffilter = 1

cal add(g:ctrlp_ext_vars, {
	\ 'init': 'ctrlp#buffilter#init(s:crbufnr)',
	\ 'accept': 'ctrlp#buffilter#accept',
	\ 'exit': 'ctrlp#buffilter#exit()',
	\ 'lname': 'lines',
	\ 'sname': 'lns',
	\ 'sort': 0,
	\ 'type': 'tabe',
	\ })

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
" Utilities {{{1
fu! s:syntax()
	if !ctrlp#nosy()
		cal ctrlp#hicheck('CtrlPBufName', 'Directory')
		cal ctrlp#hicheck('CtrlPTabExtra', 'Comment')
		sy match CtrlPBufName '\t|\zs[^|]\+\ze|\d\+:\d\+|$'
		sy match CtrlPTabExtra '\zs\t.*\ze$' contains=CtrlPBufName
		highlight link CtrlPMatch DiffChange 
	en
endf
" Public {{{1
" use buffilter only in buffilter mode
fu! ctrlp#buffilter#exit()
	unlet g:ctrlp_match_func
endf

fu! ctrlp#buffilter#init(bufnr)
	let [lines, bufnr] = [[], a:bufnr]
	let bufs = exists('s:lnmode') && s:lnmode ? ctrlp#buffers('id') : [bufnr]
	" Load only the current buffer
		let [lfb, bufn] = [getbufline(bufnr, 1, '$'), bufname(bufnr)]
		if lfb == [] && bufn != ''
			let lfb = ctrlp#utils#readfile(fnamemodify(bufn, ':p'))
		en
		cal map(lfb, 'tr(v:val, ''	'', '' '')')
		let [linenr, len_lfb] = [1, len(lfb)]
		let buft = bufn == '' ? '[No Name]' : fnamemodify(bufn, ':t')
		wh linenr <= len_lfb
			let lfb[linenr - 1] .= '	|'.buft.'|'.bufnr.':'.linenr.'|'
			let linenr += 1
		endw
		cal extend(lines, filter(lfb, 'v:val !~ ''^\s*\t|[^|]\+|\d\+:\d\+|$'''))
	cal s:syntax()
	retu lines
endf

fu! ctrlp#buffilter#accept(mode, str)
	let info = matchlist(a:str, '\t|[^|]\+|\(\d\+\):\(\d\+\)|$')
	let bufnr = str2nr(get(info, 1))
	if bufnr
		cal ctrlp#acceptfile('Et', bufnr, get(info, 2)) " jump to buffer, 
		" cal ctrlp#acceptfile(a:mode, bufnr, get(info, 2))
	en
endf

fu! ctrlp#buffilter#cmd(mode, ...)
	let s:lnmode = a:mode
	if a:0 && !empty(a:1)
		let s:lnmode = 0
		let bname = a:1 =~# '^%$\|^#\d*$' ? expand(a:1) : a:1
		let s:bufnr = bufnr('^'.fnamemodify(bname, ':p').'$')
	en

	let g:ctrlp_match_func = { 'match': "ctrlp#buffilter#matcher", 
				\ "highlight": 'ctrlp#buffilter#patterner'}
	" let g:ctrlp_pattern_func = [1, 'ctrlp#buffilter#patterner']
	retu s:id
endf
"}}}

function! ctrlp#buffilter#patterner(str, grp)
	echom "ctrlp#buffilter#patterner: " . a:str
	let patterns=split(tolower(a:str), '\s\+', 0)
	let searchPattern = join(map(patterns, 'SearchEscape(v:val)'), '\|')
	cal matchadd(a:grp, searchPattern)
	" return searchPattern
endfunction

function! ctrlp#buffilter#matcher(items, str, limit, mmode, ispath, crfile, regex)
	echo "ctrlp#buffilter#matcher"
	let items=copy(a:items)
	let patterns=split(tolower(a:str), '\s\+', 0)
	for p in patterns
		call filter(items, 'stridx(tolower(v:val), p) >=0 ')
	endfor
	echo []+items
	return []+items
endfunction

" vim:fen:fdm=marker:fmr={{{,}}}:fdl=0:fdc=1:ts=2:sw=2:sts=2
