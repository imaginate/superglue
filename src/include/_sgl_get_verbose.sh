# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
################################################################################

############################################################
# Prints the boolean for the global, `SGL_VERBOSE'.
#
# @private
# @func _sgl_get_verbose
# @use _sgl_get_verbose
# @return
#   0  PASS
############################################################
_sgl_get_verbose()
{
  local -i chatty=0

  if _sgl_is_true "${SGL_VERBOSE}"; then
    chatty=1
  fi

  printf '%s' "${chatty}"
}
readonly -f _sgl_get_verbose
