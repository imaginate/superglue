#!/bin/bash
#
# @dest /lib/superglue/_sgl_unset_func
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source unset_func
# @return
#   0  PASS
################################################################################

############################################################
# @func _sgl_unset_func
# @use _sgl_unset_func ...BUILTIN
# @val BUILTIN  Must be a built-in command.
# @return
#   0  PASS
############################################################
_sgl_unset_func()
{
  while [[ $# -gt 0 ]]; do
    unset -f "$1" 2> ${NIL} || true
    shift
  done
  return 0
}
