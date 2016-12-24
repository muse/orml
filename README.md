# Orml rules many lands.
### What is it?
Think of it like `pass`, except with more features and a more maintainable
codebase (no offense). `orml` is a password/data manager which allows for
various additional security and convenience features.

### Installing
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


### Flags
There's quite a few flags available and not every flag has a purpose in every
command.

`--flag`            | `command`                    |`man`
--------------------|------------------------------|-----
`--as [key]`        | `insert, export (--encrypt)` | Do not use the preferenced key from `~/.orml/keys | head -1`. Instead use the provided key, regardless of its existence in the `~/.orml/keys` file. This flag only applies to export when the `--encrypt` flag is also set.
`--secret [length]` | `insert`                     | Ignore any user received input and use a /dev/urandom string consisting of all the printable ascii characters and the provided length.
`--encrypt`         | `export`                     | After creating the tar.gz, encrypt the tarball with either the preferenced key, or the key provided by `--as`.
`--decrypt`         | `import`                     | Force decrypt the .tar.gz before attempting to import it.
`--clipboard`       | `import, select`             | Copy the contents of the selected entry or imported tarball to the clipboard.
`--null`            | `import, select`             | Don't show or do anything.
