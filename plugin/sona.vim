"=============================================================================
" FILE: sona.vim
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

if v:version < 703
	echoerr 'This plugin requires VIM 7.3'
	finish
elseif exists('g:sona_loaded') && g:sona_loaded == 1
	finish
endif
let g:sona_loaded = 1

function! s:install_mapping(map, local, mapping) " {{{
	for [action, mapping] in items(a:mapping)
		for key in mapping
			execute 'nnoremap <silent>'
				\ (a:local ? '<buffer> ' : ' ') . key .
				\ (a:map ? ' :call ' . action . '<CR>' : ' <Nop>') 
		endfor
	endfor
endfunction " }}}

" global config {{{
let s:global_defaults = {
	\   'ignore_case':		0
	\ , 'save_search': 		0
	\ , 'fuzzy_pattern':		0
	\ , 'auto_action':		0
	\ , 'hide_on_action':		1
	\ , 'window_height':		15
	\ , 'max_results': 		100
	\ , 'max_display_results': 	50
	\ , 'extra_mapkeys': 		[]
	\ , 'window_position':		'botright'
	\ , 'mapping':			{}
	\ , 'cursor_color':
	\	'ctermbg=250 ctermfg=000 guibg=#efefef guifg=#000000'
	\ , 'match_color':
	\	'ctermbg=NONE ctermfg=111 guibg=NONE guifg=#68a9eb'
	\ , 'text_color':
	\	'ctermbg=NONE ctermfg=118 guibg=NONE guifg=#ffdb72'
	\ , 'mark_color':
	\	'ctermbg=NONE ctermfg=112 guibg=NONE guifg=#99cf50'
	\ , 'line_color':
	\	'ctermbg=NONE ctermfg=140 guibg=NONE guifg=#bcdbff'
	\ , 'column_color':
	\	'ctermbg=NONE ctermfg=118 guibg=NONE guifg=#ffdb72'
	\ , 'kind_color':
	\	'ctermbg=NONE ctermfg=140 guibg=NONE guifg=#bcdbff'
	\ , 'file_color':
	\	'ctermbg=NONE ctermfg=207 guibg=NONE guifg=#ffb3ff'
	\ , 'hide_dark':
	\	'ctermfg=233 guifg=#000'
	\ , 'hide_light':
	\	'ctermfg=254 guifg=#fff'
	\ }
for [name, value] in items(s:global_defaults)
	if !exists('g:sona_' . name)
		execute 'let g:sona_' . name '=' string(value)
	endif
	unlet value
endfor
call s:install_mapping(1, 0, g:sona_mapping)
" }}}
" script variables {{{
let s:sona = {}
let s:flags = {}
let s:stack = []
let s:group = 'sona'
let s:source = 'source'
let s:stack_idx = 0
" }}}
" window parameters {{{
let s:window_global_options = {
	\   'mouse':		['n']
	\ , 'switchbuf':	['useopen,usetab']
	\ , 'hlsearch':		[0]
	\ , 'magic':		[1]
	\ , 'cpoptions':	['&vim']
	\ , 'lazyredraw':	[1]
	\ , 'timeoutlen':	[0]
	\ }
let s:window_local_options = {
	\   'buflisted':	0
	\ , 'buftype':		'nofile'
	\ , 'swapfile':		0
	\ , 'colorcolumn':	0
	\ , 'cursorcolumn':	0
	\ , 'cursorline':	1
	\ , 'updatetime':	500
	\ , 'number':		0
	\ , 'relativenumber':	0
	\ , 'foldcolumn':	0
	\ }
