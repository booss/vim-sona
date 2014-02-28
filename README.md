vim-sona
========

my dev plugin I've been using for years...

About the author
=====

- Alex Boussinet (https://github.com/booss)

Introduction
=====

This plugin will help you navigate into your C projects.
You'll be able to jump to tag definitions, declaration, references, files...
Sona comes bundled with sources, filters, actions which are entirely customizable.

Dependencies
=====
* global (https://www.gnu.org/software/global/)
* ctags (http://ctags.sourceforge.net/)
* the_silver_searcher (https://github.com/ggreer/the_silver_searcher.git)

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

Configuration
=====

### Options

```vim
let g:sona_ignore_case = 0
let g:sona_save_search = 0
let g:sona_fuzzy_pattern = 0
let g:sona_auto_action = 0
let g:sona_hide_on_action = 1
let g:sona_window_height = 15
let g:sona_max_results =  100
let g:sona_max_display_results = 50
let g:sona_extra_mapkeys =  []
let g:sona_window_position = 'botright'
let g:sona_mapping = {}
let g:sona_cursor_color = 'ctermbg=250 ctermfg=000 guibg=#efefef guifg=#000000'
let g:sona_match_color = 'ctermbg=NONE ctermfg=111 guibg=NONE guifg=#68a9eb'
let g:sona_text_color = 'ctermbg=NONE ctermfg=118 guibg=NONE guifg=#ffdb72'
let g:sona_mark_color = 'ctermbg=NONE ctermfg=112 guibg=NONE guifg=#99cf50'
let g:sona_line_color = 'ctermbg=NONE ctermfg=140 guibg=NONE guifg=#bcdbff'
let g:sona_column_color = 'ctermbg=NONE ctermfg=118 guibg=NONE guifg=#ffdb72'
let g:sona_kind_color = 'ctermbg=NONE ctermfg=140 guibg=NONE guifg=#bcdbff'
let g:sona_file_color = 'ctermbg=NONE ctermfg=207 guibg=NONE guifg=#ffb3ff'
let g:sona_hide_dark = 'ctermfg=233 guifg=#000'
let g:sona_hide_light = 'ctermfg=254 guifg=#fff'
```

### sona window mappings

```vim
<Esc> or <C-c>		close sona window
<BS>			remove the character on the left of the cursor
<Del>			remove the character on the right of the cursor
<C-w>			delete the word on the left
<C-u>			erase the current input
<Left>			move the cursor left
<Right>			move the cursor right
<Home>			move the cursor at the beginning of input
<End>			move the cursor at the end of input
<C-j>			jump to the first result in the list
<C-k>			jump to the last result in the list
<Tab>			leave the window open and go back to the buffer
<C-i>			toggle the 'ignore case' flag
<C-f>			toggle the 'fuzzy match' flag
<C-y>			toggle the 'save search' flag (keep the results after closing the window)
<C-h>			toggle the 'hide' flag (close the window after using an action)
<C-\>			toggle the 'auto' flag (execute default action with single result)
<C-l>			refresh the results
<C-b>			pick up the previous available group (among gtags, ctags, ag, sona)
<C-d>			pick up the next available group
<C-p>			select the previous source within a group
<C-n>			select the next source within a group
<C-x>			toggle selection (useful for opening multiple files at once)
<CR> or <2-LeftMouse>	execute default action on the current selection
```

### file action mappings

```vim
<C-e>		open the file in the current buffer
<C-t>		open the file in a new tab
<C-h>		open the file in a new horizontal split buffer
<C-v>		open the file in a new vertical split buffer
<C-o>		cycle through all the open modes
```

### file action globals

```vim
" default open mode (t = tab, e = buffer, h = hsplit, v = vsplit)
let g:sona_actions_file_open_mode = 't'
" execute action in a new window
let g:sona_actions_file_open_new_window = 0
```

### file filter globals

```vim
" pattern used to exclude files from the results
let g:sona_filters_file_exclude = ''
```

### ag source globals

```vim
" path to the_silver_searcher executable
let g:sona_sources_ag_cmd = 'ag'
```

### ctags source globals

```vim
" path to exhuberant ctags executable
let g:sona_sources_ctags_ctags_cmd = 'ctags'
" default ctags options
let g:sona_sources_ctags_ctags_opt = '-Rn --languages=c,c++ --c-kinds=+p+x --c++-kinds=+p+x --fields=+iaS --extra=+q'
```

### gtags source globals

```vim
" update the tags when saving files
let g:sona_sources_gtags_auto_update = 1
" path to gtags executable
let g:sona_sources_gtags_gtags_cmd = 'gtags'
" path to global executable
let g:sona_sources_gtags_global_command = 'global'
" protect the pattern (magic chars)
let g:sona_sources_gtags_protect_pattern = 0
```

### gtags source mappings

```vim
<C-g>			toggle the 'protect pattern' flag
```

### sona sources mappings

```vim
<C-a>			list all available sources
```

Simple workflow
=====

I can quickly open a file using `,gf` or open a recent file with `,o`.
If the file I'm looking for is not a C file, I use `,ga`.
If I want to lookup the definition of the tag under the cursor, I use `,]`.
If I want to look for references of the tag under the cursor, I use `,[`.
In order to recall the previous search I issue `,w`.
If I want to leave the search window open I use `<Tab>` to go back to the buffer and `<S-Tab>` to jump back to the search window.
With `,t` I can pop the last tag jump from sona's stack (you can view the stack with `,st`).
The following section provides the full list of mappings I use.

My configuration
=====

```vim
" sona

" options
let g:sona_ignore_case = 0
let g:sona_save_search = 1
let g:sona_fuzzy_pattern = 0
let g:sona_auto_action = 1
let g:sona_hide_on_action = 1

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

	if s:cflags == ''
		call sona#load_cflags()
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

function! sona#load_cflags() " {{{
	if !filereadable('cflags')
		return sona#report('cflags file not found.', 'e')
	endif
	let s:cflags = join(readfile('cflags', '', 1))
endfunction " }}}

function! sona#set_cflags() " {{{
	let l:cflags = input('cflags=', s:cflags)
	if l:cflags != '' && s:cflags != l:cflags
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
	call sona#load_cflags()
	if s:cflags == ''
		let l:include_path = []
		for opt in split(substitute(s:cflags, '-I\s*', '-I', 'g'), ' ')
			if opt =~ "^-I"
				call add(l:include_path, substitute(opt, '-I', '', ''))
			endif
		endfor
		execute printf('set path=.,%s,/usr/include', join(l:include_path, ','))
		call sona#report('Building include paths and cflags done.', 'i')
	endif
endfunction " }}}

" use the cflags '-I' directives to build the include paths (useful with `gf`)
map <silent>	,!	:call sona#build_inc_path()<CR>
" toggle syntax checking on buffer write
map <silent>	,?	:call sona#toggle_syntax_check()<CR>
" show quickfix window if the file errors.err contains something
map <silent>	,.	:call sona#quickfix()<CR>
" edit the cflags file
map <silent>	,%	:call sona#set_cflags()<CR>

augroup sona_syntax_check
	autocmd BufWritePost *.c,*.cc,*.h,*.cpp,*.hpp,*.cxx		:call sona#syntax_check()
augroup END

" vim: fdm=marker
```

The `cflags` file contains only one line with all the flags required to compile a file in your project.
