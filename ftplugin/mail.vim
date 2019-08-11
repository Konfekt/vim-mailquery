setlocal omnifunc=mailquery#complete
autocmd BufWinEnter <buffer> call mailquery#SetupMailquery()

