This plug-in lets you complete e-mail addresses in Vim by those in your inbox
(or any other mail folder) via [mail-query](https://github.com/pbrisbin/mail-query).

# Commands

To complete an e-mail address inside Vim press `CTRL-X CTRL-O` in insert
mode. See `:help i_CTRL-X_CTRL-O` and `:help compl-omni`.

# Config

To set the path to your mail folder `$folder` add to your `.vimrc` the line

```vim
  let g:mailquery_folder = '$folder'
```

For example, if you use mbsync, a possible value of `$folder` would be

```sh
  $XDG_DATA_HOME/mbsync/INBOX/cur
```

