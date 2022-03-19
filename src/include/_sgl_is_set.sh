# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
################################################################################

############################################################
# @private
# @func _sgl_is_set
# @use _sgl_is_set FUNC
# @val FUNC  Must be a valid function name.
# @return
#   0  PASS  The FUNC is set.
#   1  FAIL  The FUNC is not set.
############################################################
_sgl_is_set()
{
  if [[ -n "${1}" ]] && declare -F "${1}" > ${NIL}; then
    return 0
  fi
  return 1
}
readonly -f _sgl_is_set
