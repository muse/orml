#!/usr/bin/env bash

(make clean && make install && bash test/test.bash test/somebody.key)
