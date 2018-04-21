# @dest $LIB/superglue/_sgl_match_patt
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
#
# @use _sgl_source match_patt
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_match_patt
# @use _sgl_match_patt PATT STR
# @val PATT  Must be a valid basic regular expression.
# @val STR   Can be any string.
# @return
#   0  PASS  The STR matches the PATT.
#   1  FAIL  The STR does not match the PATT.
############################################################
_sgl_match_patt()
{
  local -r PATT="${1}"
  local -r STR="${2}"

  if [[ -z "${PATT}" ]]; then
    return 1
  fi

  if ${grep} -q -e "${PATT}" <<< "${STR}"; then
    return 0
  fi
  return 1
}
readonly -f _sgl_match_patt
