function! mailquery#SetMailqueryFolder() abort
  if !executable('mail-query')
    echoerr 'No executable mail-query found.'
    echoerr 'Please install mail-query from https://github.com/pbrisbin/mail-query!'
    let g:mailquery_folder = ''
  endif

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
  else
    let before = '^[^@]*'
    let base   = escape(a:base, '\-[]{}()*+?.^$|')
    let after  = '[^@]*($|[@])'

    let pattern_begin = '^' . base . after
    let pattern_delim = before . '\b' . base . after
    let pattern = before . base . after

    let results = []

    if empty(g:mailquery_folder)
      return results
    else
      for line in split(system("mail-query" . " '" . pattern . "' " . g:mailquery_folder), '\n')
        if empty(line)
          continue
        endif
        let words = split(line, '\t')
        let dict = {}
        let address = words[0]
        let name = substitute(words[1], '\v^"|"$', '', 'g')
        let dict['word'] = name . ' <' . address . '>'
        let dict['abbr'] = name
        let dict['menu'] = address
        " add to the complete list
        call add(results, dict)
      endfor
      return results
    endif
  endif
endfunction

