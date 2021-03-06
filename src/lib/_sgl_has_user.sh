# @dest $LIB/superglue/_sgl_has_user
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source has_user
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_has_user
# @use _sgl_has_user OWNER
# @val OWNER  Should be a valid USER and/or GROUP.
# @return
#   0  PASS  The OWNER has a USER.
#   1  FAIL  The OWNER does not have a USER.
############################################################
_sgl_has_user()
{
  if [[ -n "${1}" ]] && [[ "${1:0:1}" != ':' ]]; then
    return 0
  fi
  return 1
}
readonly -f _sgl_has_user
