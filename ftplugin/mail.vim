" only enable auto completion in Mutt mails
setlocal omnifunc=mailquery#complete
autocmd BufWinEnter <buffer> call mailquery#SetupMailquery()

