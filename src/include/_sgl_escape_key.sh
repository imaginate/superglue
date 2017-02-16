#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_escape_key
# @use _sgl_escape_key KEY
# @val KEY  Must be a regex key for sed.
# @return
#   0  PASS
############################################################
_sgl_escape_key()
{
  printf '%s' "${1}" | ${sed} -e 's/[]\/$*.^|[]/\\&/g'
}
readonly -f _sgl_escape_key
