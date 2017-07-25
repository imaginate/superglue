# Test Helpers
# ============
#
# Helper functions that run the tests. All functions defined on this page are
# listed in declared order below. Note that all functions require the prefix
# `sglue_'.
#
# - `sglue_stop'
# - `sglue_test'
# - `sglue_test_all'
# - `sglue_throw'
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2017 Adam A Smith <adam@imaginate.life>
##############################################################################

############################################################
# @func sglue_stop
# @use sglue_stop ...LINE
# @val LINE
#   Should be a valid line of text to add to `stderr'. A
#   newline (e.g. `\n') is automatically appended to each
#   LINE.
# @exit
#   9  INTERNAL_SUPERGLUE_TEST_ERROR
############################################################
sglue_stop()
{
  sglue_out2 ' - '

  local -r TITLE="${SGLUE_RED}INTERNAL TEST ERROR${SGLUE_UNCOLOR}"

  if [[ ${#} -lt 1 ]]; then
    sglue_echo2 "${TITLE}"
    sglue_footer
    exit 9
  fi

  sglue_echo2 "${TITLE} ${1}"
  shift

  if [[ ${#} -lt 1 ]]; then
    sglue_footer
    exit 9
  fi

  local line

  for line in "${@}"; do
    sglue_echo2 "${line}"
  done

  sglue_footer
  exit 9
}
declare -f -r -x sglue_stop

############################################################
# @func sglue_test
#   Note that if no PATH or SECTION is defined all tests in
#   `../tests' are ran.
# @use sglue_test [...PATH|SECTION]
# @val PATH
#   Must be a readable file path with a file extension of
#   `.sh' located in the `../tests' directory.
# @val SECTION
#   Must be the name of a group of tests to run. Note that a
#   readable file path matching `../tests/SECTION.sh' must
#   exist.
# @return
#   0  PASS
# @exit-on-error
#   9  INTERNAL_SUPERGLUE_TEST_ERROR
############################################################
sglue_test()
{
  if [[ ${#} -lt 1 ]]; then
    sglue_test_all
    return 0
  fi

  local name
  local path

  for name in "${@}"; do
    name="${name##*/}"
    name="${name%.sh}"
    path="${SGLUE_TESTS%/}/${name}.sh"

    if ! sglue_is_dir -r -s -- "${path}"; then
      sglue_stop \
        "invalid \`PATH' or \`SECTION' passed to \`sglue_test'" \
        "    invalid-path: \`${path}'" \
        "    invalid-name: \`${name}'"
    fi

    sglue_clean_tree "${SGLUE_DUMMY}"
    SGLUE_TEST_ERRORS=()
    . "${path}"
    sglue_section "${name}"
  done

  return 0
}
declare -f -r sglue_test

############################################################
# @func sglue_test_all
# @use sglue_test_all
# @return
#   0  PASS
# @exit-on-error
#   9  INTERNAL_SUPERGLUE_TEST_ERROR
############################################################
sglue_test_all()
{
  local -a paths=()
  local path

  while IFS= read -r path; do
    case "${path}" in
      *.sh)
        paths+=( "${path}" )
        ;;
    esac
  done <<< "$(sglue_get_paths -f -- "${SGLUE_TESTS}")"

  if [[ ${#paths[@]} -gt 0 ]]; then
    sglue_test "${paths[@]}"
  fi

  return 0
}
declare -f -r sglue_test_all

############################################################
# @func sglue_throw
# @use sglue_throw [...MSG]
# @return
#   0  PASS
############################################################
sglue_throw()
{
  SGLUE_TEST_ERRORS[${#SGLUE_TEST_ERRORS[@]}]="${*}"
  SGLUE_TESTS_FAILED=$(( ${SGLUE_TESTS_FAILED} + 1 ))
  return 0
}
declare -f -r -x sglue_throw