let s:window_mapping = {
	\   'sona#close()':				[ '<Esc>', '<C-c>' ]
	\ , '<SID>prompt_remove_char()':		[ '<BS>' ]
	\ , '<SID>prompt_delete_char()':		[ '<Del>' ]
	\ , '<SID>prompt_delete_word()':		[ '<C-w>' ]
	\ , '<SID>prompt_erase()':			[ '<C-u>' ]
	\ , '<SID>cursor_left()':			[ '<Left>' ]
	\ , '<SID>cursor_right()':			[ '<Right>' ]
	\ , '<SID>cursor_home()':			[ '<Home>' ]
	\ , '<SID>cursor_end()':			[ '<End>' ]
	\ , '<SID>window_select(1)':			[ '<C-k>' ]
	\ , '<SID>window_select(0)':			[ '<C-j>' ]
	\ , '<SID>window_last()':			[ '<Tab>' ]
	\ , 'sona#toggle_flag(''ignore_case'', 1)':	[ '<C-i>' ]
	\ , 'sona#toggle_flag(''fuzzy_pattern'', 1)':	[ '<C-f>' ]
	\ , 'sona#toggle_flag(''save_search'', 0)':	[ '<C-y>' ]
	\ , 'sona#toggle_flag(''hide_on_action'', 0)':	[ '<C-h>' ]
	\ , 'sona#toggle_flag(''auto_action'', 0)':	[ '<C-\>' ]
	\ , '<SID>search_render(1)':			[ '<C-l>' ]
	\ , '<SID>cycle_group(-1)':			[ '<C-b>' ]
	\ , '<SID>cycle_group(1)':			[ '<C-d>' ]
	\ , '<SID>cycle_source(-1)':			[ '<C-p>' ]
	\ , '<SID>cycle_source(1)':			[ '<C-n>' ]
	\ , '<SID>window_mark()':			[ '<C-x>' ]
	\ , 'sona#action()':		[ '<CR>', '<2-LeftMouse>' ]
	\ }
" }}}

function! sona#report(message, type) " {{{
	redraw
	execute 'echohl'
		\ a:type == 'e' ? 'Error' :
		\ a:type == 'w' ? 'WarningMsg' :
		\ a:type == 'i' ? 'MoreMsg' : 'Normal'
	echo 'sona: ' . a:message
	echohl None
endfunction " }}}
function! sona#get_sources() " {{{
	return s:sources
endfunction " }}}
function! sona#toggle_flag(flag, refresh) " {{{
	if exists('t:sona')
		let g:sona_{a:flag} = !g:sona_{a:flag}
		let t:sona.update = a:refresh == 1
	endif
endfunction " }}}
function! sona#patternify(pattern) " {{{
	"let l:pattern = substitute(substitute(a:pattern
	"	\ , '^\s\+|\s\+$', '', 'g')
	"	\ , '[$.^*({?+\\|]', '\\&', 'g')
	let l:pattern = substitute(a:pattern , '^\s\+|\s\+$', '', 'g')
	if g:sona_fuzzy_pattern == 1
		let l:pattern =  substitute(l:pattern, '.', '.*&', 'g') . '.*'
	else
		let l:pattern =  '.*'
			\ . substitute(l:pattern, '\s\+', '.*', 'g') . '.*'
	endif
	return substitute(l:pattern, '\(\.\*\)\+', '.*', 'g')
endfunction " }}}
function! sona#matchify(pattern) " {{{
	" return (g:sona_ignore_case == 1 ? '\c' : '')
	"	\ . substitute(join(split(substitute(
	"	\   a:pattern, '[~$.`^\\]', '\\&', 'g')
	"	\ , g:sona_fuzzy_pattern == 1 ? '[^│]\zs' : ' ')
	"	\ , '[^│]\{-\}'), '^\s\+|\s\+$', '', 'g')
	let l:match = g:sona_ignore_case == 1 ? '\c' : ''
	let l:match .= join(split(
		\ substitute(a:pattern, '^\s\+|\s\+$', '', 'g')
		\ , g:sona_fuzzy_pattern == 1 ? '[^│]\zs' : ' ')
		\ , '[^│ ]{-}')
	return substitute(l:match, '\%(^\|[^\\]\)\.\([*+?]\)', '[^│ ]\1', 'g')
endfunction " }}}

function! s:custom_flag() " {{{
	let l:flags = ''
	for [flag, onoff] in items(s:flags)
		if exists('g:sona_' . flag)
			if empty(onoff)
				let l:flags .= g:sona_{flag}
			else
				let l:flags .= g:sona_{flag} ? onoff[0] : onoff[1]
			endif
		endif
	endfor
	return l:flags
endfunction " }}}
function! sona#add_status_flag(type, source, flag, ...) " {{{
	let l:var = a:type . '_' . a:source . '_' . a:flag
	let l:fullvar = 'g:sona_' . l:var
	let s:flags[l:var] = copy(a:000)
endfunction " }}}
function! sona#status(type) " {{{
	if !exists('t:sona')
		return ''
	endif
	return a:type == 'group' ? t:sona.group
		\ : a:type == 'source' ? t:sona.source
		\ : a:type == 'tresults' ? t:sona.tresults
		\ : a:type == 'fuzzy' ? g:sona_fuzzy_pattern ? 'F' : 'f'
		\ : a:type == 'hide' ? g:sona_hide_on_action ? 'H' : 'h'
		\ : a:type == 'auto' ? g:sona_auto_action ? 'A' : 'a'
		\ : a:type == 'case' ? g:sona_ignore_case ? 'I' : 'i'
		\ : a:type == 'save' ? g:sona_save_search ? 'R' : 'r'
		\ : a:type == 'custom_flag' ? s:custom_flag()
		\ : '?'
