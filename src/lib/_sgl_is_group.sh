# @dest $LIB/superglue/_sgl_is_group
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source is_group
# @return
#   0  PASS
################################################################################

_sgl_source is_cmd is_flat which

############################################################
# @private
# @func _sgl_is_group
# @use _sgl_is_group GROUP
# @val GROUP  Should be a group name or id.
# @return
#   0  PASS  The GROUP is valid.
#   1  FAIL  The GROUP is invalid.
############################################################
_sgl_is_group()
{
  local grp="${1}"
  local cmd

  if ! _sgl_is_flat "${grp}"; then
    return 1
  fi

  cmd="$(_sgl_which getent)"
  if _sgl_is_cmd "${cmd}"; then
    if ${cmd} group "${grp}" > ${NIL} 2>&1; then
      return 0
    fi
    return 1
  fi

  return 0
}
readonly -f _sgl_is_group
