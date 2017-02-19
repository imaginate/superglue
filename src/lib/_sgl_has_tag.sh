# @dest $LIB/superglue/_sgl_has_tag
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source has_tag
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_has_tag
# @use _sgl_has_tag TAG FILE
# @val FILE  Must be a valid file path.
# @val TAG   Must be a valid `superglue' tag.
#   `DEST'
#   `INCL'
#   `MODE'
#   `OWN'
#   `SET'
#   `VERS'
# @return
#   0  PASS  The FILE contains at least one TAG.
#   1  FAIL  The FILE does not contain a TAG.
############################################################
_sgl_has_tag()
{
  local tag="${1}"
  local file="${2}"

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

  if ${grep} -q -e "${tag}" -- "${file}"; then
    return 0
  fi
  return 1
}
readonly -f _sgl_has_tag
