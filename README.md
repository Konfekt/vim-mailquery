This plug-in lets you complete e-mail addresses in Vim by those in your inbox (or any other mail folder) via [mail-query](https://github.com/pbrisbin/mail-query).

# Commands

To complete an e-mail address inside Vim press `CTRL-X CTRL-O` in insert
mode. See `:help i_CTRL-X_CTRL-O` and `:help compl-omni`.

# Setup

Download and compile [mail-query](https://github.com/pbrisbin/mail-query) and add the path (say `~/bin` or `%USERPROFILE%\bin`) of the folder that contains the obtained executable `mail-query` to your environment variable `$PATH` (on Linux) respectively `%PATH%` (on Microsoft Windows):

- on Linux, if you use `bash` or `zsh` by adding to `~/.profile` or `~/.zshenv` the line

```sh
    PATH=$PATH:~/bin
```

- on Microsoft Windows, a convenient program to update `%PATH%` is [Rapidee](http://www.rapidee.com/).


To set the path to your mail folder `$folder` add to your `.vimrc` the line

```vim
  let g:mailquery_folder = '$folder'
```

For example, if you use mbsync, a possible value of `$folder` would be

```sh
  $XDG_DATA_HOME/mbsync/INBOX/cur
```

# Related Plug-ins

The [vim-mutt-aliases](https://github.com/Konfekt/vim-mutt-aliases) plug-in lets you complete e-mail addresses in Vim by those in your `mutt` alias file.
