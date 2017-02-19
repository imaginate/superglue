# @dest $LIB/superglue/_sgl_esc_key
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source esc_key
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_esc_key
# @use _sgl_esc_key KEY
# @val KEY  Must be a regex key for sed.
# @return
#   0  PASS
############################################################
_sgl_esc_key()
{
  printf '%s' "${1}" | ${sed} -e 's/[]\/$*.^|[]/\\&/g'
}
readonly -f _sgl_esc_key
