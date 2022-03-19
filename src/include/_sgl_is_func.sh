# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
################################################################################

############################################################
# @private
# @func _sgl_is_func
# @use _sgl_is_func FUNC
# @val FUNC  Must be a valid `superglue' function.
# @return
#   0  PASS  FUNC is a valid function.
#   1  FAIL  FUNC is not a valid function.
############################################################
_sgl_is_func()
{
  local func="${1}"
  local fn

  if [[ ! "${func}" =~ ^sgl_[a-z_]+$ ]]; then
    return 1
  fi

  for fn in "${SGL_FUNCS[@]}"; do
    if [[ "${func}" == "${fn}" ]]; then
      return 0
    fi
  done
  return 1
}
readonly -f _sgl_is_func
