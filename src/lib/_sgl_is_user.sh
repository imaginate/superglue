# @dest $LIB/superglue/_sgl_is_user
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source is_user
# @return
#   0  PASS
################################################################################

_sgl_source is_cmd which

############################################################
# @private
# @func _sgl_is_user
# @use _sgl_is_user USER
# @val USER  Should be a user name or id.
# @return
#   0  PASS  The USER is valid.
#   1  FAIL  The USER is invalid.
############################################################
_sgl_is_user()
{
  local user="${1}"
  local cmd

  if [[ -z "${user}" ]] || [[ "${user}" =~ [[:space:]] ]]; then
    return 1
  fi

  cmd="$(_sgl_which getent)"
  if _sgl_is_cmd "${cmd}"; then
    if ${cmd} passwd "${user}" > ${NIL} 2>&1; then
      return 0
    fi
    return 1
  fi

  cmd="$(_sgl_which id)"
  if _sgl_is_cmd "${cmd}"; then
    if ${cmd} "${user}" > ${NIL} 2>&1; then
      return 0
    fi
    return 1
  fi

  return 0
}
readonly -f _sgl_is_user
