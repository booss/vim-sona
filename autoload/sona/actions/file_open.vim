"=============================================================================
" FILE: file_open.vim (part of sona actions)
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

let s:open_modes = {
	\   'e': ['edit', 'sbuffer']
	\ , 't': ['tabnew', 'tab sbuffer']
	\ , 'h': ['new', 'sbuffer']
	\ , 'v': ['vnew', 'vertical sbuffer']
	\ }

function! sona#actions#file_open#cycle() " {{{
	let l:open_modes = keys(s:open_modes)
	let g:sona_actions_file_open_mode =
		\ l:open_modes[(index(l:open_modes
		\ , g:sona_actions_file_open_mode) + 1) % len(l:open_modes)]
endfunction " }}}

function! sona#actions#file_open#globals() " {{{
	return {
		\   'mode':		't'
		\ , 'new_window':	0
		\ }
endfunction " }}}
function! sona#actions#file_open#mapping() " {{{
	return {
		\   'sona#action(''e'')': 	[ '<C-e>' ]
		\ , 'sona#action(''t'')': 	[ '<C-t>' ]
		\ , 'sona#action(''h'')': 	[ '<C-h>' ]
		\ , 'sona#action(''v'')':	[ '<C-v>' ]
		\ , 'persistent': {
			\   'sona#actions#file_open#cycle()':	[ '<C-o>' ]
			\ }
		\ }
endfunction " }}}

function! sona#actions#file_open#action(results, ...) " {{{
	let l:open_cmd = get(s:open_modes
		\ , a:0 ? a:1 : g:sona_actions_file_open_mode, 'e')
	for context in a:results
		let l:file = get(context, 'file', '')
		if l:file == '' || empty(glob(l:file))
			call sona#report('file not found', 'e')
			continue
		endif
		if bufname('%') == ''
			let l:mode = 'edit'
		else
			let l:mode = l:open_cmd[buflisted(bufnr(l:file))
				\ && g:sona_actions_file_open_new_window == 0]
		endif
		execute l:mode l:file
		let l:lnum = get(context, 'lnum', 1)
		let l:cnum = stridx(getline(l:lnum)
			\ , get(context, 'search', '')) + 1
		call cursor(l:lnum, l:cnum > 0 ? l:cnum : 1)
		normal zz
	endfor
endfunction " }}}

function! sona#actions#file_open#init() " {{{
	call sona#add_status_flag('actions', 'file_open', 'mode')
	return {
		\   'description': 'open files'
		\ , 'action': 'sona#actions#file_open#action'
		\ }
endfunction " }}}

" vim: fdm=marker
