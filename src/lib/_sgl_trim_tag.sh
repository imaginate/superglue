# @dest $LIB/superglue/_sgl_trim_tag
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
#
# @use _sgl_source trim_tag
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_trim_tag
# @use _sgl_trim_tag LINE
# @val LINE  Should be a TAG line.
# @return
#   0  PASS
############################################################
_sgl_trim_tag()
{
  if [[ -z "${1}" ]]; then
    return 0
  fi

  printf '%s' "${1}" \
    | ${sed} \
      -e 's/^[[:blank:]]*#[[:blank:]]*@[[:lower:]]\+[[:blank:]]\+//' \
      -e 's/[[:blank:]]\+$//'
}
readonly -f _sgl_trim_tag
