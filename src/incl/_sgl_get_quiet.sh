#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# Checks the globals, SGL_QUIET and SGL_QUIET_PARENT.
#
# @func _sgl_get_quiet
# @use _sgl_get_quiet
# @return
#   0  OFF
#   1  ON
############################################################
_sgl_get_quiet()
{
  if [[ "${SGL_QUIET}" == '1' ]] || [[ "${SGL_QUIET_PARENT}" == '1' ]]; then
    printf '%s' '1'
    return 1
  fi
  printf '%s' '0'
  return 0
}
readonly -f _sgl_get_quiet
