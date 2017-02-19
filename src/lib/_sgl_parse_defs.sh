# @dest $LIB/superglue/_sgl_parse_defs
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source parse_defs
# @return
#   0  PASS
################################################################################

_sgl_source err parse_def

############################################################
# Parses each KEY=VALUE pair and adds them to the global
# associative array, `_SGL_DEFS'.
#
# @private
# @func _sgl_parse_defs
# @use _sgl_parse_defs PRG OPT VARS
# @val OPT   Must be a valid PRG option.
# @val PRG   Must be a the name of the command or function calling this helper.
# @val VAR   Should be a valid `KEY=VALUE' pair. The KEY must start with a character
#            matching `[a-zA-Z_]', only contain characters `[a-zA-Z0-9_]', and end
#            with a character matching `[a-zA-Z0-9]'.
# @val VARS  Should be a list of one or more VAR separated by `,'.
# @return
#   0  PASS
# @exit-on-error
#   1  ERR   An unknown error.
#   2  OPT   An invalid option.
#   3  VAL   An invalid or missing value.
#   4  AUTH  A permissions error.
#   5  DPND  A dependency error.
#   6  CHLD  A child process exited unsuccessfully.
#   7  SGL   A `superglue' script error.
############################################################
_sgl_parse_defs()
{
  local prg="${1}"
  local opt="${2}"
  local vars="${3}"

  if [[ -z "${vars}" ]]; then
    _sgl_err VAL "missing \`${prg}' \`${opt}' VARS"
  fi

  while IFS= read -r -d ',' var; do
    _sgl_parse_def "${prg}" "${opt}" "${var}"
  done <<< "${vars%,},"

  return 0
}
readonly -f _sgl_parse_defs
