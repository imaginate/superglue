# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# Prints the boolean for the global, `SGL_ALIAS'.
#
# @private
# @func _sgl_get_alias
# @use _sgl_get_alias
# @return
#   0  PASS
############################################################
_sgl_get_alias()
{
  local -i shorty=0

  if _sgl_is_true "${SGL_ALIAS}"; then
    shorty=1
  fi

  printf '%s' "${shorty}"
}
readonly -f _sgl_get_alias
