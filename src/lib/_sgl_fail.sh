#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
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
    title="${SGL_RED}${title}${SGL_UNCOLOR}"
  elif [[ ${SGL_COLOR_OFF} -ne 1 ]] && [[ -t 1 ]]; then
    title="${SGL_RED}${title}${SGL_UNCOLOR}"
  fi

  if [[ ${SGL_SILENT} -ne 1 ]]; then
    printf "%s\n" "${title} $2" 1>&2
    if [[ ${SGL_VERBOSE} -eq 1 ]]; then
      local details="$(caller)"
      printf "%s %s %s\n" '-' 'LINE' "${details%% *}" 1>&2
      printf "%s %s %s\n" '-' 'FILE' "${details##* }" 1>&2
    fi
  fi
}
readonly -f _sgl_fail