endfunction " }}}
function! s:statusline_render() " {{{
	execute 'setlocal statusline='
		\ . '\ %{sona#status(''group'')}'
		\ . ':%{sona#status(''source'')}'
		\ . '\ -\ %{sona#status(''tresults'')}\ found'
		\ . '%<%=['
		\ . '%{sona#status(''fuzzy'')}'
		\ . '%{sona#status(''case'')}'
		\ . '%{sona#status(''auto'')}'
		\ . '%{sona#status(''save'')}'
		\ . '%{sona#status(''hide'')}'
		\ . '%{sona#status(''custom_flag'')}'
		\ . ']'
endfunction " }}}

function! s:stack_open(rm, idx) " {{{
	if empty(s:stack)
		let s:stack_idx = 0
		return sona#report('stack is empty', 'w')
	endif
	let l:context = a:rm ? remove(s:stack, a:idx) : s:stack[a:idx]
	let l:bufnr = l:context['bufnr']
	execute (buflisted(l:bufnr) && bufwinnr(l:bufnr) != -1 ?
		\ 'buffer' : 'sbuffer') l:bufnr
	let l:cnum = get(l:context, 'cnum', -1)
	if l:cnum < 0
		let l:line = getline(l:context['lnum'])
		let l:cnum = stridx(l:line, get(l:context, 'search', '')) + 1
	endif
	call cursor(l:context['lnum'], l:cnum <= 0 ? 1 : l:cnum)
	normal zv
endfunction " }}}
function! sona#get_stack() " {{{
	return s:stack
endfunction " }}}
function! sona#stack_push() " {{{
	if bufname(bufnr('%')) != ''
		call add(s:stack, {
			\   'bufnr': bufnr('%')
			\ , 'lnum': line('.')
			\ , 'cnum': col('.')
			\ })
	endif
endfunction " }}}
function! sona#stack_pop() " {{{
	call s:stack_open(1, -1)
endfunction " }}}
function! s:stack_dir(dir) " {{{
	let l:l = len(s:stack)
	let l:idx = s:stack_idx + a:dir
	return l:idx >= 0 && l:idx < l:l
endfunction " }}}
function! sona#stack_drop(idx) " {{{
	let l:l = len(s:stack)
	if a:idx < l:l && a:idx >= -l:l
		remove(s:stack, a:idx)
	endif
endfunction " }}}
function! sona#stack_prev() " {{{
	if s:stack_dir(-1)
		let s:stack_idx -= 1
		call s:stack_open(0, s:stack_idx)
	endif
endfunction " }}}
function! sona#stack_next() " {{{
	if s:stack_dir(+1)
		let s:stack_idx += 1
		call s:stack_open(0, s:stack_idx)
	endif
endfunction " }}}

function! s:cursor_left() " {{{
	if exists('t:sona') && t:sona.cursor > 0
		let t:sona.cursor -= 1
		call s:prompt_render()
	endif
endfunction " }}}
function! s:cursor_right() " {{{
	if exists('t:sona') && t:sona.cursor < strlen(t:sona.pattern)
		let t:sona.cursor += 1
		call s:prompt_render()
	endif
endfunction " }}}
function! s:cursor_home() " {{{
	if exists('t:sona') && t:sona.cursor > 0
		let t:sona.cursor = 0
		call s:prompt_render()
	endif
endfunction " }}}
function! s:cursor_end() " {{{
	if exists('t:sona')
		let l:length = strlen(t:sona.pattern)
		if t:sona.cursor < l:length
			let t:sona.cursor = l:length
			call s:prompt_render()
		endif
	endif
endfunction " }}}
function! s:cursor_render(char) " {{{
	echohl SonaCursor
	echon a:char
	echohl None
endfunction " }}}

function! s:prompt_render() " {{{
	if exists('t:sona')
		call sona#report('', 'i')
		if t:sona.pattern != '' && t:sona.cursor == 0
			call s:cursor_render(t:sona.pattern[0])
			echon t:sona.pattern[1:-1]
		elseif t:sona.cursor == len(t:sona.pattern)
			echon t:sona.pattern
			call s:cursor_render(' ')
		elseif t:sona.cursor < len(t:sona.pattern)
			echon t:sona.pattern[0:(t:sona.cursor - 1)]
			call s:cursor_render(t:sona.pattern[t:sona.cursor])
			if t:sona.cursor < len(t:sona.pattern) - 1
				echon t:sona.pattern[(t:sona.cursor + 1):-1]
			endif
		else
			echon t:sona.pattern
		endif
	endif
