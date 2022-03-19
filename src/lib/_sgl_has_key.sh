# @dest $LIB/superglue/_sgl_has_key
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
#
# @use _sgl_source has_key
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_has_key
# @use _sgl_has_key VALUE
# @val VALUE  Must be a TAG value.
# @return
#   0  PASS  The VALUE contains at least one KEY.
#   1  FAIL  The VALUE does not contain a KEY.
############################################################
_sgl_has_key()
{
  if [[ -z "${1}" ]]; then
    return 1
  elif [[ "${1}" =~ ^\$ ]] || [[ "${1}" =~ [^\\]\$ ]]; then
    return 0
  fi
  return 1
}
readonly -f _sgl_has_key
