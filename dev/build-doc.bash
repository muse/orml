#!/usr/bin/env bash

(pandoc doc/orml.1.md --standalone --from markdown --to man --output doc/orml.1)
(pandoc doc/orml.1.md --from markdown --to markdown_github  --output README.md)
