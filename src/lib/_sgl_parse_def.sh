# @dest $LIB/superglue/_sgl_parse_def
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
#
# @use _sgl_source parse_def
# @return
#   0  PASS
################################################################################

_sgl_source err esc_val is_key

############################################################
# Parses a KEY=VALUE pair and adds it to the global
# associative array, `_SGL_DEFS'.
#
# @private
# @func _sgl_parse_def
# @use _sgl_parse_def PRG OPT VAR
# @val OPT   Must be a valid PRG option.
# @val PRG   Must be a the name of the command or function calling this helper.
# @val VAR   Should be a valid `KEY=VALUE' pair. The KEY must start with a character
#            matching `[a-zA-Z_]', only contain characters `[a-zA-Z0-9_]', and end
#            with a character matching `[a-zA-Z0-9]'.
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
_sgl_parse_def()
{
  local prg="${1}"
  local opt="${2}"
  local var="${3}"
  local key
  local val

  if [[ -z "${var}" ]]; then
    _sgl_err VAL "missing \`${prg}' \`${opt}' VAR"
  fi

  if [[ ! "${var}" =~ = ]]; then
    _sgl_err VAL "missing \`${prg}' \`${opt}' VAR \`${var}' VALUE"
  fi

  key="${var%%=*}"
  val="${var#*=}"

  if ! _sgl_is_key "${key}"; then
    _sgl_err VAL "invalid \`${prg}' \`${opt}' KEY \`${key}' in VAR \`${var}'"
  fi

  _SGL_DEFS["${key}"]="$(_sgl_esc_val "${val}")"
  return 0
}
readonly -f _sgl_parse_def
