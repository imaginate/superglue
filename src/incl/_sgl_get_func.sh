#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_get_func
# @use _sgl_get_func FUNC
# @val FUNC  Must be a valid `superglue' function. The `sgl_' prefix is optional.
# @return
#   0  PASS  FUNC is a valid function.
#   1  FAIL  FUNC is not a valid function.
############################################################
_sgl_get_func()
{
  local func="$1"

  if [[ ! "${func}" =~ ^[a-z_]+$ ]]; then
    printf '%s' "${func}"
    return 1
  fi

  [[ "${func}" =~ ^sgl_ ]] || func="sgl_$1"

  if [[ ! -f "${SGL_LIB}/${func}" ]]; then
    printf '%s' "${func}"
    return 1
  fi

  printf '%s' "${func}"
  return 0
}
readonly -f _sgl_get_func
