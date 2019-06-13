function! muttcomplete#FindMailqueryFolder() abort
  if exists('g:mailquery_folder')
    let folder = g:mailquery_folder
  else
    let muttrc = readfile(expand('~/.muttrc'))
    for line in muttrc
      let folder = matchlist(line,'\v^\s*set\s+folder\s*\=\s*[''"]?([^''"]*)[''"]?$')
      if !empty(folder)
        let folder = resolve(expand(folder[1]))
      endif
      echoerr 'Guessed inbox folder by $folder in ~/.muttrc.'
      echoerr 'Please set g:mailquery_folder to mutt inbox folder in vimrc!'
    endfor
  endif
  if !isdirectory(folder)
    echoerr 'No existing $folder in ~/.muttrc found.'
    echoerr 'Please set g:mailquery_folder to mutt inbox folder in vimrc!'
    return ''
  else
    return folder
  endif
endfunction

function! muttcomplete#mailquery(findstart, base) abort
  if a:findstart
    " locate the start of the word
    " we stop when we encounter space character
    let col = col('.')-1
    let text_before_cursor = getline('.')[0 : col - 1]
    " let start = match(text_before_cursor, '\v<([[:digit:][:lower:][:upper:]]+[._%+-@]?)+$')
    let start = match(text_before_cursor, '\v<\S+$')
    return start
  else
    let before = '^[^@]*'
    let base   = escape(a:base, '\-[]{}()*+?.^$|')
    let after  = '[^@]*($|[@])'

    let pattern_begin = '^' . base . after
    let pattern_delim = before . '\b' . base . after
    let pattern = before . base . after

    let inbox_folder = muttcomplete#FindMailqueryFolder()
    if empty(inbox_folder)
      return []
    endif

    let results = []

    if !executable('mail-query')
      echoerr 'No executable mail-query found.'
      echoerr 'Please install mail-query from https://github.com/pbrisbin/mail-query!'
      return []
    endif

    for line in split(system("mail-query" . " '" . pattern . "' " . inbox_folder), '\n')
      if empty(line)
        continue
      endif
      let words = split(line, '\t')
      let dict = {}
      let dict['word'] = words[0]
      let dict['menu'] = words[1]
      " add to the complete list
      call add(results, dict)
    endfor
    return results
  endif
endfunction

