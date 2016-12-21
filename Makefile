#!/usr/bin/make
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

define validate_existence
  if [ $(1) $(2) ]; then $(3); else $(4); fi;
endef

BIN_FROM :=./
BIN_TO   :=/usr/local/bin
BIN_AS   :=orml.bash
DOC_FROM :=doc
DOC_TO   :=/usr/local/share/man/man1
DOC_AS   :=orml.1
LIB_FROM :=lib
LIB_TO   :=/usr/local/lib/orml
LIB_AS   :=*

build:
	$(call \
	  validate_existence, \
	  ! -d, $(LIB_TO),    \
	  mkdir $(LIB_TO),    \
	  :)
	cp $(LIB_FROM)/$(LIB_AS) $(LIB_TO)
	cp $(DOC_FROM)/$(DOC_AS) $(DOC_TO)
	cp $(BIN_FROM)/$(BIN_AS) $(BIN_TO)/orml
	chmod +r $(DOC_TO)/$(DOC_AS)
	chmod +x $(BIN_TO)/orml

clean:
	rm $(BIN_TO)/orml
	rm -r $(LIB_TO)
	rm $(DOC_TO)/$(DOC_AS)
