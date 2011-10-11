" Vim colorscheme file

highlight clear
if exists('syntax_on')
    syntax reset
endif
let g:colors_name = 'scheakur'

" base colors and attributes
let s:base_args = ['#2e2e2e', '#f2f2e7', 'none']
" constants
let s:base = '_base_'
" highlighting properties
let s:props = {}
let s:colors = {}

" functions for highlighting " {{{
function! s:hi(group, ...) " fg, bg, attr
    let s:props[a:group] = a:000
endfunction

function! s:color(name, color)
    let s:colors[a:name] = a:color
endfunction

function! s:do_highlight()
    for group in keys(s:props)
        let args = s:props[group]
        let fg = s:get(args, 0, '')
        let bg = s:get(args, 1, '')
        let attr = s:get(args, 2, '')
        if fg != ''
            execute 'hi ' . group . ' ctermfg=' . s:tco(fg) . ' guifg=#' . fg
        endif
        if bg != ''
            execute 'hi ' . group . ' ctermbg=' . s:tco(bg) . ' guibg=#' . bg
        endif
        if attr != ''
            execute 'hi ' . group . ' term=' . attr . ' cterm=' . attr . ' gui=' . attr
        endif
    endfor
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
        let newArgs = get(props, val, [])
        if empty(newArgs)
            return ''
        endif
        call remove(props, val)
        return s:get(newArgs, a:index, a:default, props)
    endif
    " Starting with '@' means a color reference
    if val =~ '^\$'
        let val = strpart(val, 1)
        let val = get(s:colors, val, '')
        let newArgs = copy(a:args)
        let newArgs[a:index] = val
        if (a:0 > 0)
            return s:get(newArgs, a:index, a:default, a:1)
        else
            return s:get(newArgs, a:index, a:default)
        endif
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
    let r = float2nr(5.0 * a:r / 255.0 + 0.5)
    let g = float2nr(5.0 * a:g / 255.0 + 0.5)
    let b = float2nr(5.0 * a:b / 255.0 + 0.5)
    let c = 16 + (r * 36) + (g * 6) + (b)
    return c
endfunction

function! s:rgb2gray(r, g, b)
    let gray = float2nr(23.0 * (a:r + a:g + a:b) / 3.0 / 255.0 + 0.5)
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
call s:color('frame', '#4a4642')
call s:color('hilite', '#f4b3c2')

" highlights " {{{
call s:hi('Normal', s:base, s:base, s:base)
call s:hi('Cursor', '', '#f39812')
call s:hi('CursorIM', '#fededa', '#47885e')
call s:hi('CursorColumn', '', '#e9edf3')
call s:hi('CursorLine', '', '#e9edf3')
call s:hi('Directory', '#1177dd')
call s:hi('DiffAdd', s:base, '#ddeedd')
call s:hi('DiffChange', s:base, '#ffffcc')
call s:hi('DiffDelete', s:base, '#ffdddd')
call s:hi('DiffText', s:base, '#aaffaa')
call s:hi('Folded', '#1e8b98', s:base, 'underline')
call s:hi('FoldColumn', '@Folded', '@Folded', 'reverse')
call s:hi('LineNr', '#567686', '#f2f2e6')
call s:hi('ModeMsg', '#4085aa')
call s:hi('MoreMsg', '#2e8b57')
call s:hi('WarningMsg', '#fa8072')
call s:hi('ErrorMsg', '@Error', '@Error')
call s:hi('NonText', '#666699')
call s:hi('Question', '#008080')
call s:hi('IncSearch', s:base, '$hilite', 'none')
call s:hi('Search', s:base, '#cecece')
call s:hi('SpecialKey', '#667788')
call s:hi('StatusLine', '#dcdcdc', '$frame', 'none')
call s:hi('StatusLineNC', '@StatusLine', '#7a7672', 'italic')
call s:hi('VertSplit', '$frame', '$frame', 'none')
call s:hi('Visual', '', '#cce0ef')
call s:hi('Title', '#cd5c5c')
call s:hi('Pmenu', s:base, '#faebf0')
call s:hi('PmenuSel', s:base, '$hilite')
call s:hi('PmenuSbar', '', '@Pmenu')
call s:hi('PmenuThumb', '$hilite')

call s:hi('Comment', '#2e8b57', '#ddf1dd')
call s:hi('Comment', '#316745', '#ddf1dd')

call s:hi('Constant', '#aa6622')
call s:hi('Number', '#59823e')
call s:hi('Identifier', '#3a9a8d')
call s:hi('Statement', '#1177dd', '', s:base)
call s:hi('String', '#2a4fad')
call s:hi('PreProc', '#d4772c')
call s:hi('Conditional', '#aa3232')
call s:hi('Special', '#e95295')
" call s:hi('Operator', '#ef3d3d', '#ffe3e5')
call s:hi('Type', '#ef5623', '', s:base)
call s:hi('Repeat', '#1e7b47')
call s:hi('Function', '#664499')
call s:hi('Delimiter', '#a04f20')
call s:hi('MatchParen', '#0e8ed3', '#dbf2ff')
call s:hi('Ignore', '#666666')
call s:hi('Todo', '#6a5d21', '#fdfec9')
call s:hi('Error', '#d1160b', '#ffe3e5')

" for JavaScript
call s:hi('javaScriptDocParam', '@Statement', '@Comment')
call s:hi('javaScriptDocType', '@Type', '@Comment')
call s:hi('javaScriptDocTypeNoParam', '@Type', '@Comment')
call s:hi('javaScriptDocTags', '@Special', '@Comment')
call s:hi('javaScriptDocSeeTag', '@Function', '@Comment')

" VimFiler
hi def link VimFilerCurrentDirectory Statement

" }}}

" Highlight!
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
unlet s:colors
" }}}

