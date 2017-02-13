#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_is_path
# @use _sgl_is_path PATH
# @val PATH  Should be a valid file system path.
# @return
#   0  PASS
#   1  FAIL
############################################################
_sgl_is_path()
{
  local path="${1%/}"
  local name="${path##*/}"

  if [[ -n "${name}" ]]      && \
     [[ "${name}" != '*' ]]  && \
     [[ "${name}" != '.*' ]] && \
     [[ -a "${path}" ]]
  then
    return 0
  fi
  return 1
}
readonly -f _sgl_is_path
