# @dest $LIB/superglue/_sgl_chk_tag
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source chk_tag
# @return
#   0  PASS
################################################################################

_sgl_source err get_keys has_def has_tag is_key trim_tag

############################################################
# @private
# @func _sgl_chk_tag
# @use _sgl_chk_tag PRG SRC TAG
# @val PRG  Must be a the name of the command or function calling this helper.
# @val SRC  Must be a valid file path.
# @val TAG  Must be a valid `superglue' tag.
#   `DEST'
#   `INCL'
#   `MODE'
#   `OWN'
#   `SET'
#   `VERS'
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
_sgl_chk_tag()
{
  local prg="${1}"
  local src="${2}"
  local tag="${3}"
  local key
  local val
  local line
  local name

  if ! _sgl_has_tag "${src}" "${tag}"; then
    return 0
  fi

  case "${tag}" in
    DEST)
      tag='^[[:blank:]]*#[[:blank:]]*@dest\(ination\)\?[[:blank:]]\+'
      ;;
    INCL)
      tag='^[[:blank:]]*#[[:blank:]]*@incl\(ude\)\?[[:blank:]]\+'
      ;;
    MODE)
      tag='^[[:blank:]]*#[[:blank:]]*@mode\?[[:blank:]]\+'
      ;;
    OWN)
      tag='^[[:blank:]]*#[[:blank:]]*@own\(er\)\?[[:blank:]]\+'
      ;;
    SET)
      tag='^[[:blank:]]*#[[:blank:]]*@\(set\|var\|variable\)[[:blank:]]\+'
      ;;
    VERS)
      tag='^[[:blank:]]*#[[:blank:]]*@vers\(ion\)\?[[:blank:]]\+'
      ;;
  esac

  while IFS= read -r line; do
    val="$(_sgl_trim_tag "${line}")"
    while IFS= read -r key; do
      if [[ -z "${key}" ]]; then
        continue
      fi
      name="${key:1}"

      if [[ "${key:1:1}" == '{' ]]; then
        if [[ "${key: -1:1}" != '}' ]]; then
          key="KEY \`${key}' at LINE \`${line}'"
          _sgl_err VAL "invalid \`${prg}' ${key} in SRC \`${src}'"
        fi
        name="${name:1}"
        name="${name%\}}"
      fi

      if ! _sgl_is_key "${name}"; then
        key="KEY \`${key}' at LINE \`${line}'"
        _sgl_err VAL "invalid \`${prg}' ${key} in SRC \`${src}'"
      fi

      if ! _sgl_has_def "${name}"; then
        key="KEY \`${key}' at LINE \`${line}'"
        _sgl_err VAL "undefined \`${prg}' ${key} in SRC \`${src}'"
      fi
    done <<< "$(_sgl_get_keys "${val}")"
  done <<< "$(${grep} -e "${tag}" -- "${src}")"

  return 0
}
readonly -f _sgl_chk_tag
