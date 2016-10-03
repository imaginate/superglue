#!/bin/bash
#
# @dest /lib/superglue/_sgl_source
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use . /lib/superglue/_sgl_source
# @return
#   0  PASS
################################################################################

############################################################
# @func _sgl_source
# @use _sgl_source ...FUNC
# @val FUNC  Must be a private `superglue' command.
# @return
#   0  PASS
############################################################
_sgl_source()
{
  while [[ $# -gt 0 ]]; do
    if [[ -f "${SGL_LIB}/_sgl_$1" ]]; then
      declare -F "_sgl_$1" > ${NIL} || . "${SGL_LIB}/_sgl_$1"
    else
      _sgl_err DPND "missing core func - reinstall \`superglue'"
    fi
    shift
  done
}
readonly -f _sgl_source
