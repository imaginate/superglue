#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_help
# @use _sgl_help CMD|FUNC
# @val CMD   Must be a valid `superglue' command.
# @val FUNC  Must be a valid `superglue' function. The `sgl_' prefix is optional.
# @exit
#   0  PASS
############################################################
_sgl_help()
{
  local file="${SGL_HELP}/$1"

  [[ "$1" =~ ^(sgl|sglue)$ ]] && file="${SGL_HELP}/superglue"

  [[ -d ${SGL_HELP} ]] || _sgl_err DPND "missing help dir - reinstall \`${SGL}'"
  [[ -f ${file} ]] || _sgl_err DPND "missing \`${file}' - reinstall \`${SGL}'"

  ${cat} ${file}
  exit 0
}
readonly -f _sgl_help
