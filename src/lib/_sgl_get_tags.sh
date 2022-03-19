# @dest $LIB/superglue/_sgl_get_tags
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
#
# @use _sgl_source get_tags
# @return
#   0  PASS
################################################################################

_sgl_source esc_key get_keys trim_blank trim_tag

############################################################
# Prints each TAG value. Checks should be ran before calling.
#
# @private
# @func _sgl_get_tags
# @use _sgl_get_tags SRC TAG
# @val SRC  Must be a valid file path.
# @val TAG  Must be a valid `superglue' tag.
#   `DEST'
#   `SET'
# @return
#   0  PASS
############################################################
_sgl_get_tags()
{
  local -r SRC="${1}"
  local -r TAG="${2}"
  local -i var=0
  local key
  local val
  local line
  local name
  local patt
  local value

  case "${TAG}" in
    DEST)
      patt='^[[:blank:]]*#[[:blank:]]*@dest\(ination\)\?[[:blank:]]\+'
      ;;
    SET)
      patt='^[[:blank:]]*#[[:blank:]]*@\(set\|var\|variable\)[[:blank:]]\+'
      var=1
      ;;
  esac

  while IFS= read -r line; do
    val="$(_sgl_trim_tag "${line}")"

    if [[ ${var} -eq 1 ]]; then
      key="$(_sgl_trim_blank "${val%%=*}")"
      val="$(_sgl_trim_blank "${val#*=}")"
      printf '%s' "${key}="
    fi

    if [[ "${val:0:1}" == "'" ]]; then
      val="${val:1}"
      val="${val%\'}"
      printf '%s\n' "${val}"
      continue
    fi

    if [[ "${val:0:1}" == '"' ]]; then
      val="${val:1}"
      val="${val%\"}"
    fi

    while IFS= read -r key; do
      if [[ -z "${key}" ]]; then
        continue
      fi

      name="${key:1}"
      if [[ "${key:1:1}" == '{' ]]; then
        name="${name:1}"
        name="${name%\}}"
      fi

      key="$(_sgl_esc_key "${key}")"
      value="${_SGL_DEFS[${name}]}"
      if [[ "${val:0:1}" == '$' ]]; then
        key="^${key}"
      else
        key="\([^\\]\)${key}"
        value="\1${value}"
      fi
      val="$(printf '%s' "${val}" | ${sed} -e "s/${key}/${value}/")"
    done <<< "$(_sgl_get_keys "${val}")"

    printf '%s\n' "${val}"
  done <<< "$(${grep} -e "${patt}" -- "${SRC}")"

  return 0
}
readonly -f _sgl_get_tags
