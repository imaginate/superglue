# Superglue Test Makefile
# =======================
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2017 Adam A Smith <adam@imaginate.life>
#
# @use make [TARGET]
# @val TARGET
#   The default TARGET is `test'. See each TARGET below for more details.
#   - `h|help'  Print the help info and exit.
#   - `t|test'  Run all of the tests and print the results.
# @exit
#   0  PASS   All tests passed.
#   1  FAIL   One or more tests failed.
#   9  ERROR  An internal error occurred (i.e. **no** tests were ran).
##############################################################################


##############################################################################
## DECLARE PHONY TARGETS
##############################################################################

.PHONY: \
	h help \
	t test

##############################################################################
## DEFINE DEFAULT TARGET
##############################################################################

all: test

##############################################################################
## DEFINE PHONY TARGETS
##############################################################################

h: help
help:
	@sed -e '/^[ \t]*#/ d' -- ./Makefile.help

t: test
test:
	@./bin/test.sh

