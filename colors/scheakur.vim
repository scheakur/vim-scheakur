" Vim colorscheme file

highlight clear
if exists('syntax_on')
	syntax reset
endif
let g:colors_name = 'scheakur'

" base colors and attributes
let s:base_args = ['#2e2e2e', '#f2f2e7', 'none', 234, 255, 'none']
" constants
let s:base = '_base_'
" highlighting properties
let s:props = {}

" functions for highlighting " {{{
function! s:hi(group, ...) " fg, bg, attr, term_fg, term_bg, term_attr
	let s:props[a:group] = a:000
endfunction

function! s:copy(group, orig_group)
	let orig = a:orig_group
	call s:hi(a:group, orig, orig, orig, orig, orig, orig)
endfunction


function! s:do_highlight()
	for group in keys(s:props)
		let args = s:props[group]

		let fg = s:get(args, 0, '')
		let bg = s:get(args, 1, '')
		let attr = s:get(args, 2, '')

		let term_fg = s:get(args, 3, '')
		let term_bg = s:get(args, 4, '')
		let term_attr = s:get(args, 5, '')

		if attr == 'undercurl'
			execute 'hi ' . group
			\	. ' ctermfg=' . s:tco(fg)
			\	. ' guisp=#' . fg
			\	. ' cterm=underline gui=' . attr
			call s:apply(group, 'bg', bg, term_bg)
			continue
		endif

		call s:apply(group, 'fg', fg, term_fg)
		call s:apply(group, 'bg', bg, term_bg)
		call s:apply(group, '', attr, term_attr)
	endfor
endfunction


function! s:apply(group, key, val, term_val)
	if empty(a:val)
		return
	endif
	let term_val =
	\	!empty(a:term_val) ? a:term_val :
	\	empty(a:key) ? a:val :s:tco(a:val)
	let gui_val = empty(a:key) ? a:val : ('#' . a:val)
	execute 'hi ' . a:group
	\	. ' cterm' . a:key . '=' . term_val
	\	. ' gui' . a:key . '=' . gui_val
endfunction


function! s:get(args, index, default, ...)
	let val = s:get_val(a:args, a:index, a:default)
	if val == ''
		return val
	endif
	" rgb color
	if val =~ '^#[a-fA-F0-9]\{6\}'
		return strpart(val, 1)
	endif
	" Starting with '@' means a syntax group reference
	if val =~ '^@'
		let val = strpart(val, 1)
		let props = (a:0 > 0) ? a:1 : copy(s:props)
		let new_args = get(props, val, [])
		if empty(new_args)
			return ''
		endif
		call remove(props, val)
		return s:get(new_args, a:index, a:default, props)
	endif
	" attribute
	return val
endfunction

function! s:get_val(args, index, default)
	let val = get(a:args, a:index, a:default)
	if val == s:base
		return get(s:base_args, a:index, '')
	endif
	if val != ''
		return val
	endif
	return a:default
endfunction

" Terminal COlor
function! s:tco(rgb)
	let r = ('0x' . strpart(a:rgb, 0, 2)) + 0
	let g = ('0x' . strpart(a:rgb, 2, 2)) + 0
	let b = ('0x' . strpart(a:rgb, 4, 2)) + 0
	let c = s:rgb2tco(r, g, b)
	return c
endfunction

function! s:rgb2tco(r, g, b)
	if s:rgb_is_gray(a:r, a:g, a:b)
		return s:rgb2gray(a:r, a:g, a:b)
	else
		return s:rgb2color(a:r, a:g, a:b)
	endif
endfunction

function! s:rgb2color(r, g, b)
	let r = float2nr(5.0 * a:r / 255.0 - 0.45)
	let g = float2nr(5.0 * a:g / 255.0 - 0.45)
	let b = float2nr(5.0 * a:b / 255.0 - 0.45)
	let r = (r < 0) ? 0 : r
	let g = (g < 0) ? 0 : g
	let b = (b < 0) ? 0 : b
	let c = 16 + (r * 36) + (g * 6) + (b)
	return c
endfunction

function! s:rgb2gray(r, g, b)
	let gray = float2nr(23.0 * (a:r + a:g + a:b) / 3.0 / 255.0 - 0.45)
	let gray = (gray < 0) ? 0 : gray
	let gray += 232
	return gray
endfunction

function! s:rgb_is_gray(r, g, b)
	let r = a:r * a:r
	let g = a:g * a:g
	let b = a:b * a:b
	let a = (r + g + b) / 3.0 " average
	let t = 1500.0 " threshold
	if (abs(a -r) < t && abs(a - g) < t && abs(a - b) < t)
		return 1
	endif
	return 0
endfunction
" }}}

" named colors
let s:frame = '#4a4642'


" highlights " {{{
function! s:set_highlight()
	let _ = ''

	call s:hi('Normal', s:base, s:base, s:base, s:base, s:base, s:base)
	call s:hi('Cursor', _, '#f39812')
	call s:hi('CursorIM', '#fededa', '#47885e')
	call s:hi('CursorLine', _, '#fafaf7')
	call s:hi('CursorColumn', _, '@CursorLine')
	call s:hi('Directory', '#1177dd')
	call s:hi('Folded', '#04530d', '#d0ead0')
	call s:hi('FoldColumn', '@Folded', '@Folded')
	call s:hi('LineNr', '#567686', '#e2e2d0', _, 236)
	call s:hi('CursorLineNr', '@LineNr', '@CursorLine', 'none')
	call s:hi('ModeMsg', '#337ca3')
	call s:hi('MoreMsg', '#1e7b3d')
	call s:hi('WarningMsg', '#ea6042')
	call s:copy('ErrorMsg', '@Error')
	call s:hi('NonText', '#7878ba', _, s:base)
	call s:hi('Question', '#008080')
	call s:hi('IncSearch', s:base, '#f4b3c2', s:base, s:base, 218)
	call s:hi('Search', s:base, '#e9e7ac')
	call s:hi('SpecialKey', '#aabbcc')
	call s:hi('StatusLine', '#dcdcdc', s:frame, 'none')
	call s:hi('StatusLineNC', '@StatusLine', '#7a7672', 'italic')
	call s:hi('VertSplit', s:frame, s:frame, 'none')
	call s:hi('Visual', _, '#cce0ef', _, _, 153)
	call s:hi('TabLine', '@StatusLine', '@StatusLine', '@StatusLine')
	call s:hi('TabLineFill', '@StatusLine', '@StatusLine', '@StatusLine')
	call s:hi('TabLineSel', s:frame, _, s:base)
	call s:hi('Title', '@Special', _, s:base)
	call s:hi('Pmenu', s:base, '#f6e4e7', _, _, 231)
	call s:copy('PmenuSel', '@IncSearch')
	call s:hi('PmenuSbar', _, '@Pmenu')
	call s:hi('PmenuThumb', '@PmenuSel')
	call s:hi('Comment', '#506a78', _)
	call s:hi('ColorColumn', _, '#dfd6d1')

	call s:hi('Constant', '#1a7931')
	call s:hi('Identifier', '#1a5991')
	call s:hi('Statement', '#0c71d5', _, s:base)
	call s:hi('String', '#0b3fad')
	call s:hi('PreProc', '#6b118a')
	call s:hi('Operator', '@PreProc')
	call s:hi('Special', '#141784')
	call s:hi('Type', '#1a7931', _, s:base)
	call s:hi('Type', '#bd3b09', _, s:base)
	call s:hi('Function', '#cb1265')
	call s:hi('MatchParen', '#0e8ed3', '#dbf2ff')
	call s:hi('Ignore', '#666666')
	call s:hi('Todo', '#4d4214', '#fdfec9', _, _, 229)
	call s:hi('Error', '#d1160b', '#ffe3e5', _, _, 223)
	call s:hi('Underlined', '#2358ba')
	call s:hi('Tag', '#a25a09')
	call s:copy('WildMenu', '@IncSearch')
	call s:hi('SignColumn', s:base, _)
	call s:hi('SpellBad', '@Error', '@Error', 'undercurl', _, '@Error')
	call s:hi('SpellCap', '@String', '@MatchParen', 'undercurl')
	call s:hi('SpellRare', '@Folded', '@Folded', 'undercurl')
	call s:hi('SpellLocal', '@Todo', '@Todo', 'undercurl', _, '@Todo')
	call s:hi('DiffAdd', s:base, '@SpellRare')
	call s:hi('DiffChange', s:base, '@SpellLocal', _, _, '@Todo')
	call s:hi('DiffDelete', s:base, '@SpellBad', _, _, '@Error')
	call s:hi('DiffText', s:base, '@SpellCap')
endfunction
" }}}

" Highlight!
call s:set_highlight()
call s:do_highlight()

" cleanup {{{
" TODO need ?
delfunction s:do_highlight
delfunction s:hi
delfunction s:get
delfunction s:get_val
delfunction s:tco
delfunction s:rgb2tco
delfunction s:rgb_is_gray
delfunction s:rgb2gray
delfunction s:rgb2color
unlet s:base_args
unlet s:base
unlet s:props
unlet s:frame
" }}}

