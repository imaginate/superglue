#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_is_read
# @use _sgl_is_read FILE
# @val FILE  Should be a readable file path.
# @return
#   0  PASS
#   1  FAIL
############################################################
_sgl_is_read()
{
  if _sgl_is_path "${1}" && [[ -r "${1}" ]]; then
    return 0
  fi
  return 1
}
readonly -f _sgl_is_read
