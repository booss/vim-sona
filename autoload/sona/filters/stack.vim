"=============================================================================
" FILE: stack.vim (part of sona filters)
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

function! sona#filters#stack#filter(context) " {{{
	let l:filter = {
		\   'lnum': a:context['lnum']
		\ , 'cnum': a:context['cnum']
		\ , 'file': bufname(a:context['bufnr'])
		\ }
	let l:filter['display'] = s:render_stack(l:filter)
	return l:filter
endfunction " }}}
function! s:render_stack(context) " {{{
	let l:window_width = winwidth(0) - 14
	let l:file = a:context['file']
	if l:window_width < 0
		let l:format = '>│%d│%d│%s│'
	else
		let l:format = printf('>│%%05d:%%04d│%%-%ds│', l:window_width)
		if strlen(l:file) > l:window_width
			let l:file = '...' . l:file[-(l:window_width - 3):-1]
		endif
	endif
	return printf(l:format, a:context['lnum'], a:context['cnum'], l:file)
endfunction " }}}

function! sona#filters#stack#init() " {{{
	return {
		\   'description': 'filter stack files'
		\ , 'filter': 'sona#filters#stack#filter'
		\ }
endfunction " }}}

" vim: fdm=marker
