# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @private
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
  local prg

  if [[ ${code} -eq 0 ]]; then
    return 0
  fi

  shift
  cmdstr="$(_sgl_cmd_to_str "${@}")"

  if [[ -n "${FN}" ]]; then
    prg="${FN}"
  else
    prg="${SGL}"
  fi

  _sgl_err CHLD "\`${cmdstr}' in \`${prg}' exited with \`${code}'"
}
readonly -f _sgl_chk_exit
