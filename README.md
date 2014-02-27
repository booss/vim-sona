vim-sona
========

my dev plugin I've been using for years...

About the author
=====

- Alex Boussinet (https://github.com/booss)

Introduction
=====

This plugin will help you navigate into your C projects.
With the help of CTAGS `http://ctags.sourceforge.net/` and GLOBAL `https://www.gnu.org/software/global/`
sona allows you to jump, search, list symbols, references, prototypes, structures, files...
sona uses sources to collect data after looking for a pattern.
Those data are then filtered and displayed in the sona window where a specific action can then be triggered (usually open file).
Each sources, filters, actions exports globals and mappings and status flags which can be customized.

Features
=====

### Sources

* gtags (using GLOBAL)
* ctags (using CTAGS)
* ag (using the silver searcher)
* mru (provided by sona)
* source (provided by sona)
* stack (provided by sona)

### Filters

* ag
* ctags
* file
* gtags
* source
* stack
* tag

### Actions

* file open
* source select

Here is my current configuration
=====

```vim
" sona

" options
"let g:sona_ignore_case = 0
let g:sona_save_search = 1
"let g:sona_fuzzy_pattern = 0
let g:sona_auto_action = 1
"let g:sona_hide_on_action = 1

let g:sona_actions_file_open_mode = 't'

nnoremap <silent> <S-Tab>	:call sona#focus()<CR>
" mappings {{{
let g:sona_mapping = {
	\   'sona#sources#gtags#clean()':				[',gc']
	\ , 'sona#sources#gtags#update()':				[',gb']
	\ , 'sona#sources#gtags#update_file(expand(''%''), 0)':		[',gU']
	\ , 'sona#open(''gtags'', ''tag'')':				[',gt']
	\ , 'sona#open(''gtags'', ''ref'')':				[',gr']
	\ , 'sona#open(''gtags'', ''file'')':				[',gf']
	\ , 'sona#open(''gtags'', ''anyfile'')':			[',ga']
	\ , 'sona#open(''gtags'', ''sym'')':				[',gs']
	\ , 'sona#open(''gtags'', ''grep'')':				[',gg']
	\
	\ , 'sona#search(''gtags'', ''tag'', expand(''<cword>''))':	[',]']
	\ , 'sona#search(''gtags'', ''ref'', expand(''<cword>''))':	[',[']
	\ , 'sona#search(''gtags'', ''file'', expand(''<cfile>''))':	[',f']
	\ , 'sona#search(''gtags'', ''sym'', expand(''<cword>''))':	[',s']
	\ , 'sona#search(''gtags'', ''grep'', expand(''<cword>''))':	[',g']
	\
	\ , 'sona#sources#ctags#clean()':				[',cc']
	\ , 'sona#sources#ctags#update()':				[',cb']
	\ , 'sona#open(''ctags'', ''tag'')':				[',ct']
	\ , 'sona#open(''ctags'', ''struct'')':				[',cs']
	\ , 'sona#open(''ctags'', ''union'')':				[',cu']
	\ , 'sona#open(''ctags'', ''func'')':				[',cf']
	\ , 'sona#open(''ctags'', ''proto'')':				[',cp']
	\ , 'sona#open(''ctags'', ''member'')':				[',cm']
	\ , 'sona#open(''ctags'', ''macro'')':				[',cd']
	\ , 'sona#open(''ctags'', ''var'')':				[',cv']
	\ , 'sona#open(''ctags'', ''type'')':				[',cT']
	\ , 'sona#open(''ctags'', ''enum'')':				[',cE']
	\ , 'sona#open(''ctags'', ''enumv'')':				[',ce']
	\
	\ , 'sona#search(''ctags'', ''tag'', expand(''<cword>''))':	[',lt']
	\ , 'sona#search(''ctags'', ''struct'', expand(''<cword>''))':	[',ls']
	\ , 'sona#search(''ctags'', ''union'', expand(''<cword>''))':	[',lu']
	\ , 'sona#search(''ctags'', ''func'', expand(''<cword>''))':	[',lf']
	\ , 'sona#search(''ctags'', ''proto'', expand(''<cword>''))':	[',lp']
	\ , 'sona#search(''ctags'', ''member'', expand(''<cword>''))':	[',lm']
	\ , 'sona#search(''ctags'', ''macro'', expand(''<cword>''))':	[',ld']
	\ , 'sona#search(''ctags'', ''var'', expand(''<cword>''))':	[',lv']
	\ , 'sona#search(''ctags'', ''type'', expand(''<cword>''))':	[',lT']
	\ , 'sona#search(''ctags'', ''enum'', expand(''<cword>''))':	[',lE']
	\ , 'sona#search(''ctags'', ''enumv'', expand(''<cword>''))':	[',le']
	\
	\ , 'sona#sources#ctags#build_highlight()':			[',hb']
	\ , 'sona#sources#ctags#clean_highlight()':			[',hc']
	\ , 'sona#sources#ctags#load_highlight()':			[',hl']
	\
	\ , 'sona#open(''ag'', ''ag'')':				[',ag']
	\ , 'sona#search(''ag'', ''ag'', expand(''<cword>''))':		[',as']
	\
	\ , 'sona#open(''sona'', ''stack'')':				[',st']
	\ , 'sona#open(''sona'', ''source'')':				[',sr']
	\ , 'sona#open(''sona'', ''mru'')':				[',o']
	\
	\ , 'sona#stack_push()':					[',p']
	\ , 'sona#stack_pop()':						[',t']
	\ , 'sona#toggle()':						[',w']
	\ }
" }}}

function! s:sona_filter(val) " {{{
	return a:val.lnum != 0 || a:val.pattern != ''
endfunction " }}}

let s:cflags = ''
let s:syntax_check = 1
function! sona#toggle_syntax_check() " {{{
	if s:syntax_check == 1
		let l:message = 'Syntax checking is off'
		lclose
	else
		let l:message = 'Syntax checking is on'
	endif
	let s:syntax_check = !s:syntax_check
	call sona#report(l:message, 'i')
endfunction " }}}

function! sona#syntax_check() " {{{
	if s:syntax_check == 0
		return
	endif

	let l:makeprg = &makeprg
	let &makeprg = printf('gcc -fsyntax-only %s', s:cflags)
	silent! lmake! %

	let l:list = filter(getloclist(0), 's:sona_filter(v:val)')
	silent! call setloclist(0, l:list, 'r')

	redraw!
	if len(l:list)
		botright lwindow
		call sona#report(' Syntax KO ', 'e')
	else
		lclose
		call sona#report(' Syntax OK ', 'i')
	endif

	let &makeprg = l:makeprg
endfunction " }}}

function! sona#set_cflags() " {{{
	let l:cflags = input('cflags=', s:cflags)
	if s:cflags != l:cflags
		let s:cflags = l:cflags
		call writefile([s:cflags], 'cflags')
	endif
	call sona#report(printf('cflags=%s', s:cflags), 'i')
endfunction " }}}

function! s:sona_qf_filter(val) " {{{
	if (a:val.bufnr == 0)
		if (a:val.text[0] != '/')
			return 0
		endif
	elseif (!filereadable(bufname(a:val.bufnr)))
		return 0
	endif

	return 1
endfunction " }}}

function! sona#quickfix() " {{{
	if !filereadable('errors.err')
		return sona#report('No errors !', 'i')
	endif
	cgetfile errors.err
	let l:list = filter(getqflist(), 's:sona_qf_filter(v:val)')
	silent! call setqflist(l:list, 'r')
	if len(l:list)
		botright cwindow
		call sona#report(' Syntax KO ', 'e')
	else
		cclose
		call sona#report(' Syntax OK ', 'i')
		call delete('errors.err')
	endif
endfunction " }}}

function! sona#build_inc_path() " {{{
	let l:include_path = []
	if filereadable('cflags')
		let l:cflags = join(readfile('cflags', '', 1))
		for opt in split(substitute(l:cflags, '-I\s*', '-I', 'g'), ' ')
			if opt =~ "^-I"
				call add(l:include_path, substitute(opt, '-I', '', ''))
			endif
		endfor
	endif
	execute printf('set path=.,%s,/usr/include', join(l:include_path, ','))
	call s:sb_notify_ok('Building include paths and cflags done.')
endfunction " }}}

map <silent>	,!	:call sona#build_inc_path()<CR>
map <silent>	,?	:call sona#toggle_syntax_check()<CR>
map <silent>	,.	:call sona#quickfix()<CR>
map <silent>	,%	:call sona#set_cflags()<CR>

augroup sona_syntax_check
	autocmd BufWritePost *.c,*.cc,*.h,*.cpp,*.hpp,*.cxx		:call sona#syntax_check()
augroup END

" vim: fdm=marker
```

The cflags file is contains only one line of all the flags required to compile a file of your project.
