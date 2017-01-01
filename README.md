# Orml rules many lands.
## What is it?
Think of it like `pass`, except with more features and a more maintainable
codebase. `orml` is a password/data manager which allows for
various additional security and convenience features.

## Dependencies
* `bash 4.*`
* `make`
* `git`
* `gpg`
* `gnu-getopt` *I might end up changing this to be compatible with bsd-getopt too.*
* `tar`
* `tree`
* `xclip | pbcopy`

I haven't listed all, only the most relevant ones. You shouldn't really have to
worry about these, (sane) systems have most them installed by default.

## Installing
Make is used for installing and removing `orml`. The commands `build` & `clean`
can be used for this, `build` being the default.
```
$ git clone https://github.com/muse/orml
$ make build
```

After that, you will need to install `orml` itself, before you do this make sure
you have a GPG key. You can validate this with `$ gpg --list-secret-keys` which
lists the secret keys available on the system, `orml` will use this to populate
`~/.orml/keys`.

```
$ orml install
```

You're all set to start using `orml`, before entering any commands validate that
`~/.orml/keys` has your default key at the top. When the `--as` flag is omited
`orml` will use this instead.

## Commands
`command` | `man`
----------|------
`install` | You should reference the [installing](/README.md#installing) section.
`insert`  | Insert and encrypt a new file, text message or secure/private key. The key used to encrypt this entry is taken from ~/.orml/keys by default, it will take the first line in the file. This is also the way for you to set a preference on which key to use. You can specify a key which will overwrite the preference with `--as [key]`.  <br /><br /> There are multiple ways to provide insert with data, this is done by changing the second argument.  <br /> <ol> <li>Omitting it, which will spawn a prompt. This prompt will not visibly hide user input without the `--password` flag</li> <li>Supplying a single dash, telling `orml` to read from standard input instead of using the arguments</li><li>Specifying the `--secret [length]` flag, this will use a /dev/urandom string using the printable ascii character set and the provided length</li><li>Anything else which doesn't apply to the previous clauses is initially treated as a file path. If this ends up not being a valid path, it is interpret as text</li></ol>
`select`  | Select and decrypt a existing entry. You don't need to specify a key, gpg will identify if the required key is available by itself. It is possible to suppress any output to standard output with the `--null` flag. Additionally you can use the `--clipboard` flag to copy the contents of entry to your clipboard.
`list`    | List entries optionally based on the provided argument.<br /><br /><ol><li>When no arguments are specified, all of the entries will be list</li><li>When a single argument matching `@hidden` is specified, only ~/.orml/.hidden will be listed</li><li>Any other arguments will be used to pattern match entries, and list those exclusively</li></ol>
`drop`    | Drop the matching entry, hidden entry or directory. This will prompt a confirmation which can optionally be skipped with `--force`.
`move`    | Move the first entry to the second location. When the second location exists, a prompt will appear which can be skipped with `--force`.
`hide`    | Hide the matching entry. the file is then moved to ~/.orml/hidden with the hash of the relative path as its new filename. You can still access this entry like you normally would with select.
`unhide`  | Unhide the matching hidden entry by replacing the hash with the provided matching relative path, it will be interpret the same way it was set initially.
`import`  | Import a tarball or gpg file resembling a logical ordering structure. All found directories are created or reused dependent on the existing directories in ~/.orml.  All the new files found are added, the duplicate files will be overwritten by their import. When a gpg file is provided *without* extension, you need to tell `orml` to decrypt it first by specifying the `--decrypt` flag.
`export`  | Export everything in ~/.orml by making it a tarball, writing it to the provided file. You can additionally encrypt it with the `--encrypt` flag, this can be used in combination with the .I `--as [key]`.
`version` | Display the current version.

## Flags
`flag`        | `arguments` |`man`
--------------|-------------|-----
`--as`        | `[key]`     | Do not use the preferenced key from `~/.orml/keys | head -1`. Instead use the provided key, regardless of its existence in the `~/.orml/keys` file. This flag only applies to export when the `--encrypt` flag is also set.
`--secret`    | `[length]`  | Ignore any user received input and use a /dev/urandom string consisting of all the printable ascii characters and the provided length.
`--encrypt`   | `[]`        | After creating the tar.gz, encrypt the tarball with either the preferenced key, or the key provided by `--as`.
`--decrypt`   | `[]`        | Force decrypt the .tar.gz before attempting to import it.
`--clipboard` | `[]`        | Copy the contents of the selected entry or imported tarball to the clipboard.
`--force`     | `[]`        | Don't prompt
`--null`      | `[]`        | Don't show or do anything.

### Ideas and bugs
Feel free to make a PR really.
