NAME
====

orml - orml rules many lands.

SYNOPSIS
========

orml \[version\] | \[help\] | \[drop *\[entry\]*\] | \[list *\[@hidden | \[pattern | \[\]\]\]*\] | \[move *\[from\] \[to\]*\] | \[install *\[key\]*\] | \[insert *\[entry\] \[- | input\]*\] | \[select *\[entry\]*\] | \[hide *\[entry\]*\] | \[unhide *\[entry\]*\] | \[export *\[file\]*\] | \[import *\[file\]*\] | \[--passphrase *\[passphrase\]*\] | \[--secret *\[length\]*\] | \[--as *\[key\]*\] | \[--encrypt\] | \[--decrypt\] | \[--clipboard\] | \[--password\] | \[--null\] | \[--force\]

DESCRIPTION
===========

Think of it like pass, except with more features and a more maintainable codebase. orml is a password/data manager which allows for various additional security and convenience features.

DEPENDENCIES
============

|     Dependency| version     | purpose                        |
|--------------:|:------------|:-------------------------------|
|           bash| &gt;= 4.0.0 | core                           |
|            gpg| &gt;= 2.0   | core                           |
|     gnu-getopt| \*          | core                           |
|           make| \*          | installation                   |
|            git| \*          | installation                   |
|            tar| \*          | command:import, command:export |
|           tree| \*          | command:list                   |
|  xclip\#pbcopy| \*          | opts:clipboard                 |

INSTALLING
==========

Make is used for installing and removing orml. The commands build & clean can be used for this, build being the default.

    $ git clone https://github.com/muse/orml
    $ make build

After that, you will need to install orml itself, before you do this make sure you have a GPG key. You can validate this with `$ gpg --list-secret-keys` which lists the secret keys available on the system, orml will use this to populate ~/.orml/keys.

    $ orml install D16BCBA7

Before entering any commands validate that ~/.orml/keys has your default key at the top. When the *--as* option is omited orml will use this instead.

COMMANDS
========

version
-------

Display the current version.

help
----

Open the manual page if available and possible.

drop \[entry\]
--------------

Drop the matching entry, hidden entry or directory. This will prompt a confirmation which can optionally be skipped with *--force*.

install \[key\]
---------------

Refer to the INSTALLING section above.

list \[@hidden | \[pattern | \[\]\]\]
-------------------------------------

List entries optionally based on the provided argument.

-   When no arguments are specified, all of the entries will be list
-   When a single argument matching *@hidden* is specified, only ~/.orml/.hidden will be listed
-   Any other arguments will be used to pattern match entries, and list those exclusively

move \[from\] \[to\]
--------------------

Move the first entry to the second location. When the second location exists, a prompt will appear which can be skipped with *--force*.

insert \[entry\] \[- | input\]
------------------------------

Insert and encrypt a new file, text message or secure/private key. The key used to encrypt this entry is taken from ~/.orml/keys by default, it will take the first line in the file. This is also the way for you to set a preference on which key to use. You can specify a key which will overwrite the preference with *--as \[key\]*. There are multiple ways to provide insert with data, this is done by changing the second argument.

-   Omitting it, which will spawn a prompt. This prompt will not visibly hide user input without the *--password* option
-   Supplying a single dash, telling orml to read from standard input instead of using the arguments
-   Specifying the *--secret \[length\]* option, this will use a /dev/urandom string using the printable ascii character set and the provided length
-   Anything else which doesn't apply to the previous clauses is initially treated as a file path. If this ends up not being a valid path, it is interpret as text.

select \[entry\]
----------------

Select and decrypt a existing entry. You don't need to specify a key, gpg will identify if the required key is available by itself. It is possible to suppress any output to standard output with the *--null* option. Additionally you can use the *--clipboard* option to copy the contents of entry to your clipboard.

hide \[entry\]
--------------

Hide the matching entry. the file is then moved to ~/.orml/hidden with the hash of the relative path as its new filename. You can still access this entry like you normally would with select.

unhide \[entry\]
----------------

Unhide the matching hidden entry by replacing the hash with the provided matching relative path, it will be interpret the same way it was set initially.

import \[file\]
---------------

Import a tarball or gpg file resembling a logical ordering structure. All found directories are created or reused dependent on the existing directories in ~/.orml. All the new files found are added, the duplicate files will be overwritten by their import. When a gpg file is provided **without** extension, you need to tell provide the *--decrypt* option.

export \[file\]
---------------

Export everything in ~/.orml by making a tarball writen to the provided . You can additionally encrypt it with the *--encrypt* option, this can be used in combination with the *--as \[key\]*.

OPTIONS
=======

--passphrase \[passphrase\]
---------------------------

Use this passphrase instead of the later prompted one (not very secure).

--secret \[length\]
-------------------

Ignore any user received input and use a /dev/urandom string consisting of all the printable ascii characters and the provided length.

--as \[key\]
------------

Do not use the preferenced key from ~/.orml/keys. Instead use the provided key, regardless of its existence in the ~/.orml/keys file. This option only applies to **export** when the *--encrypt* option is also set.

--encrypt
---------

After creating the tarball, encrypt it with either the preferenced key, or the key provided by *--as*.

--decrypt
---------

Force decrypt the tarball before attempting to import it.

--clipboard
-----------

Copy the contents of the selected entry to the clipboard.

--null
------

Don't show anything.

--password
----------

Don't show what's being typed into a prompt.

--force
-------

Don't prompt.

BUGS
====

-   mvdw at airmail dot cc
-   github/muse/orml

