# @dest $LIB/superglue/_sgl_esc_key
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
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
