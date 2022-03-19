# @dest $LIB/superglue/_sgl_cnt_tag
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
#
# @use _sgl_source cnt_tag
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_cnt_tag
# @use _sgl_cnt_tag SRC TAG
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
_sgl_cnt_tag()
{
  local src="${1}"
  local tag="${2}"
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

  count="$(${grep} -c -e "${tag}" -- "${src}" 2> ${NIL} || :)"
  if [[ ! "${count}" =~ ^[0-9]+$ ]]; then
    count=0
  fi

  printf '%s' "${count}"
}
readonly -f _sgl_cnt_tag
