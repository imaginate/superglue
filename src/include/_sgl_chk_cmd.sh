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
  local -r FN='_sgl_chk_cmd'
  local cmd

  if [[ ${#} -eq 0 ]]; then
    _sgl_err SGL "missing a CMD for \`${FN}' to check'"
  fi

  for cmd in "${@}"; do
    if ! _sgl_is_cmd "${cmd}"; then
      _sgl_err DPND "missing executable \`${1}'"
    fi
  done
  return 0
}
readonly -f _sgl_chk_cmd
