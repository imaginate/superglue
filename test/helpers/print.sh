# Print Helpers
# =============
#
# Helper functions that print test data to `stdout' and `stderr'. All
# functions defined on this page are listed by group in declared order below.
# Note that all functions require the prefix `sglue_'.
#
# Stdout
# ------
# - `sglue_out'
# - `sglue_echo'
# - `sglue_eol'
# - `sglue_paint'
# - `sglue_column'
#
# Stderr
# ------
# - `sglue_out2'
# - `sglue_echo2'
# - `sglue_eol2'
# - `sglue_paint2'
# - `sglue_column2'
#
# Rows
# ----
# - `sglue_blank_row'
# - `sglue_err_row'
# - `sglue_err_rows'
#
# Test
# ----
# - `sglue_header'
# - `sglue_footer'
# - `sglue_section'
# - `sglue_results'
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
##############################################################################

##############################################################################
## STDOUT
##############################################################################

############################################################
# @func sglue_out
# @use sglue_out [...MSG]
# @return
#   0  PASS
############################################################
sglue_out()
{
  printf '%s' "${*}"
}
declare -f -r -x sglue_out

############################################################
# @func sglue_echo
# @use sglue_echo [...MSG]
# @return
#   0  PASS
############################################################
sglue_echo()
{
  printf '%s\n' "${*}"
}
declare -f -r -x sglue_echo

############################################################
# @func sglue_eol
# @use sglue_eol
# @return
#   0  PASS
############################################################
sglue_eol()
{
  printf '\n'
}
declare -f -r -x sglue_eol

############################################################
# @func sglue_paint
# @use sglue_paint COLOR [...MSG]
# @val COLOR  Must be one of the below options.
#   `green'
#   `red'
# @val MSG    Can be any string.
# @return
#   0  PASS
############################################################
sglue_paint()
{
  if [[ ${#} -lt 2 ]]; then
    return 0
  fi

  if [[ ! -t 1 ]]; then
    shift
    sglue_out "${*}"
    return 0
  fi

  case "${1}" in
    green)
      sglue_out "${SGLUE_GREEN}"
      ;;
    red)
      sglue_out "${SGLUE_RED}"
      ;;
    *)
      return 0
      ;;
  esac
  shift

  sglue_out "${*}"
  sglue_out "${SGLUE_UNCOLOR}"
}
declare -f -r -x sglue_paint

############################################################
# @func sglue_column
# @use sglue_column WIDTH [...MSG]
# @return
#   0  PASS
############################################################
sglue_column()
{
  local -i width="${1}"

  shift
  printf "%${width}s" "${*}"
}
declare -f -r -x sglue_column

##############################################################################
## STDERR
##############################################################################

############################################################
# @func sglue_out2
# @use sglue_out2 [...MSG]
# @return
#   0  PASS
############################################################
sglue_out2()
{
  printf '%s' "${*}" 1>&2
}
declare -f -r -x sglue_out2

############################################################
# @func sglue_echo2
# @use sglue_echo2 [...MSG]
# @return
#   0  PASS
############################################################
sglue_echo2()
{
  printf '%s\n' "${*}" 1>&2
}
declare -f -r -x sglue_echo2

############################################################
# @func sglue_eol2
# @use sglue_eol2
# @return
#   0  PASS
############################################################
sglue_eol2()
{
  printf '\n' 1>&2
}
declare -f -r -x sglue_eol2

############################################################
# @func sglue_paint2
# @use sglue_paint2 COLOR [...MSG]
# @val COLOR  Must be one of the below options.
#   `green'
#   `red'
# @val MSG    Can be any string.
# @return
#   0  PASS
############################################################
sglue_paint2()
{
  if [[ ${#} -lt 2 ]]; then
    return 0
  fi

  if [[ ! -t 1 ]]; then
    shift
    sglue_out2 "${*}"
    return 0
  fi

  case "${1}" in
    green)
      sglue_out2 "${SGLUE_GREEN}"
      ;;
    red)
      sglue_out2 "${SGLUE_RED}"
      ;;
    *)
      return 0
      ;;
  esac
  shift

  sglue_out2 "${*}"
  sglue_out2 "${SGLUE_UNCOLOR}"
}
declare -f -r -x sglue_paint2

############################################################
# @func sglue_column2
# @use sglue_column2 WIDTH [...MSG]
# @return
#   0  PASS
############################################################
sglue_column2()
{
  local -i width="${1}"
 
  shift
  printf "%${width}s" "${*}" 1>&2
}
declare -f -r -x sglue_column2

##############################################################################
## ROWS
##############################################################################

############################################################
# @func sglue_blank_row
# @use sglue_blank_row
# @return
#   0  PASS
############################################################
sglue_blank_row()
{
  local -i i=0

  while [[ ${i} -lt ${SGLUE_ROW_LENGTH} ]]; do
    sglue_out '-'
    i=$(( ${i} + 1 ))
  done
  sglue_eol
}
declare -f -r -x sglue_blank_row

############################################################
# @func sglue_err_row
# @use sglue_err_row [...MSG]
# @return
#   0  PASS
############################################################
sglue_err_row()
{
  sglue_echo2 " - ${*}"
}
declare -f -r -x sglue_err_row

############################################################
# @func sglue_err_rows
# @use sglue_err_rows [...ERR]
# @return
#   0  PASS
############################################################
sglue_err_rows()
{
  local err

  if [[ ${#} -lt 1 ]]; then
    return 0
  fi

  for err in "${@}"; do
    sglue_err_row "${err}"
  done
  return 0
}
declare -f -r -x sglue_err_rows

##############################################################################
## TEST
##############################################################################

############################################################
# @func sglue_header
# @use sglue_header
# @return
#   0  PASS
############################################################
sglue_header()
{
  sglue_blank_row
  echo "## ${SGLUE_HEADER}"
  sglue_blank_row
}
declare -f -r -x sglue_header

############################################################
# @func sglue_footer
# @use sglue_footer
# @return
#   0  PASS
############################################################
sglue_footer()
{
  sglue_blank_row
  echo "## ${SGLUE_FOOTER}"
  sglue_blank_row
}
declare -f -r -x sglue_footer

############################################################
# @func sglue_section
# @use sglue_section SECTION 
# @return
#   0  PASS
############################################################
sglue_section()
{
  sglue_out ' '
  sglue_column ${SGLUE_SECTION_WIDTH} "${1}"
  sglue_out ' '

  if [[ ${#SGLUE_TEST_ERRORS[@]} -eq 0 ]]; then
    sglue_paint green 'PASS'
  else
    sglue_paint red 'FAIL'
  fi
  sglue_eol

  sglue_err_rows "${SGLUE_TEST_ERRORS[@]}"
}
declare -f -r -x sglue_section

############################################################
# @func sglue_results
# @use sglue_results
# @return
#   0  PASS
############################################################
sglue_results()
{
  sglue_blank_row
  sglue_out ' '

  if [[ ${SGLUE_TESTS_FAILED} -eq 0 ]]; then
    sglue_paint green 'All Tests Passed'
  else
    sglue_paint red "${SGLUE_TESTS_FAILED} Tests Failed"
  fi
  sglue_eol
}
declare -f -r -x sglue_results

