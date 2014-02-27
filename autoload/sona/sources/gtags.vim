"=============================================================================
" FILE: gtags.vim (part of sona sources)
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

function! sona#sources#gtags#check() " {{{
	return filereadable('GPATH') && filereadable('GRTAGS') && filereadable('GTAGS')
endfunction " }}}
function! sona#sources#gtags#clean() " {{{
	call system('rm -f GPATH GRTAGS GTAGS')
	call sona#report('gtags files removed', 'i')
endfunction " }}}
function! sona#sources#gtags#update() " {{{
	if sona#sources#gtags#check()
		call system(g:sona_sources_gtags_global_cmd . ' -u')
		call sona#report('gtags files updated', 'i')
	else
		call system(g:sona_sources_gtags_gtags_cmd)
		call sona#report('gtags files created', 'i')
	endif
endfunction " }}}
function! sona#sources#gtags#update_file(file, quiet) " {{{
	if sona#sources#gtags#check()
		call system(g:sona_sources_gtags_global_cmd . ' --single-update ' . string(a:file))
		if a:quiet == 0
			call sona#report('updated file''s symbols', 'i')
		endif
	elseif a:quiet == 0
		return sona#report('no gtags file found', 'e')
	endif
endfunction " }}}

function! sona#sources#gtags#globals() " {{{
	return {
		\   'auto_update':	1
		\ , 'gtags_cmd':	'gtags'
		\ , 'global_cmd':	'global'
		\ , 'protect_pattern':	0
		\ }
endfunction " }}}
function! sona#sources#gtags#mapping() " {{{
	return {
		\   'sona#toggle_flag(''sources_gtags_protect_pattern'', 1)':
		\				[ '<C-g>' ]
		\ }
endfunction " }}}

function! sona#sources#gtags#search(option) dict " {{{
	if sona#sources#gtags#check()
		return split(system(printf(g:sona_sources_gtags_global_cmd
			\ . " %s %s %s %s | head -n %d"
			\ , a:option, g:sona_ignore_case ? '-i' : ''
			\ , g:sona_sources_gtags_protect_pattern ? '-e' : ''
			\ , shellescape(self.source =~ 'grep' ? self.pattern
			\ : sona#patternify(self.pattern)), g:sona_max_results)), "\n")
	else
		call sona#report('no database found', 'e')
		return []
	endif
endfunction " }}}

function! sona#sources#gtags#init() " {{{
	call sona#add_status_flag('sources', 'gtags'
		\ , 'protect_pattern', 'P', 'p')
	if g:sona_sources_gtags_auto_update == 1
		autocmd! BufWritePost *.[ch] call sona#sources#gtags#update_file(expand('%'), 1)
	endif

	return {
		\   'group': 'gtags'
		\ , 'source': [
			\   {
				\   'description': 'search tag definition'
				\ , 'name': 'tag'
				\ , 'search': 'sona#sources#gtags#search'
				\ , 'opt': '-x'
				\ , 'filter': 'gtags'
				\ , 'action': 'file_open'
				\ , 'stack': 1
				\ }
			\ , {
				\   'description': 'search tag references'
				\ , 'name': 'ref'
				\ , 'search': 'sona#sources#gtags#search'
				\ , 'opt': '-rx'
				\ , 'filter': 'gtags'
				\ , 'action': 'file_open'
				\ , 'stack': 1
				\ }
			\ , {
				\   'description': 'search project files'
				\ , 'name': 'file'
				\ , 'search': 'sona#sources#gtags#search'
				\ , 'opt': '-P'
				\ , 'filter': 'file'
				\ , 'action': 'file_open'
				\ , 'stack': 1
				\ }
			\ , {
				\   'description': 'search symbols'
				\ , 'name': 'sym'
				\ , 'search': 'sona#sources#gtags#search'
				\ , 'opt': '-sx'
				\ , 'filter': 'gtags'
				\ , 'action': 'file_open'
				\ , 'stack': 1
				\ }
			\ , {
				\   'description': 'grep files'
				\ , 'name': 'grep'
				\ , 'search': 'sona#sources#gtags#search'
				\ , 'opt': '-gx'
				\ , 'filter': 'gtags'
				\ , 'action': 'file_open'
				\ , 'stack': 1
				\ }
			\ , {
				\   'description': 'search all project files'
				\ , 'name': 'anyfile'
				\ , 'search': 'sona#sources#gtags#search'
				\ , 'opt': '-Po'
				\ , 'filter': 'file'
				\ , 'action': 'file_open'
				\ , 'stack': 1
				\ }
			\ , {
				\   'description': 'search symbol location'
				\ , 'name': 'symloc'
				\ , 'search': 'sona#sources#gtags#search'
				\ , 'opt': '-s'
				\ , 'filter': 'file'
				\ , 'action': 'file_open'
				\ , 'stack': 1
				\ }
			\ , {
				\   'description': 'grep location'
				\ , 'name': 'greploc'
				\ , 'search': 'sona#sources#gtags#search'
				\ , 'opt': '-g'
				\ , 'filter': 'file'
				\ , 'action': 'file_open'
				\ , 'stack': 1
				\ }
			\ ]
		\ }
endfunction " }}}

" vim: fdm=marker
