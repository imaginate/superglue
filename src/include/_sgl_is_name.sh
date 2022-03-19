# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
################################################################################

############################################################
# @private
# @func _sgl_is_name
# @use _sgl_is_name PATH
# @val PATH  Should be a valid file system path.
# @return
#   0  PASS
#   1  FAIL
############################################################
_sgl_is_name()
{
  local name

  name="${1%/}"
  name="${name##*/}"

  if [[ -n "${name}" ]]      && \
     [[ "${name}" != '*' ]]  && \
     [[ "${name}" != '.*' ]]
  then
    return 0
  fi
  return 1
}
readonly -f _sgl_is_name
