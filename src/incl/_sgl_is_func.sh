#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_is_func
# @use _sgl_is_func FUNC
# @val FUNC  Must be a valid `superglue' function. The `sgl_' prefix
#            is optional.
# @return
#   0  PASS  FUNC is a valid function.
#   1  FAIL  FUNC is not a valid function.
############################################################
_sgl_is_func()
{
  local func="${1}"
  local fn

  if [[ ! "${func}" =~ ^[a-z_]+$ ]]; then
    return 1
  fi

  func="${func#sgl_}"
  func="sgl_${func}"

  for fn in "${SGL_FUNCS[@]}"; do
    if [[ "${func}" == "${fn}" ]]; then
      return 0
    fi
  done
  return 1
}
readonly -f _sgl_is_func
