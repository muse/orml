# $ orml - orml rules many lands.
### What is it?
Think of it like `pass`, except with more features and a more maintainable codebase.
`orml` is a password/data manager which allows for various additional security
and convenience features.

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

### How does it work?
I haven't ported the .groff to Markdown or plain ASCII yet. I recommend using
the provided manual with `$ man orml` or `$ orml help`.
