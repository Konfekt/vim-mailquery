This plug-in lets you complete e-mail addresses in Vim by those found in your inbox (or any other mail folder) via [mail-query](https://github.com/pbrisbin/mail-query).
Useful, for example, when using `Vim` as editor for `mutt` (especially with `$edit_headers` set).

# Usage

When you're editing a mail file in Vim that reads
```mail
    From: Fulano <Fulano@Silva.com>
    To:   foo
```
and in your Inbox there is an e-mail from
```mail
    Mister Foo <foo@bar.com>
```
and your cursor is right after `foo`, then hit `Ctrl+X Ctrl+O` to obtain:
```mail
    From: Fulano <Fulano@Silva.com>
    To:   Mister Foo <foo@bar.com>
```

# Commands

To complete an e-mail address inside Vim press `CTRL-X CTRL-O` in insert
mode. See `:help i_CTRL-X_CTRL-O` and `:help compl-omni`.

# Setup

1. Download and install (by `sudo make install`) [mail-query](https://github.com/pbrisbin/mail-query).
    If you are missing superuser rights, then compile it (by `make`) add the path of the folder that contains the obtained executable `mail-query` (say `~/bin`) to your environment variable `$PATH`:
    If you use `bash` or `zsh`, by adding to `~/.profile` or `~/.zshenv` the line

    ```sh
        PATH=$PATH:~/bin
    ```
    
    To decode [7-bit ASCII encoded MIME-headers](https://tools.ietf.org/html/rfc2047) (which start, for example, with `=?UTF-8?Q?` or `=?ISO-8859-1?Q?`), ensure that `perl` is executable and the [Encode::MIME:Header](https://perldoc.perl.org/Encode/MIME/Header.html) module is installed.
    Please note that if completing non-`ASCII` characters, then only `UTF-8` encoded non-`ASCII` characters in the mail folder can be found, but none encoded in `ISO-8859-1(5)` or any other encoding (common before the advent of `UTF-8` in the nineties).

2. The mail folder is automatically set to the value of the variable `$folder` in the file `~/.muttrc`.
    To explicitly set the path to a mail folder `$folder`, add to your `.vimrc` the line

    ```vim
    let g:mailquery_folder = '$folder'
    ```

    For example, if you use `mbsync`, then `$folder` could be

    ```sh
    $XDG_DATA_HOME/mbsync/INBOX/cur
    ```

3. If you would like to filter out most probably impersonal e-mail addresses such as those that come from mailer daemons or accept no reply, then try adding

    ```vim
    let g:mailquery_filter = 1
    ```

    to your `vimrc`, which will discard all e-mail addresses that satisfy the regular expression given by the variable `g:mailquery_filter_regex` that defaults to

    ```vim
    let g:mailquery_filter_regex = '\v^[[:alnum:]._%+-]*%([0-9]{9,}|([0-9]+[a-z]+){3,}|\+|nicht-?antworten|ne-?pas-?repondre|not?([-_.])?reply|<(un)?subscribe>|<mailer\-daemon>)[[:alnum:]._%+-]*\@'
    ```

# Related Plug-ins

- The plugin [vim-notmuch-addrlookup](https://github.com/Konfekt/vim-notmuch-addrlookup) lets you complete e-mail addresses in Vim by those indexed by [notmuch](https://notmuchmail.org).
- The [vim-mutt-aliases](https://github.com/Konfekt/vim-mutt-aliases) plug-in lets you complete e-mail addresses in Vim by those in your `mutt` alias file and (when the alias file is periodically populated by the [mutt-alias.sh](https://github.com/Konfekt/mutt-alias.sh) shell script) gives a more static alternative to this plug-in.

# Credits

- to Patrick Brisbin's [mail-query](https://github.com/pbrisbin/mail-query).
- to Lu Guanqun as the fork [vim-mutt-aliases](https://github.com/Konfekt/vim-mutt-aliases) of [Lu Guanqun](mailto:guanqun.lu@gmail.com)'s [vim-mutt-aliases-plugin](https://github.com/guanqun/vim-mutt-aliases-plugin/tree/063a7bdd0d852a118253278721f74a053776135d) served as a template.

# License

Distributable under the same terms as Vim itself.  See `:help license`.