endfunction " }}}
function! s:prompt_add(char) " {{{
	if exists('t:sona')
		let t:sona.pattern = substitute(
			\ t:sona.pattern, '\%' . (t:sona.cursor + 1)
			\ . 'c\zs', a:char, '')
		let t:sona.cursor += strlen(a:char)
		let t:sona.update = 1
		call s:prompt_render()
	endif
endfunction " }}}
function! s:prompt_remove_char() " {{{
	if exists('t:sona') && t:sona.pattern != '' && t:sona.cursor > 0
		let t:sona.pattern = substitute(
			\ t:sona.pattern, '.\%' . (t:sona.cursor + 1)
			\ . 'c', '', '')
		let t:sona.cursor -= 1
		let t:sona.update = 1
		call s:prompt_render()
	endif
endfunction " }}}
function! s:prompt_delete_char() " {{{
	if exists('t:sona') && t:sona.cursor < len(t:sona.pattern)
		let t:sona.pattern = substitute(
			\ t:sona.pattern, '\%' . (t:sona.cursor + 1)
			\ . 'c.', '', '')
		let t:sona.update = 1
		call s:prompt_render()
	endif
endfunction " }}}
function! s:prompt_delete_word() " {{{
	if exists('t:sona') && t:sona.pattern != '' && t:sona.cursor != 0
		let l:length = strlen(t:sona.pattern)
		let t:sona.pattern = substitute(t:sona.pattern,
			\ printf('\zs\(\w\+\|\W\+\)\ze\%%%dc'
			\ , t:sona.cursor + 1), '', '')
		let t:sona.cursor -= l:length - strlen(t:sona.pattern)
		let t:sona.update = 1
		call s:prompt_render()
	endif
endfunction " }}}
function! s:prompt_erase() " {{{
	if exists('t:sona')
		let t:sona.pattern = ''
		let t:sona.cursor = 0
		let t:sona.update = 1
		call s:prompt_render()
	endif
endfunction " }}}

function! s:cycle_group(direction) " {{{
	if exists('t:sona')
		let l:groups = keys(s:sources)
		call t:sona.mapkeys(0)
		let t:sona.group = l:groups[(index(l:groups, t:sona.group)
			\ + a:direction) % len(l:groups)]
		let t:sona.source = keys(s:sources[t:sona.group])[0]
		let s:group = t:sona.group
		call t:sona.mapkeys(1)
		let t:sona.update = 1
	endif
endfunction " }}}
function! s:cycle_source(direction) " {{{
	if exists('t:sona')
		let l:sources = keys(s:sources[t:sona.group])
		call t:sona.mapkeys(0)
		let t:sona.source = l:sources[(index(l:sources, t:sona.source)
			\ + a:direction) % len(l:sources)]
		let s:source = t:sona.source
		call t:sona.mapkeys(1)
		let t:sona.update = 1
	endif
endfunction " }}}

function! s:window_mark() " {{{
	if !exists('t:sona')
		return
	endif
	let l:lnum = line('.')
	let l:index = index(t:sona.marks, l:lnum)
	if l:index < 0
		call setline(l:lnum, substitute(getline(l:lnum), '^.', '*', ''))
		call add(t:sona.marks, l:lnum)
	else
		call setline(l:lnum, substitute(getline(l:lnum), '^.', ' ', ''))
		call remove(t:sona.marks, l:index)
	endif
	call cursor(l:lnum + 1, 1)
endfunction " }}}
function! s:window_last() " {{{
	wincmd p
endfunction " }}}
function! s:window_select(line) " {{{
	if exists('t:sona')
		call cursor(a:line == 0 ? t:sona.nresults : a:line, 1)
	endif
endfunction " }}}
function! s:window_mapkeys() " {{{
	for regname in split('"0123456789abcdefghijklmnopqrstuvwxyz.%#*+~/', '.\zs')
		let s:window_mapping['<SID>prompt_add(getreg('
			\ . string(regname) . '))'] = [ '<C-r>' . regname ]
	endfor

	for [action, keys] in items(s:window_mapping)
		for key in keys
			execute 'nnoremap <silent> <buffer>' key
				\ . ' :call ' . action . '<CR>'
		endfor
	endfor

	for char in extend(split(
			\   '0123456789'
			\ . 'abcdefghijklmnopqrstuvwxyz'
			\ . 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
			\ . ' `~!@#$%^&*()[{]}/?=+-_\|''",<.>;:'
			\ , '.\zs'), g:sona_extra_mapkeys)
		execute printf('nnoremap <silent> <buffer> <Char-0x%x> :call <SID>prompt_add(%s)<CR>'
				\ , char2nr(char)
				\ , char == '|' ? string('\|') : string(char))
	endfor

	autocmd! CursorHold <buffer>	call <SID>search_render(0)
