# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @private
# @func _sgl_cmd_to_str
# @use _sgl_cmd_to_str CMD [...OPT] [...VAL]
# @val CMD  Must be a valid executable path.
# @val OPT  Must be an option for the CMD.
# @val VAL  Must be a value for the CMD.
# @return
#   0  PASS
############################################################
_sgl_cmd_to_str()
{
  local str
  local val

  for val in "${@}"; do
    if [[ "${val}" =~ [[:blank:]] ]]; then
      val="\"${val}\""
    fi
    if [[ -n "${str}" ]]; then
      str="${str} ${val}"
    else
      str="${val}"
    fi
  done

  printf '%s' "${str}"
}
readonly -f _sgl_cmd_to_str
