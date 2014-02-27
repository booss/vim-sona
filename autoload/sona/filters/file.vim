"=============================================================================
" FILE: file.vim (part of sona filters)
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

function! sona#filters#file#globals() " {{{
	return {
		\   'exclude':		''
		\ }
endfunction " }}}

function! sona#filters#file#filter(string) " {{{
	let l:match = matchlist(a:string, '^\(\f\+\)$')
	if !empty(l:match)
		let l:file = sona#utils#url_decode_string(a:string)
		if glob(l:file) != ''
			if g:sona_filters_file_exclude != ''
					\ && l:file =~ g:sona_filters_file_exclude
				return
			endif
			let l:filter = {
						\   'lnum': 1
						\ , 'file': l:file
						\ }
			let l:filter['display'] = s:render_file(l:filter)
			return l:filter
		endif
	endif
endfunction " }}}
function! s:render_file(context) " {{{
	let l:window_width = winwidth(0) - 3
	let l:file = a:context['file']
	if l:window_width < 0
		let l:format = '>│%s│'
	else
		let l:format = printf('>│%%-%ds│', l:window_width)
		if strlen(l:file) > l:window_width
			let l:file = '...' . l:file[-(l:window_width - 3):-1]
		endif
	endif
	return printf(l:format, l:file)
endfunction " }}}

function! sona#filters#file#init() " {{{
	return {
		\   'description': 'filter file names'
		\ , 'filter': 'sona#filters#file#filter'
		\ }
endfunction " }}}

" vim: fdm=marker
