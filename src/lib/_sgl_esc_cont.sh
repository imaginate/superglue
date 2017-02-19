# @dest $LIB/superglue/_sgl_esc_cont
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source esc_cont
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_esc_cont
# @use _sgl_esc_cont PATH
# @val PATH  Must be a valid file path.
# @return
#   0  PASS
############################################################
_sgl_esc_cont()
{
  local line
  local val

  while IFS= read -r line; do
    val="${val}${line}\\n"
  done <<< "$(${sed} -e 's/[\/&]/\\&/g' "${1}")"
  printf '%s' "${val%\\n}"
}
readonly -f _sgl_esc_cont
