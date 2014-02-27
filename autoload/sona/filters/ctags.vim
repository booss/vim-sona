"=============================================================================
" FILE: ctags.vim (part of sona filters)
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

function! sona#filters#ctags#filter(tag) " {{{
	if !empty(a:tag)
		let l:filter = {
			\   'lnum': str2nr(a:tag['cmd'])
			\ , 'file': a:tag['filename']
			\ , 'search': a:tag['name']
			\ , 'kind': a:tag['kind']
			\ }
		let l:filter['display'] = s:render_ctags(l:filter)
		return l:filter
	endif
endfunction " }}}
function! s:render_ctags(context) " {{{
	let l:window_width = winwidth(0) - 10
	let l:file = a:context['file']
	let l:search = substitute(a:context['search'], '\s\+', ' ', 'g')
	if l:window_width < 0
		let l:format = '>│%d│%s│%s│%s'
	else
		let l:file_width = float2nr(l:window_width / 100.0 * 40) - 1
		let l:search_width = float2nr(l:window_width / 100.0 * 60)
		let l:format = printf('>│%%05d│%%-%ds│%%s│%%-%ds'
			\ , l:file_width, l:search_width)
		if strlen(l:file) > l:file_width
			let l:file = '...' . l:file[-(l:file_width - 3):-1]
		endif
		if strlen(l:search) > l:search_width
			let l:search = l:search[0:(l:search_width - 4)] . '...'
		endif
	endif
	return printf(l:format, a:context['lnum'], l:file, a:context['kind'], l:search)
endfunction " }}}

function! sona#filters#ctags#init() " {{{
	return {
		\   'description': 'filter ctags cross references'
		\ , 'filter': 'sona#filters#ctags#filter'
		\ }
endfunction " }}}

" vim: fdm=marker
