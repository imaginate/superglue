#!/bin/bash
#
# @dest /lib/superglue/_sgl_unalias
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source unalias
# @return
#   0  PASS
################################################################################

############################################################
# @func _sgl_unalias
# @use _sgl_unalias ...BUILTIN
# @val BUILTIN  Must be a built-in command.
# @return
#   0  PASS
############################################################
_sgl_unalias()
{
  while [[ $# -gt 0 ]]; do
    unalias "$1" 2> ${NIL} || true
    shift
  done
  return 0
}
