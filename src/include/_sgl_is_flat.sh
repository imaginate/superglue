# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
################################################################################

############################################################
# @private
# @func _sgl_is_flat
# @use _sgl_is_flat STR
# @val STR  Can be any string.
# @return
#   0  PASS
#   1  FAIL
############################################################
_sgl_is_flat()
{
  if [[ -z "${1}" ]] || [[ "${1}" =~ [[:space:]] ]]; then
    return 1
  fi
  return 0
}
readonly -f _sgl_is_flat
