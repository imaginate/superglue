# @dest $LIB/superglue/_sgl_has_group
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
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
