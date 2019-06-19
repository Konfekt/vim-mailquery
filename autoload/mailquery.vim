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
      let output = split(system('mutt -Q "folder"'), '\n')

      for line in output
        let folder = matchlist(line,'\v^\s*' . 'folder' . '\s*\=\s*[''"]?([^''"]*)[''"]?$')
        if !empty(folder)
          let g:mailquery_folder = resolve(expand(folder[1]))
        else
          let g:mailquery_folder = ''
        endif
      endfor
    elseif filereadable(expand('~/.muttrc'))
      " pedestrian's way
      let muttrc = readfile(expand('~/.muttrc'))
      for line in muttrc
        let folder = matchlist(line,'\v^\s*set\s+' . 'folder' . '\s*\=\s*[''"]?([^''"]*)[''"]?$')
        if !empty(folder)
          let folder = resolve(expand(folder[1]))
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

  if !isdirectory(g:mailquery_folder)
    echoerr 'Please set g:mailquery_folder in your vimrc to a valid (mail) folder path!'
    let g:mailquery_folder = ''
  endif

  if !executable('mail-query')
    echoerr 'No executable mail-query found.'
    echoerr 'Please install mail-query from https://github.com/pbrisbin/mail-query!'
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
    let base   = escape(a:base, '\-[]{}()*+?.^$|')
    let after  = '[^@]*($|[@])'
    let pattern_perl = before . base . after

    let lines = split(system("mail-query" . " '" . pattern_perl . "' " . g:mailquery_folder), '\n')

    if empty(lines)
      return
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
      let dict['abbr'] = name
      let dict['menu'] = address

      " weight  according to whether pattern matches at
      " beginning or after delimiter in name or address
      let weight = 0
      if name =~? pattern
        let weight += 1
        if    name =~? pattern_delim
          let weight += 1
          if  name =~? pattern_begin
            let weight += 1
          endif
        endif
      endif
      if address =~? pattern
        let weight += 1
        if    address =~? pattern_delim
          let weight += 1
          if  address =~? pattern_begin
            let weight += 1
          endif
        endif
      endif
      call add(results[weight], dict)
    endfor
    let results = sort(results[6], 1) +
          \ sort(results[5], 1) + sort(results[4], 1) + sort(results[3], 1) +
          \ sort(results[2], 1) + sort(results[1], 1) + sort(results[0], 1)
    return results
  endif
endfunction

