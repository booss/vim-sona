"=============================================================================
" FILE: source.vim (part of sona filters)
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

function! sona#filters#source#filter(context) " {{{
	let [l:grp, l:src] = a:context
	let l:filter = {
		\   'grp': l:grp
		\ , 'src': l:src
		\ }
	let l:filter['display'] = s:render_source(l:filter)
	return l:filter
endfunction " }}}
function! s:render_source(context) " {{{
	let l:window_width = winwidth(0) - 4
	let l:group = a:context['grp']
	let l:source = a:context['src']
	let l:descr = get(sona#get_sources()[l:group][l:source]
		\ , 'description', '')
	if l:window_width < 0
		let l:format = '>│%s│%s│%s'
	else
		let l:group_width = float2nr(l:window_width / 100.0 * 20) - 1
		let l:source_width = float2nr(l:window_width / 100.0 * 20) - 1
		let l:descr_width = float2nr(l:window_width / 100.0 * 60) + 1
		let l:format = printf('>│%%-%ds│%%-%ds│%%-%ds'
			\ , l:group_width, l:source_width, l:descr_width)
		if strlen(l:group) > l:group_width
			let l:group = l:group[-(l:group_width - 3):-1] . '...'
		endif
		if strlen(l:source) > l:source_width
			let l:source = l:source[-(l:source_width - 3):-1] . '...'
		endif
		if strlen(l:descr) > l:descr_width
			let l:descr = l:descr[0:(l:descr_width - 4)] . '...'
		endif
	endif
	return printf(l:format, l:group, l:source, l:descr)
endfunction " }}}

function! sona#filters#source#init() " {{{
	return {
		\   'description': 'filter available sources'
		\ , 'filter': 'sona#filters#source#filter'
		\ }
endfunction " }}}

" vim: fdm=marker
