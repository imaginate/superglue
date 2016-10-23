#!/bin/bash
#
# @dest /lib/superglue/_sgl_help
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source help
# @return
#   0  PASS
################################################################################

############################################################
# @func _sgl_help
# @use _sgl_help [FUNC]
# @val FUNC  Must be a valid `superglue' function. The `sgl_' prefix is optional.
# @exit
#   0  PASS
############################################################
_sgl_help()
{
  local file="${SGL_HELP}/$1"

  [[ -d ${SGL_HELP} ]] || _sgl_err DPND "missing help dir - reinstall \`${SGL}'"
  [[ -f ${file} ]] || _sgl_err DPND "missing \`${file}' - reinstall \`${SGL}'"

  ${cat} ${file}
  exit 0
}
readonly -f _sgl_help
