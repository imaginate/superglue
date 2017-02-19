# @dest $LIB/superglue/_sgl_chk_tags
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source chk_tags
# @return
#   0  PASS
################################################################################

_sgl_source chk_tag

############################################################
# @private
# @func _sgl_chk_tags
# @use _sgl_chk_tags PRG SRC ...TAG
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
_sgl_chk_tags()
{
  local prg="${1}"
  local src="${2}"
  local tag

  for tag in "${@:2}"; do
    _sgl_chk_tag "${prg}" "${src}" "${tag}"
  done
  return 0
}
readonly -f _sgl_chk_tags
