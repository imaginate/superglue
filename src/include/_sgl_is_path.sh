# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
################################################################################

############################################################
# @private
# @func _sgl_is_path
# @use _sgl_is_path PATH
# @val PATH  Should be a valid file system path.
# @return
#   0  PASS
#   1  FAIL
############################################################
_sgl_is_path()
{
  if _sgl_is_name "${1}" && [[ -a "${1}" ]]; then
    return 0
  fi
  return 1
}
readonly -f _sgl_is_path
