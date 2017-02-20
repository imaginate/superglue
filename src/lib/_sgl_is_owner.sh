# @dest $LIB/superglue/_sgl_is_owner
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source is_owner
# @return
#   0  PASS
################################################################################

_sgl_source is_flat

############################################################
# @private
# @func _sgl_is_owner
# @use _sgl_is_owner OWNER
# @val OWNER  Should be a valid USER and/or GROUP.
# @return
#   0  PASS  The OWNER is a valid string.
#   1  FAIL  The OWNER is an invalid string.
############################################################
_sgl_is_owner()
{
  if ! _sgl_is_flat "${1}" || [[ "${1#*:}" =~ : ]]; then
    return 1
  fi
  return 0
}
readonly -f _sgl_is_owner
