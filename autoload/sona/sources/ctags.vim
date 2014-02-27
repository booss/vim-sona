"=============================================================================
" FILE: ctags.vim (part of sona sources)
" AUTHOR:  Alex Boussinet <alex.boussinet@gmail.com>
" Last Modified: 29 Aug 2012.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Version: 1.0, for Vim 7.3
"=============================================================================

if !exists('g:sona_loaded') || g:sona_loaded == 0
	finish
endif

function! sona#sources#ctags#globals() " {{{
	return {
		\   'ctags_cmd':	'ctags'
		\ , 'ctags_opt':  	'-Rn --languages=c,c++'
			\ . ' --c-kinds=+p+x --c++-kinds=+p+x'
			\ . ' --fields=+iaS --extra=+q'
		\ }
endfunction " }}}

function! sona#sources#ctags#build_highlight() " {{{
	if !sona#sources#ctags#check()
		return sona#report('Not available', 'i')
	endif

	let g:cSystyp = ''
	let g:cSyscon = ''
	let g:cSysfun = ''
	let g:cSysvar = ''

	call sona#report('Building tag syntax highlight ...', 'i')
	let l:output = system(printf('sed -n %s tags | sort -u',
				\ '''s/^\([^\t]\+\)\t[^\t]\+\t[0-9]\+;"\t\([defglstuvx]\).*/\2;\1/p'''))

	for group in split(l:output, '\n')
		if group =~ ' '
			continue
		endif
		let l:split_group = split(group, ';')
		let [kind, keyword] = l:split_group
		if keyword !~ '^\w\+$'
			continue
		endif
		if kind =~ '[gstu]'
			let g:cSystyp .= ' ' . keyword
		elseif kind =~ '[de]'
			let g:cSyscon .= ' ' . keyword
		elseif kind =~ 'f'
			let g:cSysfun .= ' ' . keyword
		elseif kind =~ '[lvx]'
			let g:cSysvar .= ' ' . keyword
		endif
		unlet! keyword kind group
	endfor

	"c  classes
	"d  macro definitions
	"e  enumerators (values inside an enumeration)
	"f  function definitions
	"g  enumeration names
	"l  local variables [off]
	"m  class, struct, and union members
	"n  namespaces
	"p  function prototypes [off]
	"s  structure names
	"t  typedefs
	"u  union names
	"v  variable definitions
	"x  external and forward variable declarations [off]

	let l:taghi = [
				\'augroup sb_syntax_highlight',
				\'	autocmd!',
				\'	autocmd BufRead,BufNewFile *.c,*.cc,*.h,*.cpp,*.hpp,*.cxx execute',
				\'		\ ''   syntax keyword cSystyp ' . g:cSystyp . ' | highlight link cSystyp Type''',
				\'		\ '' | syntax keyword cSyscon ' . g:cSyscon . ' | highlight link cSyscon PreProc''',
				\'		\ '' | syntax keyword cSysfun ' . g:cSysfun . ' | highlight link cSysfun Function''',
				\'		\ '' | syntax keyword cSysvar ' . g:cSysvar . ' | highlight link cSysvar Identifier''',
				\'augroup END'
				\]
	call writefile(l:taghi, 'taghi')
	call sona#sources#ctags#load_highlight()
	call sona#report('Building tag syntax highlight done.', 'i')
endfunction " }}}
function! sona#sources#ctags#clean_highlight() " {{{
	call sona#report('Removing tag syntax highlight ...', 'i')
	if exists('g:cSustyp')
		unlet g:cSystyp
	endif
	if exists('g:cSuscon')
		unlet g:cSyscon
	endif
	if exists('g:cSusfun')
		unlet g:cSysfun
	endif
	if exists('g:cSusvar')
		unlet g:cSysvar
	endif
	silent! autocmd! sb_syntax_highlight
	silent! augroup! sb_syntax_highlight
	call sona#report('Removing tag syntax highlight done.', 'i')
endfunction " }}}
function! sona#sources#ctags#load_highlight() " {{{
	if !filereadable('taghi')
		return sona#report('Not available', 'i')
	endif
	source taghi
	call sona#report('Tag syntax highlight loaded.', 'i')
endfunction " }}}

function! sona#sources#ctags#check() " {{{
	return filereadable('tags')
endfunction " }}}
function! sona#sources#ctags#clean() " {{{
	call system('rm -f tags taghi')
	call sona#report('ctags file removed', 'i')
