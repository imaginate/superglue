#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_unset_func
# @use _sgl_unset_func BUILTIN
# @val BUILTIN  Must be a built-in command.
# @return
#   0  PASS
############################################################
_sgl_unset_func()
{
  if unset -f $1 2> ${NIL} ; then
    return 0
  else
    return 0
  fi
}
readonly -f _sgl_unset_func
