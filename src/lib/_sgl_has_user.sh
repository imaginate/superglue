# @dest $LIB/superglue/_sgl_has_user
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
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
