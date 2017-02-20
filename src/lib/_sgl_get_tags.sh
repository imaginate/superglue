# @dest $LIB/superglue/_sgl_get_tags
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source get_tags
# @return
#   0  PASS
################################################################################

_sgl_source esc_key get_keys trim_tag

############################################################
# Prints each TAG value. Checks should be ran before calling.
#
# @private
# @func _sgl_get_tags
# @use _sgl_get_tags SRC TAG
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
############################################################
_sgl_get_tags()
{
  local src="${1}"
  local tag="${2}"
  local key
  local val
  local line
  local name
  local value

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
        name="${name:1}"
        name="${name%\}}"
      fi
      key="$(_sgl_esc_key "${key}")"
      value="${_SGL_DEFS[${name}]}"
      if [[ "${val:0:1}" == '$' ]]; then
        val="$(printf '%s' "${val}" | ${sed} -e "s/^${key}/${value}/")"
      else
        val="$(printf '%s' "${val}" | ${sed} -e "s/\([^\\]\)${key}/\1${value}/")"
      fi
    done <<< "$(_sgl_get_keys "${val}")"
    printf '%s\n' "${val}"
  done <<< "$(${grep} -e "${tag}" -- "${src}")"

  return 0
}
readonly -f _sgl_get_tags
