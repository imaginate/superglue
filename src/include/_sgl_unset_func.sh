# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
################################################################################

############################################################
# @private
# @func _sgl_unset_func
# @use _sgl_unset_func BUILTIN
# @val BUILTIN  Must be a built-in command.
# @return
#   0  PASS
############################################################
_sgl_unset_func()
{
  if unset -f ${1} 2> ${NIL}; then
    return 0
  fi
  return 0
}
readonly -f _sgl_unset_func