endfunction " }}}
function! s:window_highlighting() " {{{
	let l:bg=synIDattr(synIDtrans(hlID("Normal")), "bg")
	if l:bg != -1
		try
			highlight SonaHide ctermfg=bg guifg=bg
		catch /E420/
		endtry
	else
		let l:bg=synIDattr(synIDtrans(hlID("NonText")), "bg")
		if l:bg != -1
			execute "highlight SonaHide ctermfg=" . l:bg
		elseif &background == "dark"
			execute "highlight SonaHide " . g:sona_hide_dark
		elseif &background == "light"
			execute "highlight SonaHide " . g:sona_hide_light
		endif
	endif
	execute 'highlight SonaMark' g:sona_mark_color
		\ . '| highlight SonaText ' . g:sona_text_color
		\ . '| highlight SonaMatch ' . g:sona_match_color
		\ . '| highlight SonaCursor ' . g:sona_cursor_color
		\ . '| highlight SonaLnum ' . g:sona_line_color
		\ . '| highlight SonaCnum ' . g:sona_column_color
		\ . '| highlight SonaKind ' . g:sona_kind_color
		\ . '| highlight SonaFile ' . g:sona_file_color

	syntax match SonaText /== NO MATCH ==/
	syntax match SonaHide /^>/
	syntax match SonaMark /^\*/
	syntax match SonaHide /│/ contained

	syntax match SonaLnum /\d\+\(:\|│\)\@=/ contained
	syntax match SonaCnum /:\zs\d\+\ze\(│\)\@=/ contained
	syntax match SonaLiCo /│\d\+\(:\d\+\)\=\(│\)\@=/
		\ contains=SonaLnum,SonaCnum,SonaHide

	syntax match SonaFile /│\f\+\s*\(│\)\@=/
		\ contains=SonaHide,SonaLiCo,SonaKind

	syntax match SonaKind /│[a-z]\(│\)\@=/ contains=SonaHide

	syntax match SonaText /│[^│]*$/ contains=SonaHide
endfunction " }}}
function! s:window_enter() " {{{
	if exists('t:sona')
		for [name, parameters] in items(s:window_global_options)
			let [l:default; l:original] = parameters
			if empty(l:original)
				call add(parameters, eval('&' . name))
			endif
			execute printf('let &g:%s=%s', name, string(l:default))
		endfor
		call s:statusline_render()
	endif
endfunction " }}}
function! s:window_leave(force) " {{{
	unlet! s:last
	if !exists('t:sona')
		return
	elseif a:force == 1
		autocmd! * <buffer>
		wincmd p
		execute 'bdelete! ' . t:sona.bufnr
		if g:sona_save_search
			let s:last = t:sona
			let s:last.bufnr = -1
		endif
		unlet! t:sona
	endif
	for [name, parameters] in items(s:window_global_options)
		let [l:default, l:original] = parameters
		execute printf('let &g:%s=%s', name, string(l:original))
	endfor
	redraw | echo
endfunction " }}}

function! s:init() " {{{
	let s:mapping = {}
	call s:init_filters()
	call s:init_actions()
	call s:init_sources()
endfunction " }}}
function! s:init_mapping(type, name, ...) " {{{
	let l:mapping = {}
	silent! let l:mapping = sona#{a:type}#{a:name}#mapping()
	if type(l:mapping) != 4
		return sona#report('invalid mapping', 'w')
	endif
	if has_key(l:mapping, 'persistent')
		let l:persistent = remove(l:mapping, 'persistent')
		if type(l:persistent) == 4
			call extend(s:window_mapping, l:persistent)
		endif
	endif
	if len(l:mapping) == 0
		return
	elseif !has_key(s:mapping, a:type)
		let s:mapping[a:type] = {}
	endif
	if a:0
		if !has_key(s:mapping[a:type], a:1)
			let s:mapping[a:type][a:1] = {}
		endif
		let s:mapping[a:type][a:1][a:name] = l:mapping
	elseif !has_key(s:mapping[a:type], a:name)
		if a:type == 'sources'
			if !has_key(s:mapping[a:type], a:name)
				let s:mapping[a:type][a:name] = {}
			endif
			let s:mapping[a:type][a:name]['__shared'] = l:mapping
		else
			let s:mapping[a:type][a:name] = l:mapping
		endif
	endif
