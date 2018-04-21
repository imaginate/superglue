# @dest $LIB/superglue/_sgl_esc_val
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
#
# @use _sgl_source esc_val
# @return
#   0  PASS
################################################################################

_sgl_source esc_vals

############################################################
# @private
# @func _sgl_esc_val
# @use _sgl_esc_val VAL
# @val VAL  Must be a value for sed replacement.
# @return
#   0  PASS
############################################################
_sgl_esc_val()
{
  if [[ "${1}" == *$'\n'* ]]; then
    _sgl_esc_vals "${1}"
  else
    printf '%s' "${1}" | ${sed} -e 's/[\/&]/\\&/g'
  fi
}
readonly -f _sgl_esc_val
