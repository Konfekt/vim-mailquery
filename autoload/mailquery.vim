function! mailquery#SetupMailquery() abort
  " Setup g:mailquery_filter
  if !exists('g:mailquery_filter')
    let g:mailquery_filter = 0
  elseif g:mailquery_filter
    " Setup g:mailquery_filter_regex
    if !exists('g:mailquery_filter_regex')
      let g:mailquery_filter_regex = '\v^[[:alnum:]._%+-]*%([0-9]{9,}|([0-9]+[a-z]+){3,}|\+|not?([-_.])?reply|<(un)?subscribe>|<MAILER\-DAEMON>)[[:alnum:]._%+-]*\@'
    endif
  endif
  " Setup g:mailquery_folder
  if !exists('g:mailquery_folder')
    if executable('mutt')
      silent let output = split(system('mutt -Q "folder"'), '\n')

      for line in output
        let folder = matchstr(line,'\v^\s*' . 'folder' . '\s*\=\s*[''"]?' . '\zs[^''"]*\ze' . '[''"]?$')
        if !empty(folder)
          let g:mailquery_folder = resolve(expand(folder))
        else
          let g:mailquery_folder = ''
        endif
      endfor
    elseif filereadable(expand('~/.muttrc'))
      " pedestrian's way
      let muttrc = readfile(expand('~/.muttrc'))
      for line in muttrc
        let folder = matchstr(line,'\v^\s*set\s+' . 'folder' . '\s*\=\s*[''"]?' . '\zs[^''"]*\ze' . '[''"]?$')
        if !empty(folder)
          let folder = resolve(expand(folder))
          let g:mailquery_folder = folder
        endif
      endfor
    else
      let g:mailquery_folder = ''
    endif
    if !empty(g:mailquery_folder)
      echomsg 'Guessed mail folder by value of $folder in ~/.muttrc to be ' . g:mailquery_folder . '.'
      " echohl 'Please set g:mailquery_folder in your vimrc to a mail folder!'
    endif
  endif

  " check whether Perl module to decode MIME headers is installed
  " thanks to https://stackoverflow.com/a/15162063
  if !exists('s:mailquery_mimeheader')
    let s:mailquery_mimeheader = 0
    if executable('perl')
      silent call system("perl -e 'use Encode::MIME::Header;'")
      if v:shell_error == 0
        let s:mailquery_mimeheader = 1
      endif
    endif
  endif

  if !isdirectory(g:mailquery_folder)
    echoerr 'Please set g:mailquery_folder in your vimrc to a valid (mail) folder path!'
    let g:mailquery_folder = ''
  endif

  if !exists('s:mailquery_executable') 
    if executable('mail-query')
      let s:mailquery_executable = 1
    else
      echoerr 'No executable mail-query found.'
      echoerr 'Please install mail-query from https://github.com/pbrisbin/mail-query!'
      let s:mailquery_executable = 0
    endif
  endif
endfunction

function! mailquery#complete(findstart, base) abort
  if a:findstart
    " locate the start of the word
    " we stop when we encounter space character
    let col = col('.')-1
    let text_before_cursor = getline('.')[0 : col - 1]
    " let start = match(text_before_cursor, '\v<([[:digit:][:lower:][:upper:]]+[._%+-@]?)+$')
    let start = match(text_before_cursor, '\v<\S+$')
    return start
    " build perl regex for mail-query
  else
    if empty(g:mailquery_folder)
      return []
    endif

    let before = '^[^@]*'
    let base = a:base
    if base =~# '[^\x00-\x7F]' && s:mailquery_mimeheader
      silent let base = system("perl -CS -MEncode -ne 'print encode(\"MIME-Q\", $_)'", base)
      let base = matchstr(base, '\c\v^\V=?UTF-8?Q?\v\zs.*\ze\V?=\v$')
    endif
    let base   = escape(base, '\-[]{}()*+?.^$|')
    let after  = '[^@]*($|[@])'
    let pattern_perl = before . base . after

    let lines = []
    if s:mailquery_executable
      silent let lines = split(system("mail-query" . " '" . pattern_perl . "' " . g:mailquery_folder), '\n')
    endif
    " convert MIME headers via Perl thanks to https://superuser.com/a/972248
    if s:mailquery_mimeheader
      silent let lines = split(system("perl -CS -MEncode -ne 'print decode(\"MIME-Header\", $_)'", lines), '\n')
    endif

    if empty(lines)
      return []
    endif

    " build vim regex to sort according to whether pattern matches at
    " beginning or after delimiter
    let before = '\v^[^@]*'
    let base   = '\V' . escape(a:base, '\')
    let after  = '\v[^@]*($|[@])'

    let pattern       = before . base . after
    let pattern_delim = before . '\v(^|\A)' . base . after
    let pattern_begin = '\v^' . base . after

    let results = [ [], [], [], [], [], [], [] ]
    for line in lines
      if empty(line)
        continue
      endif

      let words = split(line, '\t')

      if len(words) < 2
        continue
      endif

      let dict = {}
      let address = words[0]

      " skip impersonal addresses
      if g:mailquery_filter && address =~? g:mailquery_filter_regex
        continue
      endif

      " remove double quotes
      let name = substitute(words[1], '\v^"|"$', '', 'g')

      " add to completion menu
      let dict['word'] = name . ' <' . address . '>'
      let dict['abbr'] = strlen(name) < 35 ? name : name[0:30] . '...'
      let dict['menu'] = address

      " weigh according to whether pattern matches at
      " beginning or after some delimiter in name or address
      let pertinence = 0
      if name =~? pattern
        let pertinence += 1
        if    name =~? pattern_delim
          let pertinence += 1
          if  name =~? pattern_begin
            let pertinence += 1
          endif
        endif
      endif
      if address =~? pattern
        let pertinence += 1
        if    address =~? pattern_delim
          let pertinence += 1
          if  address =~? pattern_begin
            let pertinence += 1
          endif
        endif
      endif
      call add(results[pertinence], dict)
    endfor
    let results = uniq(sort(results[6], 1) +
          \ sort(results[5], 1) + sort(results[4], 1) + sort(results[3], 1) +
          \ sort(results[2], 1) + sort(results[1], 1) + sort(results[0], 1),
          \ 1)
    return results
  endif
endfunction
