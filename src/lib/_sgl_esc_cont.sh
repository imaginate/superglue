# @dest $LIB/superglue/_sgl_esc_cont
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
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
