"=============================================================================
" FILE: mru.vim (part of sona sources)
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

function! sona#sources#mru#search(option) dict " {{{
	let l:pattern = sona#patternify(self.pattern)
	return filter(copy(v:oldfiles), 'v:val =~ l:pattern')
endfunction " }}}

function! sona#sources#mru#sort(a, b) " {{{
	let l:fileA = getftime(get(a:a, 'file', ''))
	let l:fileB = getftime(get(a:b, 'file', ''))
	return l:fileA == l:fileB ? 0 : (l:fileA > l:fileB ? 1 : -1)
endfunction " }}}

function! sona#sources#mru#init() " {{{
	return {
		\   'group': 'sona'
		\ , 'source': {
			\   'description': 'search most recent used files'
			\ , 'search': 'sona#sources#mru#search'
			\ , 'filter': 'file'
			\ , 'action': 'file_open'
			\ , 'sort': 'sona#sources#mru#sort'
			\ , 'stack': 0
			\ }
		\ }
endfunction " }}}

" vim: fdm=marker
