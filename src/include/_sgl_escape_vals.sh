#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_escape_vals
# @use _sgl_escape_vals VAL
# @val VAL  Must be a multi-line value for sed replacement.
# @return
#   0  PASS
############################################################
_sgl_escape_vals()
{
  local line
  local val

  while IFS= read -r line; do
    val="${val}${line}\\n"
  done <<< "$(printf '%s' "${1}" | ${sed} -e 's/[\/&]/\\&/g')"
  printf '%s' "${val%\\n}"
}
readonly -f _sgl_escape_vals
