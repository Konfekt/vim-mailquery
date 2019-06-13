" only enable auto completion in Mutt mails
autocmd BufRead,BufNewFile,BufFilePost mutt{ng,}-*-\w\+,mutt[[:alnum:]_-]\\\{6\}
      \ setlocal omnifunc=mailquery#complete |
      \ autocmd BufWinEnter <buffer> call mailquery#SetMailqueryFolder()

