# @dest $LIB/superglue/_sgl_raw_tags
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source raw_tags
# @return
#   0  PASS
################################################################################

_sgl_source trim_tag

############################################################
# Prints each TAG value. Checks should be ran before calling.
#
# @private
# @func _sgl_raw_tags
# @use _sgl_raw_tags SRC TAG
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
_sgl_raw_tags()
{
  local src="${1}"
  local tag="${2}"
  local line

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
    if [[ -n "${line}" ]]; then
      _sgl_trim_tag "${line}"
      printf '\n'
    fi
  done <<< "$(${grep} -e "${tag}" -- "${src}")"
  return 0
}
readonly -f _sgl_raw_tags
