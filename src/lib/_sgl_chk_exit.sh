# @dest $LIB/superglue/_sgl_chk_exit
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source chk_exit
# @return
#   0  PASS
################################################################################

_sgl_source cmd_to_str err

############################################################
# @func _sgl_chk_exit
# @use _sgl_chk_exit RET CMD [...OPT] [...VAL]
# @val CMD  Must be a valid executable path.
# @val OPT  Must be an option for the CMD.
# @val VAL  Must be a value for the CMD.
# @val RET  Must be the return code for the CMD.
# @return
#   0  PASS
# @exit-on-error
#   6  CHLD  A child process exited unsuccessfully.
############################################################
_sgl_chk_exit()
{
  local -i code=${1}
  local cmdstr

  if [[ ${code} -eq 0 ]]; then
    return 0
  fi

  shift
  cmdstr="$(_sgl_cmd_to_str "${@}")"
  _sgl_err ${silent} CHLD "\`${cmdstr}' in \`${FN}' exited with \`${code}'"
}
readonly -f _sgl_chk_exit
