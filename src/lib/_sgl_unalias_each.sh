#!/bin/bash
#
# @dest /lib/superglue/_sgl_unalias_each
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source unalias_each
# @return
#   0  PASS
################################################################################

############################################################
# @func _sgl_unalias_each
# @use _sgl_unalias_each ...BUILTIN
# @val BUILTIN  Must be a built-in command.
# @return
#   0  PASS
############################################################
_sgl_unalias_each()
{
  while [[ $# -gt 0 ]]; do
    _sgl_unalias $1
    shift
  done
  return 0
}
readonly -f _sgl_unalias_each