endfunction " }}}
function! s:init_globals(type, name) " {{{
	let l:globals = {}
	silent! let l:globals = sona#{a:type}#{a:name}#globals()
	if type(l:globals) != 4
		return sona#report('invalid globals', 'w')
	elseif empty(l:globals)
		return
	endif
	for [key, value] in items(l:globals)
		if !exists('g:sona_' . a:type . '_' . a:name . '_' . key)
			let g:sona_{a:type}_{a:name}_{key} = value
		endif
	endfor
endfunction " }}}
function! s:init_filters() " {{{
	let s:filters = {}
	for filter_path in split(globpath(&runtimepath,
			\ 'autoload/sona/filters/*.vim'), "\n")
		let l:name = fnamemodify(filter_path, ':t:r')
		silent! let l:filter = sona#filters#{l:name}#init()
		if !exists('l:filter')
			call sona#report('filter ' . l:name . ' failed', 'w')
			continue
		elseif has_key(s:filters, l:name)
			call sona#report('filter ' . l:name . ' exists', 'w')
		elseif type(l:filter) != 4
			call sona#report('filter ' . l:name . ' is invalid', 'w')
		else
			let s:filters[l:name] = copy(l:filter)
		endif
		call s:init_globals('filters', l:name)
		call s:init_mapping('filters', l:name)
		unlet l:filter
	endfor
endfunction " }}}
function! s:init_source(group, source, ...) " {{{
	let l:name = a:0 ? a:1 : get(a:source, 'name', '')
	if l:name == ''
		return sona#report('invalid source name', 'w')
	elseif !has_key(s:sources, a:group)
		let s:sources[a:group] = {}
	endif
	if has_key(s:sources[a:group], l:name)
		return sona#report('source ' . l:name . ' exists', 'w')
	else
		let s:sources[a:group][l:name] = copy(a:source)
	endif
	call s:init_mapping('sources', l:name, a:group)
endfunction " }}}
function! s:init_sources() " {{{
	let s:sources = {}
	for source_path in split(globpath(&runtimepath,
			\ 'autoload/sona/sources/*.vim'), "\n")
		let l:name = fnamemodify(source_path, ':t:r')
		unlet! l:source l:source_def
		silent! let l:source = sona#sources#{l:name}#init()
		if !exists('l:source')
			call sona#report('source ' . l:name . ' failed', 'w')
			continue
		elseif type(l:source) != 4
			call sona#report('source ' . l:name . ' is invalid', 'w')
			continue
		endif
		let l:group = get(l:source, 'group', '')
		if l:group == ''
			call sona#report(
				\ 'source ' . l:name . ' has no group', 'w')
			continue
		endif
		let l:source_def = get(l:source, 'source', {})
		if empty(l:source_def)
			call sona#report(
				\ 'source ' . l:name . ' not defined', 'w')
			continue
		elseif type(l:source_def) == 3
			call s:init_mapping('sources', l:group)
			for src in l:source_def
				if type(src) != 4
					call sona#report(
						\ 'source ' . l:name
						\ . ' is invalid', 'w')
				else
					call s:init_source(l:group, src)
				endif
			endfor
		elseif type(l:source_def) == 4
			call s:init_source(l:group, l:source_def, l:name)
		else
			call sona#report('source ' . l:name . ' is invalid', 'w')
		endif
		call s:init_globals('sources', l:name)
	endfor
endfunction " }}}
function! s:init_actions() " {{{
	let s:actions = {}
	for source_path in split(globpath(&runtimepath,
			\ 'autoload/sona/actions/*.vim'), "\n")
		let l:name = fnamemodify(source_path, ':t:r')
		silent! let l:action = sona#actions#{l:name}#init()
		if !exists('l:action')
			call sona#report('action ' . l:name . ' failed', 'w')
			continue
		elseif type(l:action) != 4
			call sona#report('action ' . l:name . ' is invalid', 'w')
		elseif has_key(s:actions, l:name)
			call sona#report('action ' . l:name . ' exists', 'w')
		else
			let s:actions[l:name] = copy(l:action)
		endif
		call s:init_globals('actions', l:name)
		call s:init_mapping('actions', l:name)
		unlet l:action
	endfor
endfunction " }}}
call s:init()

