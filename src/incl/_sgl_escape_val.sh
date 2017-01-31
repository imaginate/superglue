#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_escape_val
# @use _sgl_escape_val VAL
# @val VAL  Must be a value for sed replacement.
# @return
#   0  PASS
############################################################
_sgl_escape_val()
{
  if [[ "${1}" == *$'\n'* ]]; then
    _sgl_escape_vals "${1}"
  else
    printf '%s' "${1}" | ${sed} -e 's/[\/&]/\\&/g'
  fi
}
readonly -f _sgl_escape_val
