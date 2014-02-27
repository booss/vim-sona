"=============================================================================
" FILE: gtags.vim (part of sona filters)
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

function! sona#filters#gtags#filter(tag) " {{{
	let l:match = matchlist(a:tag, '^\(\S*\)\s\+\(\d\+\)\s\+\(\f\+\)\s*\(.*\)$')
	if !empty(l:match)
		let l:filter = {
			\  'match': sona#utils#url_decode_string(l:match[1])
			\ , 'lnum': str2nr(l:match[2])
			\ , 'file': sona#utils#url_decode_string(l:match[3])
			\ , 'search': l:match[4] }
		let l:filter['display'] = s:render_gtags(l:filter)
		return l:filter
	endif
endfunction " }}}
function! s:render_gtags(context) " {{{
	let l:window_width = winwidth(0) - 9
	let l:file = a:context['file']
	let l:search = substitute(a:context['search'], '\s\+', ' ', 'g')
	if l:window_width < 0
		let l:format = '>│%d│%s│%s'
	else
		let l:file_width = float2nr(l:window_width / 100.0 * 40) - 1
		let l:search_width = float2nr(l:window_width / 100.0 * 60) + 1
		let l:format = printf('>│%%05d│%%-%ds│%%-%ds', l:file_width, l:search_width)
		if strlen(l:file) > l:file_width
			let l:file = '...' . l:file[-(l:file_width - 3):-1]
		endif
		if strlen(l:search) > l:search_width
			let l:search = l:search[0:(l:search_width - 4)] . '...'
		endif
	endif
	return printf(l:format, a:context['lnum'], l:file, l:search)
endfunction " }}}

function! sona#filters#gtags#init() " {{{
	return {
		\   'description': 'filter gtags cross references'
		\ , 'filter': 'sona#filters#gtags#filter'
		\ }
endfunction " }}}

" vim: fdm=marker
