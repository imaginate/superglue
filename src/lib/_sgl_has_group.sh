# @dest $LIB/superglue/_sgl_has_group
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
#
# @use _sgl_source has_group
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_has_group
# @use _sgl_has_group OWNER
# @val OWNER  Should be a valid USER and/or GROUP.
# @return
#   0  PASS  The OWNER has a GROUP.
#   1  FAIL  The OWNER does not have a GROUP.
############################################################
_sgl_has_group()
{
  if [[ -n "${1}" ]] && [[ "${1}" =~ :[^:] ]]; then
    return 0
  fi
  return 1
}
readonly -f _sgl_has_group
