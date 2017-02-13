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
  if [[ -z "${1}" ]]      || \
     [[ "${1}" == '*' ]]  || \
     [[ "${1}" == '.*' ]] || \
     [[ ! -a "${1}" ]]
  then
    return 1
  fi
  return 0
}
readonly -f _sgl_is_path