endfunction " }}}
function! sona#sources#ctags#update() " {{{
	if sona#sources#ctags#check()
		call system(g:sona_sources_ctags_ctags_cmd . ' '
			\ . g:sona_sources_ctags_ctags_opt)
		call sona#report('ctags file updated', 'i')
	else
		call system(g:sona_sources_ctags_ctags_cmd . ' '
			\ . g:sona_sources_ctags_ctags_opt)
		call sona#report('ctags file created', 'i')
	endif
endfunction " }}}

function! sona#sources#ctags#search(option) dict " {{{
	if sona#sources#ctags#check()
		if self.pattern == ''
			return []
		endif
		let l:tags = taglist(sona#patternify(self.pattern)
			\ . (g:sona_ignore_case ? '\c' : '\C'))
		return a:option == '' ? l:tags
			\ : filter(l:tags, 'v:val[''kind''] == a:option')
	else
		call sona#report('no database found', 'e')
		return []
	endif
endfunction " }}}

function! sona#sources#ctags#init() " {{{
	return {
		\   'group': 'ctags'
		\ , 'source': [
			\   {
				\   'description': 'search a tag definition'
				\ , 'name': 'tag'
				\ , 'search': 'sona#sources#ctags#search'
				\ , 'filter': 'ctags'
				\ , 'action': 'file_open'
				\ , 'stack': 1
				\ , 'jump': 1
				\ }
			\ , {
				\   'description': 'search a structure'
				\ , 'name': 'struct'
				\ , 'search': 'sona#sources#ctags#search'
				\ , 'opt': 's'
				\ , 'filter': 'ctags'
				\ , 'action': 'file_open'
				\ , 'stack': 1
				\ }
			\ , {
				\   'description': 'search a union'
				\ , 'name': 'union'
				\ , 'search': 'sona#sources#ctags#search'
				\ , 'opt': 'u'
				\ , 'filter': 'ctags'
				\ , 'action': 'file_open'
				\ , 'stack': 1
				\ }
			\ , {
				\   'description': 'search a function'
				\ , 'name': 'func'
				\ , 'search': 'sona#sources#ctags#search'
				\ , 'opt': 'f'
				\ , 'filter': 'ctags'
				\ , 'action': 'file_open'
				\ , 'stack': 1
				\ }
			\ , {
				\   'description': 'search a function prototype'
				\ , 'name': 'proto'
				\ , 'search': 'sona#sources#ctags#search'
				\ , 'opt': 'p'
				\ , 'filter': 'ctags'
				\ , 'action': 'file_open'
				\ , 'stack': 1
				\ }
			\ , {
				\   'description': 'search a struct or union member'
				\ , 'name': 'member'
				\ , 'search': 'sona#sources#ctags#search'
				\ , 'opt': 'm'
				\ , 'filter': 'ctags'
				\ , 'action': 'file_open'
				\ , 'stack': 1
				\ }
			\ , {
				\   'description': 'search a macro'
				\ , 'name': 'macro'
				\ , 'search': 'sona#sources#ctags#search'
				\ , 'opt': 'd'
				\ , 'filter': 'ctags'
				\ , 'action': 'file_open'
				\ , 'stack': 1
				\ }
			\ , {
				\   'description': 'search a global or extern variable'
				\ , 'name': 'var'
				\ , 'search': 'sona#sources#ctags#search'
				\ , 'opt': 'v'
				\ , 'filter': 'ctags'
				\ , 'action': 'file_open'
				\ , 'stack': 1
				\ }
			\ , {
				\   'description': 'search a typedef'
				\ , 'name': 'type'
				\ , 'search': 'sona#sources#ctags#search'
				\ , 'opt': 't'
				\ , 'filter': 'ctags'
				\ , 'action': 'file_open'
				\ , 'stack': 1
				\ }
			\ , {
				\   'description': 'search an enum'
				\ , 'name': 'enum'
				\ , 'search': 'sona#sources#ctags#search'
				\ , 'opt': 'g'
				\ , 'filter': 'ctags'
				\ , 'action': 'file_open'
				\ , 'stack': 1
				\ }
			\ , {
				\   'description': 'search an enum value'
				\ , 'name': 'enumv'
				\ , 'search': 'sona#sources#ctags#search'
				\ , 'opt': 'e'
				\ , 'filter': 'ctags'
				\ , 'action': 'file_open'
				\ , 'stack': 1
				\ }
			\ ]
		\ }
endfunction " }}}

" vim: fdm=marker
