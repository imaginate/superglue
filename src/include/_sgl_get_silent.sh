#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# Prints the boolean for the below globals.
#   `SGL_SILENT'
#   `SGL_SILENT_PARENT'
#   `SGL_SILENT_CHILD'
#
# @func _sgl_get_silent
# @use _sgl_get_silent [PROC]
# @val PROC  Must be one of the below options.
#   `CHLD'  Child process.
#   `PRT'   Parent process.
# @return
#   0  PASS
############################################################
_sgl_get_silent()
{
  local -i silent=0

  if [[ "${SGL_SILENT}" == '1' ]]; then
    silent=1
  else
    case "${1}" in
      CHLD)
        if [[ "${SGL_SILENT_CHILD}" == '1' ]]; then
          silent=1
        fi
        ;;
      PRT)
        if [[ "${SGL_SILENT_PARENT}" == '1' ]]; then
          silent=1
        fi
        ;;
    esac
  fi

  printf '%s' "${silent}"
  return 0
}
readonly -f _sgl_get_silent