function! sona#focus() " {{{
	if exists('t:sona')
		execute bufwinnr(t:sona.bufnr) 'wincmd w'
		return t:sona.bufnr
	endif
endfunction " }}}
function! s:sona.show() dict " {{{
	execute 'keepalt' g:sona_window_position
		\ g:sona_window_height 'new sona' . tabpagenr()
	redraw
	let t:sona = self
	let self.bufnr = bufnr('%')

	for [optname, default] in items(s:window_local_options)
		execute printf('let &l:%s=%s', optname, string(default))
	endfor

	autocmd! BufEnter <buffer> call <SID>window_enter()
	autocmd! BufLeave <buffer> call <SID>window_leave(0)
	autocmd! VimResized <buffer> call <SID>search_render(1)

	call s:window_highlighting()
	call s:window_mapkeys()
	call self.mapkeys(1)
	call s:window_enter()
endfunction " }}}
function! sona#open(group, source) " {{{
	let l:sona = s:sona_new(a:group, a:source, '')
	if sona#focus()
		let l:sona.bufnr = t:sona.bufnr
		unlet! t:sona
		let t:sona = l:sona
	else
		call l:sona.show()
	endif
	call t:sona.render(1)
endfunction " }}}
function! sona#close() " {{{
	if sona#focus()
		call s:window_leave(1)
	endif
endfunction " }}}
function! sona#toggle() " {{{
	if sona#focus()
		call s:window_leave(1)
	else
		let l:sona = exists('s:last') ? s:last :
			\ s:sona_new(s:group, s:source, '')
		call l:sona.show()
		call l:sona.render(1)
	endif
endfunction " }}}

function! s:sona_new(group, source, pattern) " {{{
	if !has_key(s:sources, a:group)
		return sona#report('invalid group', 'e')
	elseif !has_key(s:sources[a:group], a:source)
		return sona#report('invalid source', 'e')
	endif

	let s:group = a:group
	let s:source = a:source
	return extend({
		\   'update': 0
		\ , 'bufnr': -1
		\ , 'marks': []
		\ , 'nresults': 0
		\ , 'tresults': 0
		\ , 'results': []
		\ , 'group': a:group
		\ , 'source': a:source
		\ , 'pattern': a:pattern
		\ , 'cursor': len(a:pattern)
		\ }, s:sona)
endfunction " }}}
function! s:sona.get(key, ...) dict " {{{
	return get(s:sources[self.group][self.source], a:key, a:0 ? a:1 : 0)
endfunction " }}}
function! s:sona.mapkeys(map) dict " {{{
	if has_key(s:mapping, 'sources')
			\ && has_key(s:mapping['sources'], self.group)
		let l:map = s:mapping['sources'][self.group]
		call s:install_mapping(a:map, 1, get(l:map, '__shared', {}))
		call s:install_mapping(a:map, 1, get(l:map, self.source, {}))
	endif
	let l:action = self.get('action', '')
	if l:action != '' && has_key(s:mapping, 'actions')
			\ && has_key(s:mapping['actions'], l:action)
		call s:install_mapping(a:map, 1, s:mapping['actions'][l:action])
	endif
	let l:filter = self.get('filter', '')
	if l:filter != '' && has_key(s:mapping, 'filters')
			\ && has_key(s:mapping['filters'], l:filter)
		call s:install_mapping(a:map, 1, s:mapping['filters'][l:filter])
	endif
endfunction " }}}
function! sona#action(...) " {{{
	if sona#focus()
		call call(t:sona.action, a:000, t:sona)
	endif
endfunction " }}}
function! s:sona.action(...) dict " {{{
	if empty(self.results)
		return sona#report('no match', 'w')
	endif
	let l:results = []
	if empty(self.marks)
		call add(l:results, self.results[line('.') - 1])
	else
		for line in self.marks
			call add(l:results, get(self.results, line - 1, {}))
		endfor
		let self.marks = []
	endif
	if g:sona_hide_on_action
		call sona#close()
	endif
	if self.get('stack', 1) == 1
		call sona#stack_push()
	endif
	let l:action = self.get('action', '')
	if !has_key(s:actions, l:action)
		throw 'unknown action ' . l:action
	endif
	if !has_key(s:actions[l:action], 'action')
		throw 'no action given for ' . l:action
	endif
	let l:action = s:actions[l:action]['action']
	if l:action == '' || !exists('*' . l:action)
		throw 'bad action ' . l:action
	endif
	call call(l:action, insert(copy(a:000), l:results))
endfunction " }}}

