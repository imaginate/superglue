#!/bin/bash
#
# @dest /lib/superglue/_sgl_err
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source err
# @return
#   0  PASS
################################################################################

############################################################
# @func _sgl_err
# @use _sgl_err TYPE MSG
# @val MSG   Can be any string.
# @val TYPE  Must be an error type from the below options.
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
      _sgl_err SGL "invalid \`_sgl_err' CODE \`$1' in \`superglue'"
      ;;
  esac

  if [[ ${SGL_COLOR_ON} -eq 1 ]]; then
    [[ -n "${SGL_RED}"     ]] && title="${SGL_RED}${title}"
    [[ -n "${SGL_UNCOLOR}" ]] && title="${title}${SGL_UNCOLOR}"
  elif [[ ${SGL_COLOR_OFF} -ne 1 ]] && [[ -t 1 ]]; then
    [[ -n "${SGL_RED}"     ]] && title="${SGL_RED}${title}"
    [[ -n "${SGL_UNCOLOR}" ]] && title="${title}${SGL_UNCOLOR}"
  fi

  printf "%s\n" "${title} $2" 1>&2
  exit ${code}
}
readonly -f _sgl_err