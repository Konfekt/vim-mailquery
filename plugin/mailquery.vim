if exists('g:loaded_mailquery') || &cp
  finish
endif
let g:loaded_mailquery = 1

let s:keepcpo         = &cpo
set cpo&vim
" ------------------------------------------------------------------------------

if !exists('g:mailquery_filetypes')
  let g:mailquery_filetypes = [ 'mail' ]
endif

let s:fts = ''
for ft in g:mailquery_filetypes
  let s:fts .= ft . ','
endfor
let s:fts = s:fts[:-1]

command! MailqueryCompletion call s:mailquery()

function! s:mailquery() abort
  call mailquery#SetupMailquery()
  setlocal omnifunc=mailquery#complete
endfunction

augroup mailquery
  autocmd!
  exe 'autocmd FileType' s:fts 'MailqueryCompletion'
augroup end

" ------------------------------------------------------------------------------
let &cpo= s:keepcpo
unlet s:keepcpo
