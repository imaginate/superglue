#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_is_cmd
# @use _sgl_is_cmd CMD
# @val CMD  Should be a valid path to an executable.
# @return
#   0  PASS
#   1  FAIL
############################################################
_sgl_is_cmd()
{
  if _sgl_is_read "${1}" && [[ -x "${1}" ]]; then
    return 0
  fi
  return 1
}
readonly -f _sgl_is_cmd
