#!/bin/bash
#
# @dest /lib/superglue/sgl_source
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use . /lib/superglue/sgl_source
# @return
#   0  PASS
################################################################################

############################################################
# @func sgl_source
# @use sgl_source ...FUNC
# @val FUNC  Must be a public `superglue' function.
# @return
#   0  PASS
############################################################
sgl_source()
{
  local func
  local file

  [[ $# -gt 0 ]] || _sgl_err VAL "missing \`sgl_source' FUNC"

  while [[ $# -gt 0 ]]; do
    [[ -n "$1" ]] || _sgl_err VAL "empty \`sgl_source' FUNC"

    func="$1"
    [[ "${func}" =~ ^sgl_ ]] || func="sgl_${func}"

    file="${SGL_LIB}/${func}"
    [[ -f "${file}" ]] || _sgl_err DPND "missing \`${func}' - reinstall \`superglue'"

    declare -F "${func}" > ${NIL} || . "${file}"

    shift
  done
}
readonly -f _sgl_source
