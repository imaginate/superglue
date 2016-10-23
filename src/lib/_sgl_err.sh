#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_err
# @use _sgl_err ERR MSG
# @val MSG  Can be any string.
# @val ERR  Must be an error from the below options or any valid integer in the
#           range of `1' to `126'.
#   `MISC'  An unknown error.
#   `OPT'   An invalid option.
#   `VAL'   An invalid or missing value.
#   `AUTH'  A permissions error.
#   `DPND'  A dependency error.
#   `CHLD'  A child process exited unsuccessfully.
#   `SGL'   A `superglue' script error.
# @exit
#   1  MISC
#   2  OPT
#   3  VAL
#   4  AUTH
#   5  DPND
#   6  CHLD
#   7  INTL
############################################################
_sgl_err()
{
  local title
  local code

  case "$1" in
    MISC)
      title='ERR'
      code=1
      ;;
    OPT)
      title='OPT_ERR'
      code=2
      ;;
    VAL)
      title='VAL_ERR'
      code=3
      ;;
    AUTH)
      title='AUTH_ERR'
      code=4
      ;;
    DPND)
      title='DPND_ERR'
      code=5
      ;;
    CHLD)
      title='CHLD_ERR'
      code=6
      ;;
    SGL)
      title='SGL_ERR'
      code=7
      ;;
    *)
      if [[ ! "$1" =~ ^[1-9][0-9]?[0-9]?$ ]] || [[ $1 -gt 126 ]]; then
        _sgl_err SGL "invalid \`_sgl_err' CODE \`$1' in \`superglue'"
      fi
      title='ERR'
      code="$1"
      ;;
  esac

  if [[ ${SGL_COLOR_ON} -eq 1 ]]; then
    [[ -n "${SGL_RED}"     ]] && title="${SGL_RED}${title}"
    [[ -n "${SGL_UNCOLOR}" ]] && title="${title}${SGL_UNCOLOR}"
  elif [[ ${SGL_COLOR_OFF} -ne 1 ]] && [[ -t 1 ]]; then
    [[ -n "${SGL_RED}"     ]] && title="${SGL_RED}${title}"
    [[ -n "${SGL_UNCOLOR}" ]] && title="${title}${SGL_UNCOLOR}"
  fi

  if [[ ${SGL_SILENT} -ne 1 ]] && [[ ${SGL_SILENT_PARENT} -ne 1 ]]; then
    printf "%s\n" "${title} $2" 1>&2
  fi
  if [[ ${SGL_VERBOSE} -eq 1 ]]; then
    local line="- LINE $(caller | ${sed} -e 's/ .\+$//')"
    local file="- FILE $(caller | ${sed} -e 's/^[0-9]\+ //')"
    printf "%s\n%s\n" "${line}" "${file}"
  fi
  exit ${code}
}
readonly -f _sgl_err
