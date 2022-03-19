# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
################################################################################

############################################################
# @private
# @func _sgl_is_read
# @use _sgl_is_read FILE
# @val FILE  Should be a readable file path.
# @return
#   0  PASS
#   1  FAIL
############################################################
_sgl_is_read()
{
  if _sgl_is_name "${1}" && [[ -r "${1}" ]]; then
    return 0
  fi
  return 1
}
readonly -f _sgl_is_read
