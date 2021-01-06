"*********************************************************************
" COPYRIGHT (C) 2017 Joohyun Lee (juehyun@etri.re.kr)
" 
" MIT License
" 
" Permission is hereby granted, free of charge, to any person obtaining
" a copy of this software and associated documentation files (the
" "Software"), to deal in the Software without restriction, including
" without limitation the rights to use, copy, modify, merge, publish,
" distribute, sublicense, and/or sell copies of the Software, and to
" permit persons to whom the Software is furnished to do so, subject to
" the following conditions:
" 
" The above copyright notice and this permission notice shall be
" included in all copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
" MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
" NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
" LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
" OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
" WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"*********************************************************************


" Plugin to highlight multiple words in different colors.
" Version 2008-11-19 from http://vim.wikia.com/wiki/VimTip1572
" File highlights.csv (in same directory as script) defines the highlights.
"
" Type '\m' to toggle mapping of keypad on/off (assuming \ leader).
" Type '\f' to find the next match; '\F' to find backwards.
" Can also type '\n' or '\N' for search; then n or N will find next.
" On the numeric keypad, press:
"   1 to highlight visually selected text or current word
"     using highlight group hl1 (defined below)
"   2 for highlight hl2, 3 for highlight hl3, etc
"     (can press 1 to 9 on keypad for highlights hl1 to hl9)
"   0 to remove highlight from current word
"   - to remove all highlights in current window
"   + to restore highlights cleared with '-' in current window
"   * to restore highlights (possibly from another window)
" Can press 1 or 2 on main keyboard before keypad 1..9 for more highlights.
" Commands:
"   ':Highlight' list all highlights.
"   ':Highlight [n [pattern]]' set highlight.
"   ':Hsample' display all highlights in a scratch buffer.
"   ':Hclear [hlnum|pattern|*]' clear highlights.
"   ':Hsave x', ':Hrestore x' save/restore highlights (x any name).
" Saving current highlights requires '!' in 'viminfo' option.
if v:version < 702 || exists('loaded_highlightmultiple') || &cp
	finish
endif

let loaded_highlightmultiple = 1
let s:circular_hlnum = 0

"highlight all windows and tabs, and get back to original
"tabdo windo ... command is too slow, therefore, use following trick 
"  DoHighlight(), matching executed using ':windo' command
"  update g:cur_matches whenever DoHighlight()
"  get g:cur_matches and setmatches(g:cur_matches), when 'WinNew', 'TabEnter' event
let s:hl_all_windows_tabs = 1

" On first call, read file highlights.csv in same directory as script.
" For example, line "5,white,blue,black,green" executes:
" highlight hl5 ctermfg=white ctermbg=blue guifg=black guibg=green
let s:data_file = expand('<sfile>:p:r').'.csv'
let s:loaded_data = 0
function! LoadHighlights()
	if !s:loaded_data
		if filereadable(s:data_file)
			let names = ['hl', 'ctermfg=', 'ctermbg=', 'guifg=', 'guibg=']
			for line in readfile(s:data_file)
				let fields = split(line, ',', 1)
				if len(fields) == 5 && fields[0] =~ '^\d\+$'
					let cmd = range(5)
					call map(cmd, 'names[v:val].fields[v:val]')
					call filter(cmd, 'v:val!~''=$''')
					execute 'silent highlight '.join(cmd)
				endif
			endfor
			let s:loaded_data = 1
		endif
		if !s:loaded_data
			echo 'Error: Could not read highlight data from '.s:data_file
		endif
	endif
endfunction

