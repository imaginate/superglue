#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# Checks the globals, SGL_SILENT and SGL_SILENT_PARENT.
#
# @func _sgl_get_silent
# @use _sgl_get_silent
# @return
#   0  OFF
#   1  ON
############################################################
_sgl_get_silent()
{
  if [[ "${SGL_SILENT}" == '1' ]] || [[ "${SGL_SILENT_PARENT}" == '1' ]]; then
    return 1
  fi
  return 0
}
readonly -f _sgl_get_silent
