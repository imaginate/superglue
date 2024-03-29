#!/bin/bash
#
# Run `superglue' unit tests.
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
#
# @use ./test.sh [...SECTION]
# @val SECTION  If a SECTION is defined, it must be a readable file path to
#               `../tests/SECTION.sh'. If no SECTION is defined, all tests
#               (i.e. all file paths matching `../tests/*.sh') are ran.
# @exit
#   0  PASS   All tests passed.
#   1  FAIL   One or more tests failed.
#   9  ERROR  An internal error occurred (i.e. **no** tests were ran).
##############################################################################

##############################################################################
## CHANGE DIRECTORY
##############################################################################

if [[ "${0}" != 'test.sh' ]] && [[ "${0}" != './test.sh' ]]; then
  cd "${0%/*}"
fi

cd ..

##############################################################################
## SETUP HELPERS
##############################################################################

. ./helpers/refs.sh
. ./helpers/general.sh
. ./helpers/print.sh
. ./helpers/test.sh

##############################################################################
## SETUP DUMMY DIRECTORIES
##############################################################################

sglue_mk_dir -m 0755 -p -- "${SGLUE_DUMMY_DIRS[@]}"

##############################################################################
## RUN TESTS
##############################################################################

sglue_header

if [[ ${#} -gt 0 ]]; then
  sglue_test "${@}"
else
  sglue_test_all
fi

sglue_results
sglue_footer

##############################################################################
## REMOVE DUMMY DIRECTORIES
##############################################################################

if [[ -d "${SGLUE_DUMMY}" ]]; then
  sglue_clean_tree "${SGLUE_DUMMY}"
  sglue_rm_dir -r -- "${SGLUE_DUMMY}"
fi

##############################################################################
## EXIT WITH RESULT
##############################################################################

if [[ ${SGLUE_TESTS_FAILED} -gt 0 ]]; then
  exit 1
fi
exit 0

