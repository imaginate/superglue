# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @private
# @func _sgl_match_func
# @use _sgl_match_func FUNC
# @val FUNC  Must be a valid `superglue' function pattern. May contain `*'.
# @return
#   0  PASS  FUNC is a valid function pattern.
#   1  FAIL  FUNC is not a valid function pattern.
############################################################
_sgl_match_func()
{
  local func="${1}"
  local fn
  local re

  if [[ ! "${func}" =~ \* ]]; then
    if _sgl_is_func "${func}"; then
      return 0
    fi
    return 1
  fi

  re='^sgl_[a-z_*]+$'
  if [[ ! "${func}" =~ ${re} ]]; then
    return 1
  fi

  re="$(printf '%s' "${func}" | ${sed} -e 's/\*/[a-z_]*/g')"
  re="^${re}\$"
  for fn in "${SGL_FUNCS[@]}"; do
    if [[ "${fn}" =~ ${re} ]]; then
      return 0
    fi
  done
  return 1
}
readonly -f _sgl_match_func
