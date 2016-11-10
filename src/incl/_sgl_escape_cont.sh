#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_escape_cont
# @use _sgl_escape_cont PATH
# @val PATH  Must be a valid file path.
# @return
#   0  PASS
############################################################
_sgl_escape_cont()
{
  local line
  local val

  while IFS= read -r line; do
    val="${val}${line}\\n"
  done <<< "$(${sed} -e 's/[\/&]/\\&/g' "${1}")"
  printf '%s' "${val%\\n}"
}
readonly -f _sgl_escape_cont
