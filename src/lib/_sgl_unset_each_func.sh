#!/bin/bash
#
# @dest /lib/superglue/_sgl_unset_each_func
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source unset_each_func
# @return
#   0  PASS
################################################################################

############################################################
# @func _sgl_unset_each_func
# @use _sgl_unset_each_func ...BUILTIN
# @val BUILTIN  Must be a builtin command.
# @return
#   0  PASS
############################################################
_sgl_unset_each_func()
{
  while [[ $# -gt 0 ]]; do
    _sgl_unset_func $1
    shift
  done
}
readonly -f _sgl_unset_each_func
