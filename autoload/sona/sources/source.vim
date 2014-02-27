"=============================================================================
" FILE: source.vim (part of sona sources)
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

function! sona#sources#source#search(option) dict " {{{
	let l:pattern = sona#patternify(self.pattern)
	let l:results = []
	for [group, source] in items(sona#get_sources())
		for [name, src] in items(source)
			if group =~ l:pattern || name =~ l:pattern || get(
					\ src, 'description', '') =~ l:pattern
				call add(l:results, [ group, name ])
			endif
		endfor
	endfor
	return l:results
endfunction " }}}

function! sona#sources#source#mapping() " {{{
	return {
		\   'persistent': {
		\   	'sona#open(''sona'', ''source'')':	[ '<C-a>' ]
		\	}
		\ }
endfunction " }}}

function! sona#sources#source#init() " {{{
	return {
		\   'group': 'sona'
		\ , 'source': {
			\   'description': 'search available sources'
			\ , 'search': 'sona#sources#source#search'
			\ , 'filter': 'source'
			\ , 'action': 'source_select'
			\ , 'stack': 0
			\ }
		\ }
endfunction " }}}

" vim: fdm=marker
