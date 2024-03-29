# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
################################################################################

############################################################
# @private
# @func _sgl_is_cmd
# @use _sgl_is_cmd CMD
# @val CMD  Should be a valid path to an executable.
# @return
#   0  PASS
#   1  FAIL
############################################################
_sgl_is_cmd()
{
  if _sgl_is_file "${1}" && [[ -x "${1}" ]]; then
    return 0
  fi
  return 1
}
readonly -f _sgl_is_cmd
