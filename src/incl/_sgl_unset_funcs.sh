#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_unset_funcs
# @use _sgl_unset_funcs ...BUILTIN
# @val BUILTIN  Must be a builtin command.
# @return
#   0  PASS
############################################################
_sgl_unset_funcs()
{
  while [[ $# -gt 0 ]]; do
    _sgl_unset_func $1
    shift
  done
}
readonly -f _sgl_unset_funcs
