# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
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
