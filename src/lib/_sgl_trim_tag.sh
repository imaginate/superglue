# @dest $LIB/superglue/_sgl_trim_tag
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
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
