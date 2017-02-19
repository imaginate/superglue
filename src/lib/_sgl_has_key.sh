# @dest $LIB/superglue/_sgl_has_key
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
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
