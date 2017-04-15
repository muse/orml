#!/usr/bin/env make
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# from, to, as.
BIN_F := .
BIN_T := /usr/local/bin
BIN_A := orml
DOC_F := doc
DOC_T := /usr/local/share/man/man1
DOC_A := orml.1
LIB_F := lib
LIB_T := /usr/local/lib/orml
LIB_A := *

install:
	if [ ! -d $(LIB_T) ]; then mkdir $(LIB_T); fi
	cp $(LIB_F)/$(LIB_A) $(LIB_T)
	cp $(DOC_F)/$(DOC_A) $(DOC_T)
	cp $(BIN_F)/$(BIN_A).bash $(BIN_T)/$(BIN_A)
	chmod +r $(DOC_T)/$(DOC_A)
	chmod +x $(BIN_T)/$(BIN_A)

clean:
	rm $(BIN_T)/$(BIN_A)
	rm -r $(LIB_T)
	rm $(DOC_T)/$(DOC_A)

.PHONY: install clean
