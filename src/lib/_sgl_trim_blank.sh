# @dest $LIB/superglue/_sgl_trim_blank
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source trim_blank
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_trim_blank
# @use _sgl_trim_blank VALUE
# @val VALUE  Can be any string.
# @return
#   0  PASS
############################################################
_sgl_trim_blank()
{
  if [[ -z "${1}" ]]; then
    return 0
  fi

  printf '%s' "${1}" | \
    ${sed} \
      -e 's/^[[:blank:]]\+//' \
      -e 's/[[:blank:]]\+$//'
}
readonly -f _sgl_trim_blank
