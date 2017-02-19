# @dest $LIB/superglue/_sgl_esc_vals
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source esc_vals
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_esc_vals
# @use _sgl_esc_vals VAL
# @val VAL  Must be a multi-line value for sed replacement.
# @return
#   0  PASS
############################################################
_sgl_esc_vals()
{
  local line
  local val

  while IFS= read -r line; do
    val="${val}${line}\\n"
  done <<< "$(printf '%s' "${1}" | ${sed} -e 's/[\/&]/\\&/g')"
  printf '%s' "${val%\\n}"
}
readonly -f _sgl_esc_vals
