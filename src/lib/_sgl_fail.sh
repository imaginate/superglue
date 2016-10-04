#!/bin/bash
#
# @dest /lib/superglue/_sgl_fail
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source fail
# @return
#   0  PASS
################################################################################

############################################################
# @func _sgl_fail
# @use _sgl_fail ERR MSG
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
# @return
#   0  PASS
############################################################
_sgl_fail()
{
  local title

  case "$1" in
    MISC)
      title='ERR'
      ;;
    OPT)
      title='OPT_ERR'
      ;;
    VAL)
      title='VAL_ERR'
      ;;
    AUTH)
      title='AUTH_ERR'
      ;;
    DPND)
      title='DPND_ERR'
      ;;
    CHLD)
      title='CHLD_ERR'
      ;;
    SGL)
      title='SGL_ERR'
      ;;
    *)
      title='ERR'
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
}
readonly -f _sgl_fail
