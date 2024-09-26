" =============================================================================
" File:          autoload/ctrlp/rtscript.vim
" Description:   Runtime scripts extension
" Author:        Kien Nguyen <github.com/kien>
" =============================================================================

" Init {{{1
if exists('g:loaded_ctrlp_rtscript') && g:loaded_ctrlp_rtscript
	fini
en
let g:loaded_ctrlp_rtscript = 1

cal add(g:ctrlp_ext_vars, {
	\ 'init': 'ctrlp#rtscript#init()',
	\ 'accept': 'ctrlp#acceptfile',
	\ 'lname': 'runtime scripts',
	\ 'sname': 'rts',
	\ 'type': 'path',
	\ 'opmul': 1,
	\ })

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
" Utilities {{{1
fu! s:savetofile(rtss)
	cal ctrlp#utils#writecache(a:rtss, s:cadir, s:cafile)
endf
" Public {{{1
fu! ctrlp#rtscript#init()
	let s:cwd = getcwd()
	if !exists('g:ctrlp_rtscache')
		let entries = ctrlp#utils#readfile(ctrlp#rtscript#cachefile())
		" This should be cached as well after first run.
		sil! cal ctrlp#progress('Processing...')
		let results = map(copy(entries), 'fnamemodify(v:val, '':.'')')
		let g:ctrlp_rtscache = [&rtp, s:cwd, entries, results]
	el
		let [entries, results] = g:ctrlp_rtscache[2:3]
	en
	retu results
endf

fu! ctrlp#rtscript#id()
	retu s:id
endf

" Returns the cache file for runtime scripts.
" If it doesn't exst then generate it
fu! ctrlp#rtscript#cachefile()
	if !exists('s:cadir') || !exists('s:cafile')
		let s:cadir = ctrlp#utils#cachedir().ctrlp#utils#lash().'runtime'
		let s:cafile = s:cadir.ctrlp#utils#lash().'cache.txt'
	en

	if !isdirectory(s:cadir) || !filereadable(s:cafile)
		sil! cal ctrlp#progress('Indexing...')
		let entries = split(globpath(ctrlp#utils#fnesc(&rtp, 'g'), '**/*.*'), "\n")
		cal filter(entries, 'count(entries, v:val) == 1')
		let entries = ctrlp#dirnfile(entries)[1]
		cal s:savetofile(entries)
	en

	retu s:cafile
endf
"}}}

" vim:fen:fdm=marker:fmr={{{,}}}:fdl=0:fdc=1:ts=2:sw=2:sts=2