" Return last visually selected text or '\<cword\>'.
" what = 1 (selection), or 2 (cword), or 0 (guess if 1 or 2 is wanted).
function! s:Pattern(what)
	if a:what == 2 || (a:what == 0 && histget(':', -1) =~# '^H')
		let result = expand("<cword>")
		if !empty(result)
			let result = '\<'.result.'\>'
		endif
	else
		let old_reg = getreg('"')
		let old_regtype = getregtype('"')
		normal! gvy
		let result = substitute(escape(@@, '\.*$^~['), '\_s\+', '\\_s\\+', 'g')
		normal! gV
		call setreg('"', old_reg, old_regtype)
	endif
	return result
endfunction

" At first, remove highlighting for hlnum then highlight pattern (if not empty).
" If pat is numeric, use current word or visual selection (i.e. s:Pattern(a.pat) )
" otherwise, pat is treated as pattern string
function! s:DoHighlight(hlnum, pat)
	call LoadHighlights()
	let hltotal = a:hlnum
	"check a:pat is v:number type
	if type(a:pat) == type(0)
		let pattern = s:Pattern(a:pat)
	else
		let pattern = a:pat
	endif
	let id = hltotal + 100
	if s:hl_all_windows_tabs
		let l:wid = win_getid()
		silent! windo call matchdelete(id)
		call win_gotoid(l:wid)
		let g:cur_matches = getmatches()
	else
		silent! call matchdelete(id)
	endif
	if !empty(pattern)
		try
			if s:hl_all_windows_tabs
				let l:wid = win_getid()
				windo call matchadd('hl'.hltotal, pattern, -1, id)
				call win_gotoid(l:wid)
				let g:cur_matches = getmatches()
			else 
				call matchadd('hl'.hltotal, pattern, -1, id)
			endif
		catch /E28:/
			echo 'Highlight hl'.hltotal.' is not defined'
		endtry
	endif
endfunction


" Remove all matches for a pattern.
function! s:ClearOneHighlight(pat)
	if type(a:pat) == type(0)
		let pattern = s:Pattern(a:pat)
	else
		let pattern = a:pat
	endif
	for m in getmatches()
		if m.pattern ==# pattern
			if s:hl_all_windows_tabs
				let l:wid = win_getid()
				windo call matchdelete(m.id)
				call win_gotoid(l:wid)
				let g:cur_matches = getmatches()
			else
				call matchdelete(m.id)
			endif
		endif
	endfor
endfunction


" Return pattern to search for next match, and do search.
function! s:Search(backward)
	let patterns = []
	for m in getmatches()
		call add(patterns, m.pattern)
	endfor
	if empty(patterns)
		let pat = ''
	else
		let pat = join(patterns, '\|')
		call search(pat, a:backward ? 'b' : '')
	endif
	return pat
endfunction


" Clear Highlights
function! s:ClearAllHighlight()
	if s:hl_all_windows_tabs
		let l:wid = win_getid()
		windo call clearmatches()
		call win_gotoid(l:wid)
		let g:cur_matches = getmatches()
	else
		call clearmatches()
	endif
endfunction


" Return name of global variable to save value ('' if invalid).
function! s:NameForSave(name)
	if a:name =~# '^\w*$'
		return 'HI_SAVE_'.toupper(a:name)
	endif
	echo 'Error: Invalid name "'.a:name.'"'
	return ''
endfunction

" Return custom completion string (match patterns).
function! s:MatchPatterns(A, L, P)
	return join(sort(map(getmatches(), 'v:val.pattern')), "\n")
endfunction

" Return custom completion string (saved highlight names).
function! s:SavedNames(A, L, P)
	let l = filter(keys(g:), 'v:val =~# ''^HI_SAVE_\w''')
	return tolower(join(sort(map(l, 'strpart(v:val, 8)')), "\n"))
endfunction

" Save current highlighting in a global variable.
" e.g.  call s:Hsave('')
function! s:Hsave(name)
	let sname = s:NameForSave(a:name)
	if !empty(sname)
		let l = getmatches()
		call map(l, 'join([v:val.group, v:val.pattern, v:val.priority, v:val.id], "\t")')
		let g:{sname} = join(l, "\n")
	endif
endfunction
command! -nargs=? -complete=custom,s:SavedNames Hsave call s:Hsave('<args>')

" Restore current highlighting from a global variable.
" e.g. call s:Hrestore('')
function! s:Hrestore(name)
	call LoadHighlights()
	let sname = s:NameForSave(a:name)
	if !empty(sname)
		if exists('g:{sname}')
			let matches = []
			for l in split(g:{sname}, "\n")
				let f = split(l, "\t", 1)
				call add(matches, {'group':f[0], 'pattern':f[1], 'priority':f[2], 'id':f[3]})
			endfor
			call setmatches(matches)
		else
			echo 'No such global variable: '.sname
		endif
	endif
endfunction
command! -nargs=? -complete=custom,s:SavedNames Hrestore call s:Hrestore('<args>')

" Clear a match, or clear all current matches. Example args:
"   '14' = hl14, '*' = all, '' = visual selection or cword,
"   'pattern' = all matches for pattern
function! s:Hclear(pattern) range
	if empty(a:pattern)
		call s:ClearOneHighlight(0)
	elseif a:pattern == '*'
		call s:ClearAllHighlight()
	elseif a:pattern =~ '^[1-9][0-9]\?$'
		call s:DoHighlight(str2nr(a:pattern), '')
	else
		call s:ClearOneHighlight(a:pattern)
	endif
endfunction
command! -nargs=* -complete=custom,s:MatchPatterns -range Hclear call s:Hclear('<args>')

" Create a scratch buffer with sample text, and apply all highlighting.
function! s:Hsample()
	call LoadHighlights()
	new
	setlocal buftype=nofile bufhidden=hide noswapfile
	let lines = []
	let items = []
	for hl in filter(range(1, 99), 'v:val % 10 > 0')
		if hlexists('hl'.hl)
			let sample = printf('Sample%2d', hl)
			call s:DoHighlight(hl, sample)
		else
			let sample = '        '
		endif
		call add(items, sample)
		if len(items) >= 3
			call insert(lines, substitute(join(items), '\s\+$', '', ''))
			let items = []
		endif
	endfor
	call append(0, filter(lines, 'len(v:val) > 0'))
	$d
	%s/\d3$/&\r/e
endfunction
command! Hsample call s:Hsample()

" Set a match, or display all current matches. Example args:
"   '14' = set hl14 for visual selection or cword,
"   '14 pattern' = set hl14 for pattern, '' = display all
function! s:Highlight(args) range
	if empty(a:args)
		echo 'Highlight groups and patterns:'
		for m in getmatches()
			echo m.group m.pattern
		endfor
		return
	endif
	let l = matchlist(a:args, '^\s*\([1-9][0-9]\?\)\%($\|\s\+\(.*\)\)')
	if len(l) >= 3
		let hlnum = str2nr(l[1])
		let pattern = l[2]
		if empty(pattern)
			let pattern = s:Pattern(0)
		endif
		call s:DoHighlight(hlnum, pattern)
		return
	endif
	echo 'Error: First argument must be highlight number 1..99'
endfunction
command! -nargs=* -range Highlight call s:Highlight('<args>')


" Enable or disable mappings and any current matches.
function! s:ToggleMultiHL()
	if exists('g:match_maps') && g:match_maps
		let g:match_maps = 0
		call s:DisableMultiHL()
	else
		let g:match_maps = 1
		call s:EnableMultiHL()
	endif
	call s:StoreClsLoadHighlight(g:match_maps)
	echo 'Mappings for matching:' g:match_maps ? 'ON' : 'off'
endfunction
nnoremap <silent> <Leader>m :call <SID>ToggleMultiHL()<CR>

" Disable
function! s:DisableMultiHL()
	for i in range(0, 9)
		execute 'unmap \'.i.''
	endfor
	 
	nunmap \=
	vunmap \=
	nunmap &
	vunmap &
	nunmap \-
	vunmap \-
	
	nunmap \\
	nunmap \f
	nunmap \F
	nunmap \n
	nunmap \N
endfunction

" Enable 
function! s:EnableMultiHL()
	for i in range(0, 9)
		"execute 'vnoremap <silent> \'.i.' :<C-U>call <SID>DoHighlight('.i.', 1, v:count)<CR>'
		"execute 'nnoremap <silent> \'.i.' :<C-U>call <SID>DoHighlight('.i.', 2, v:count)<CR>'
		execute 'vnoremap <silent> \'.i.' :call <SID>DoHighlight('.i.', 1)<CR>'
		execute 'nnoremap <silent> \'.i.' :call <SID>DoHighlight('.i.', 2)<CR>'
	endfor
	
	vnoremap <silent> \=  :call <SID>DoHighlightCircular(1)<CR>
	nnoremap <silent> \=  :call <SID>DoHighlightCircular(2)<CR>
	vnoremap <silent> &   :call <SID>DoHighlightCircular(1)<CR>
	nnoremap <silent> &   :call <SID>DoHighlightCircular(2)<CR>
	vnoremap <silent> \-  :call <SID>ClearOneHighlight(1)<CR>
	nnoremap <silent> \-  :call <SID>ClearOneHighlight(2)<CR>
	nnoremap <silent> \\  :call <SID>ClearAllHighlight()<CR>
	nnoremap <silent> \f  :call <SID>Search(0)<CR>
	nnoremap <silent> \F  :call <SID>Search(1)<CR>
	nnoremap <silent> \n  :let @/=<SID>Search(0)<CR>
	nnoremap <silent> \N  :let @/=<SID>Search(1)<CR>
	nnoremap <silent> \s  :call <SID>Hsave('')<CR>
	nnoremap <silent> \r  :call <SID>Hrestore('')<CR>
endfunction

function! s:DoHighlightCircular(pat)
	call s:DoHighlight(s:circular_hlnum, a:pat)
	
	if(s:circular_hlnum==26)
		let s:circular_hlnum = 0
	else
		let s:circular_hlnum += 1
	endif
	
endfunction


function! s:ApplyHighlight()
	if s:hl_all_windows_tabs
		if exists('g:cur_matches')
			let l:wid = win_getid()
			windo call setmatches(g:cur_matches)
			call win_gotoid(l:wid)
		endif
	endif
endfunction


"do not use 'BufEnter' event
"'BufEnter' event was occurred recursely by :windo command
autocmd! TabEnter,WinNew * call <SID>ApplyHighlight()

call <SID>EnableMultiHL()