function! s:cmp(a, b) " {{{
	return a:a == a:b ? 0 : (a:a > a:b ? 1 : -1)
endfunction " }}}
function! s:sort(a, b) dict " {{{
	let l:result = strlen(get(a:a, 'match', ''))
	if l:result > 0
		let l:result -= strlen(get(a:b, 'match', ''))
	else
		let l:fileA = get(a:a, 'file', '')
		if l:fileA != ''
			let l:fileB = get(a:b, 'file', '')
			let l:result += s:cmp(getftime(l:fileB), getftime(l:fileA))
			let l:result += s:cmp(strlen(fnamemodify(l:fileA, ':t'))
				\ , strlen(fnamemodify(l:fileB, ':t')))
			let l:result += s:cmp(fnamemodify(l:fileA, ':e')
				\ , fnamemodify(l:fileB, ':e'))
			let l:result += s:cmp(strlen(fnamemodify(l:fileA, ':h'))
				\ , strlen(fnamemodify(l:fileB, ':h')))
		endif
	endif
	return s:cmp(l:result, 0)
endfunction " }}}
function! s:sona.search() dict " {{{
	let self.nresults = 0
	let self.tresults = 0
	let self.results = []

	let l:search = self.get('search', '')
	if l:search == ''
		throw 'no source given for ' . self.group . ':' . self.source
	elseif !exists('*' . l:search)
		throw 'bad search command ' . l:search
	endif

	let l:results = call(l:search, [self.get('opt', '')], self)
	let self.tresults = len(l:results)
	if self.tresults > 0
		let l:filter = self.get('filter', '')
		if !has_key(s:filters, l:filter)
			throw 'unknown filter ' . l:filter
		endif
		if !has_key(s:filters[l:filter], 'filter')
			throw 'no filter given for ' . l:filter
		endif
		let l:filter = s:filters[l:filter]['filter']
		if l:filter == '' || !exists('*' . l:filter)
			throw 'bad filter ' . l:filter
		endif

		for line in l:results[0:(self.get('max', g:sona_max_results) - 1)]
			let l:filtered_line = {l:filter}(line)
			if !empty(l:filtered_line)
				call add(self.results, l:filtered_line)
			endif
			unlet l:filtered_line
		endfor
		call sort(self.results, self.get('sort', 's:sort'), self)
	endif
	let self.nresults = len(self.results)
	return self.tresults
endfunction " }}}
function! sona#search(group, source, pattern) " {{{
	if a:pattern == ''
		return sona#report('empty pattern', 'w')
	endif
	let l:sona = s:sona_new(a:group, a:source, a:pattern)
	if empty(l:sona)
		return
	elseif l:sona.search() == 0
		return sona#report('tag not found', 'w')
	endif

	if g:sona_auto_action == 1
			\ && (l:sona.nresults == 1
			\ || get(l:sona.results[0], 'match', '')
			\ == a:pattern)
		let l:sona.marks = [1]
		call l:sona.action()
	else
		if sona#focus()
			let l:sona.bufnr = t:sona.bufnr
			unlet! t:sona
			let t:sona = l:sona
		else
			call l:sona.show()
		endif
		call t:sona.render(1)
	endif
endfunction " }}}
function! s:sona.render(update) dict " {{{
	if !sona#focus()
		return
	endif
	if a:update == 1 || self.update == 1
		let self.update = 0
		try
			call sona#report('UPDATING...', 'i')
			silent call self.search()
		catch /^Vim:Interrupt$/
			let self.results = []
			let self.nresults = 0
			let self.tresults = 0
			call sona#report('ABORTED...', 'i') | sleep 300m
		endtry
		redraw!
	endif
	let l:lnum = line('.')
	silent %d _
	match none
	if self.nresults == 0
		call setline(1, '  == NO MATCH ==')
	else
		let l:i = 1
		for line in self.results[0:(self.get('max_display',
				\ g:sona_max_display_results) - 1)]
			call setline(l:i, get(line, 'display', ''))
			let l:i += 1
		endfor
		if self.pattern != ''
			execute 'match SonaMatch `\v'
				\ . sona#matchify(self.pattern)
				\ . '`'
		endif
		for mark in self.marks
			call setline(mark, substitute(
				\ getline(mark), '^.', '*', ''))
		endfor
		call cursor(l:lnum, 1)
	endif
	call s:prompt_render()
endfunction " }}}
function! s:search_render(force) " {{{
	if exists('t:sona')
		call t:sona.render(a:force)
	endif
endfunction " }}}

" vim: fdm=marker
