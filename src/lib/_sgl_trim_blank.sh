# @dest $LIB/superglue/_sgl_trim_blank
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
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
