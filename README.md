## $ orml

I've finished the core commands, meaning that it is now functional. However,
there's a few more things I've been wanting to implement mostly because they're
convenient to have.

- [ ] There's no confirmation/error when you hide a password already hidden.
      This means there is no validation to confirm if the file is already hidden
      or when you tryto hide a already hidden file by inserting it again, after
      you hid it.
      ```
        $ orml insert foo/bar "Hey world!"
        $ orml hide foo/bar
        $ orml insert foo/bar "I've been here..."
        $ orml hide foo/bar   # We can't catch this any earlier, by the assumption
                              # that someone will insert a file manually.
      ```


- [ ] I'd like to implement short reference codes to paths. I'm not sure what
      I'd like here though, I initially thought about using the first 8 characters
      from a different shasum than hidden, this however seems very obscure and
      unlikely to be used often. I'll come back to this sometime.
      ```
      $ orml insert foo/bar "It doesn't really matter"
      $ orml list
      └── foo
          └── [2c01b6] bar
      $ orml select 2c01b6
      ```

- [ ] Adding to the issue above, perhaps shorter versions of the existing commands.

      Long  |short
      ------|-----
      `insert`|`i`
      `select`|`s`
      `drop`  |`d`
      `hide`  |`h`
      `unhide`|`u`
      `list`  |`l`

      ```
      $ orml i foo/bar "Hi"
      $ orml s foo/bar
      > Hi
      ```

- [ ] Adding tests as well, we need to make sure the commands function as intended.
      The tests will be in `test` after cloning and will be exclusive to being ran
      in the cloned directory (for now).

- [X] I feel like the `_cipher` function can be enhanced.

- [ ] Implement the existing and possibly new flags.
      - [x] `--as        (insert, select, import, export)`
      - [ ] `--hidden    (insert)`
      - [ ] `--null      (select)`
      - [X] `--encrypt   (import, export)`
      - [X] `--decrypt   (import, export)`
      - [ ] `--clipboard (select)`
      - [ ] `--secret    (insert)`
