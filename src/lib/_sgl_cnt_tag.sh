# @dest $LIB/superglue/_sgl_cnt_tag
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source cnt_tag
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_cnt_tag
# @use _sgl_cnt_tag TAG FILE
# @val FILE  Must be a valid file path.
# @val TAG   Must be a valid `superglue' tag.
#   `DEST'
#   `INCL'
#   `MODE'
#   `OWN'
#   `SET'
#   `VERS'
# @return
#   0  PASS
############################################################
_sgl_cnt_tag()
{
  local tag="${1}"
  local file="${2}"
  local -i count

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

  count="$(${grep} -c -e "${tag}" -- "${file}" 2> ${NIL} || :)"
  if [[ ! "${count}" =~ ^[0-9]+$ ]]; then
    count=0
  fi

  printf '%s' "${count}"
}
readonly -f _sgl_cnt_tag
