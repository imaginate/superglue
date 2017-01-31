#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_chk_cmd
# @use _sgl_chk_cmd ...CMD
# @val CMD  Must be a valid path to an executable.
# @return
#   0  PASS
############################################################
_sgl_chk_cmd()
{
  while [[ $# -gt 0 ]]; do
    [[ -x "$1" ]] || _sgl_err DPND "missing executable \`$1'"
    shift
  done
}
readonly -f _sgl_chk_cmd
