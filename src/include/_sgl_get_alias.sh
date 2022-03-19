# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
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
