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
  local -r FN='sgl_source'
  local func
  local file

  [[ $# -gt 0 ]] || _sgl_err VAL "missing \`${FN}' FUNC"

  while [[ $# -gt 0 ]]; do
    [[ "$1" =~ ^[a-z_\*]+$ ]] || _sgl_err VAL "invalid \`${FN}' \`$1' FUNC"

    func="$1"
    [[ "${func}" =~ ^sgl_ ]] || func="sgl_${func}"

    if [[ "${func}" =~ \* ]]; then
      for file in ${SGL_LIB}/${func}; do
        [[ -f "${file}" ]] || _sgl_err VAL "invalid \`${FN}' \`${func}' FUNC"
        func=$(printf '%s' "${file}" | ${sed} -e "s|^${SGL_LIB}/||")
        declare -F "${func}" > ${NIL} || . "${file}"
      done
    else
      file="${SGL_LIB}/${func}"
      [[ -f "${file}" ]] || _sgl_err VAL "invalid \`${FN}' \`${func}' FUNC"
      declare -F "${func}" > ${NIL} || . "${file}"
    fi
    shift
  done
}
readonly -f sgl_source
