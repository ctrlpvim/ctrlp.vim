" =============================================================================
" File:          autoload/ctrlp/tag.vim
" Description:   Help tag file extension
" Author:        Daniel James Perry <dperry45@gatech.edu>
" =============================================================================

" Init {{{1
if exists('g:loaded_ctrlp_help') && g:loaded_ctrlp_help
    fini
en
let g:loaded_ctrlp_help = 1

cal add(g:ctrlp_ext_vars, {
  \ 'init': 'ctrlp#help#init()',
  \ 'accept': 'ctrlp#help#accept',
  \ 'lname': 'tags',
  \ 'sname': 'tag',
  \ 'enter': 'ctrlp#help#enter()',
  \ 'type': 'tabs',
  \ })

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
" Utilities {{{1
fu! s:findcount(str, tgaddr)
	let [tg, ofname] = split(a:str, '\t\+\ze[^\t]\+$')
	let tgs = taglist('^'.tg.'$')
	if len(tgs) < 2
		retu [0, 0, 0, 0]
	en
	let bname = fnamemodify(bufname('%'), ':p')
	let fname = expand(fnamemodify(simplify(ofname), ':s?^[.\/]\+??:p:.'), 1)
	let [fnd, cnt, pos, ctgs, otgs] = [0, 0, 0, [], []]
	for tgi in tgs
		let lst = bname == fnamemodify(tgi["filename"], ':p') ? 'ctgs' : 'otgs'
		cal call('add', [{lst}, tgi])
	endfo
	let ntgs = ctgs + otgs
	for tgi in ntgs
		let cnt += 1
		let fulname = fnamemodify(tgi["filename"], ':p')
		if stridx(fulname, fname) >= 0
			\ && strlen(fname) + stridx(fulname, fname) == strlen(fulname)
			let fnd += 1
			let pos = cnt
		en
	endfo
	let cnt = 0
	for tgi in ntgs
		let cnt += 1
		if tgi["filename"] == ofname
			if a:tgaddr != ""
				if a:tgaddr == tgi["cmd"]
					let [fnd, pos] = [0, cnt]
				en
			else
				let [fnd, pos] = [0, cnt]
			en
		en
	endfo
	retu [1, fnd, pos, len(ctgs)]
endf

fu! s:filter(tags)
	let nr = 0
	wh 0 < 1
		if a:tags == [] | brea | en
		if a:tags[nr] =~ '^!' && a:tags[nr] !~# '^!_TAG_'
			let nr += 1
			con
		en
		if a:tags[nr] =~# '^!_TAG_' && len(a:tags) > nr
			cal remove(a:tags, nr)
		el
			brea
		en
	endw
	retu a:tags
endf

fu! s:syntax()
	if !ctrlp#nosy()
		cal ctrlp#hicheck('CtrlPTabExtra', 'Comment')
		sy match CtrlPTabExtra '\zs\t.*\ze$'
	en
endf
" Public {{{1
fu! ctrlp#help#init()
	if empty(s:tagfiles) | retu [] | en
	let g:ctrlp_alltags = []
	let tagfiles = sort(filter(s:tagfiles, 'count(s:tagfiles, v:val) == 1'))
	for each in tagfiles
		let alltags = s:filter(ctrlp#utils#readfile(each))
		cal extend(g:ctrlp_alltags, alltags)
	endfo
	cal s:syntax()
	retu g:ctrlp_alltags
endf

fu! ctrlp#help#accept(mode, str)
	cal ctrlp#exit()
	let tgaddr = matchstr(a:str, '^[^\t]\+\t\+[^\t]\+\t\zs[^\t]\{-1,}\ze\%(;"\)\?\t')
	let str = matchstr(a:str, '^[^\t]\+\t\+[^\t]\+\ze\t')
	let [tg, fdcnt] = [split(str, '^[^\t]\+\zs\t')[0], s:findcount(str, tgaddr)]
	let cmds = {
		\ 't': ['tab h'],
		\ 'h': ['h'],
		\ 'v': ['vert h'],
		\ 'e': ['h'],
		\ }
	let utg = fdcnt[3] < 2 && fdcnt[0] == 1 && fdcnt[1] == 1
	let cmd = cmds[a:mode][0]
	let cmd = a:mode == 't' ? ctrlp#tabcount().cmd : cmd
	if !fdcnt[0] || utg
		if cmd != ''
			exe cmd
		en
		let save_cst = &cst
		set cst&
		cal feedkeys(":".( utg ? fdcnt[2] : "" )."h ".tg."\r".(a:mode == 'e' &&
			\ ctrlp#modfilecond(!&aw) ? " | only" : ""), 'nt')
		let &cst = save_cst
	el
		let ext = ""
		if fdcnt[1] < 2 && fdcnt[2]
			let [sav_more, &more] = [&more, 0]
			let ext = fdcnt[2]."\r".":let &more = ".sav_more."\r"
		en
		cal feedkeys(":".cmd." ".tg."\r".ext.(a:mode == 'e' &&
			\ ctrlp#modfilecond(!&aw) ? " | only" : ""), 'nt')
	en
	cal ctrlp#setlcdir()
endf

fu! ctrlp#help#id()
	retu s:id
endf

fu! ctrlp#help#enter()
	let s:tagfiles = filter(map(split(&rtp, ','), { -> v:val . '/doc/tags' }),
		\ 'filereadable(v:val)')
endf

" vim:fen:fdm=marker:fmr={{{,}}}:fdl=0:fdc=1:ts=2:sw=2:sts=2
