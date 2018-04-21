# Superglue Makefile
# ==================
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
#
# @use make [...VARIABLE=VALUE] [TARGET]
#
# @var BIN=DIRPATH
#   Override the default binary directory of `/bin'.
# @var LIB=DIRPATH
#   Override the default library directory of `/usr/lib'.
# @var SHARE=DIRPATH
#   Override the default share directory of `/usr/share'.
#
# @val DIRPATH
#   Must be a valid absolute directory path.
# @val TARGET
#   The default TARGET is `install'. See each TARGET below for more details.
#   - `b|build'      The same as `install'.
#   - `c|clean'      The same as `uninstall'.
#   - `f|force'      Forcefully install all of the `superglue' paths.
#   - `h|help'       Print the help info and exit.
#   - `i|install'    Safely install all of the `superglue' paths.
#   - `t|test'       Run all of the tests and print the results.
#   - `x|uninstall'  Remove all of the `superglue' paths.
#
# @exit
#   0  PASS  A successful exit.
#   1  ERR   An unknown error.
#   2  OPT   An invalid option.
#   3  VAL   An invalid or missing value.
#   4  AUTH  A permissions error.
#   5  DPND  A dependency error.
#   6  CHLD  A child process exited unsuccessfully.
#   7  SGL   A `superglue' script error.
##############################################################################

##############################################################################
## DEFINE PUBLIC VARIABLE DEFAULTS
##############################################################################

BIN = "/bin"
LIB = "/usr/lib"
SHARE = "/usr/share"

##############################################################################
## DECLARE PHONY TARGETS
##############################################################################

.PHONY: \
	b build \
	c clean \
	f force \
	h help \
	i install install-f install-force \
	t test \
	x uninstall

##############################################################################
## DEFINE DEFAULT TARGET
##############################################################################

all: install

##############################################################################
## DEFINE PRIVATE VARIABLES
##############################################################################

override _ARGS = \
	--bin="$(BIN)" \
	--lib="$(LIB)" \
	--share="$(SHARE)"

##############################################################################
## DEFINE PHONY TARGETS
##############################################################################

b: build
build: install

c: clean
clean: uninstall

f: force
force: install-force

h: help
help:
	@sed -e '/^[[:blank:]]*#/ d' -- ./.Makefile.help

i: install
install:
	@./bin/install.sh $(_ARGS)

install-f: install-force
install-force:
	@./bin/install.sh $(_ARGS) --force

t: test
test:
	@make -C ./test

x: uninstall
uninstall:
	@./bin/install.sh $(_ARGS) --uninstall

