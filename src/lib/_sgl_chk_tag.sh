# @dest $LIB/superglue/_sgl_chk_tag
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
#
# @use _sgl_source chk_tag
# @return
#   0  PASS
################################################################################

_sgl_source cnt_tag err get_keys has_def has_tag is_key trim_blank trim_tag

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
  local -r PRG="${1}"
  local -r SRC="${2}"
  local -r TAG="${3}"
  local key
  local val
  local line
  local name
  local patt
  local -i var=0
  local -i limit=0

  if ! _sgl_has_tag "${SRC}" "${TAG}"; then
    return 0
  fi

  case "${TAG}" in
    DEST)
      patt='^[[:blank:]]*#[[:blank:]]*@dest\(ination\)\?[[:blank:]]\+'
      ;;
    INCL)
      patt='^[[:blank:]]*#[[:blank:]]*@incl\(ude\)\?[[:blank:]]\+'
      ;;
    MODE)
      patt='^[[:blank:]]*#[[:blank:]]*@mode\?[[:blank:]]\+'
      name='mode'
      limit=1
      ;;
    OWN)
      patt='^[[:blank:]]*#[[:blank:]]*@own\(er\)\?[[:blank:]]\+'
      name='owner'
      limit=1
      ;;
    SET)
      patt='^[[:blank:]]*#[[:blank:]]*@\(set\|var\|variable\)[[:blank:]]\+'
      var=1
      ;;
    VERS)
      patt='^[[:blank:]]*#[[:blank:]]*@vers\(ion\)\?[[:blank:]]\+'
      name='version'
      limit=1
      ;;
  esac

  if [[ ${limit} -gt 0 ]]; then
    if [[ $(_sgl_cnt_tag "${SRC}" ${TAG}) -gt ${limit} ]]; then
      name="${limit} \`${name}' TAG"
      _sgl_err VAL "only ${name} allowed for \`${PRG}' SRC \`${SRC}'"
    fi
  fi

  while IFS= read -r line; do
    val="$(_sgl_trim_tag "${line}")"

    if [[ ${var} -eq 1 ]]; then
      key="$(_sgl_trim_blank "${val%%=*}")"
      if ! _sgl_is_key "${key}"; then
        key="KEY \`${key}' at LINE \`${line}'"
        _sgl_err VAL "invalid \`${PRG}' ${key} in SRC \`${SRC}'"
      fi
      if [[ ! "${val}" =~ = ]]; then
        val="VAL at LINE \`${line}'"
        _sgl_err VAL "missing \`${PRG}' ${val} in SRC \`${SRC}'"
      fi
      val="$(_sgl_trim_blank "${val#*=}")"
    fi

    if [[ "${val:0:1}" == "'" ]]; then
      if [[ "${val: -1}" != "'" ]]; then
        val="VALUE \`${val}' at LINE \`${line}'"
        _sgl_err VAL "invalid \`${PRG}' ${val} in SRC \`${SRC}'"
      fi
      continue
    fi

    if [[ "${val:0:1}" == '"' ]]; then
      if [[ "${val: -1}" != '"' ]]; then
        val="VALUE \`${val}' at LINE \`${line}'"
        _sgl_err VAL "invalid \`${PRG}' ${val} in SRC \`${SRC}'"
      fi
      val="${val:1}"
      val="${val%\"}"
    fi

    while IFS= read -r key; do
      if [[ -z "${key}" ]]; then
        continue
      fi
      name="${key:1}"

      if [[ "${key:1:1}" == '{' ]]; then
        if [[ "${key: -1:1}" != '}' ]]; then
          key="KEY \`${key}' at LINE \`${line}'"
          _sgl_err VAL "invalid \`${PRG}' ${key} in SRC \`${SRC}'"
        fi
        name="${name:1}"
        name="${name%\}}"
      fi

      if ! _sgl_is_key "${name}"; then
        key="KEY \`${key}' at LINE \`${line}'"
        _sgl_err VAL "invalid \`${PRG}' ${key} in SRC \`${SRC}'"
      fi

      if ! _sgl_has_def "${name}"; then
        key="KEY \`${key}' at LINE \`${line}'"
        _sgl_err VAL "undefined \`${PRG}' ${key} in SRC \`${SRC}'"
      fi
    done <<< "$(_sgl_get_keys "${val}")"
  done <<< "$(${grep} -e "${patt}" -- "${SRC}")"

  return 0
}
readonly -f _sgl_chk_tag
