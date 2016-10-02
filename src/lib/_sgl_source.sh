#!/bin/bash
#
# @dest /lib/superglue/_sgl_source
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use . /lib/superglue/_sgl_source
# @return
#   0  PASS
################################################################################

############################################################
# @func _sgl_source
# @use _sgl_source ...FUNC
# @val FUNC  Must be a private `superglue' command.
# @return
#   0  PASS
############################################################
_sgl_source()
{
  local path

  while [[ $# -gt 0 ]]; do

    path="${SGL_LIB}/_sgl_$1"

    if [[ ! -f "${path}" ]]; then
      printf "%s\n" "DEP ERROR missing core func - reinstall \`superglue'" 1>&2
      exit 5
    fi

    . "${path}"
    shift
  done
}
readonly -f _sgl_source
