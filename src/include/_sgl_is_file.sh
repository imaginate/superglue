# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_is_file
# @use _sgl_is_file FILE
# @val FILE  Should be a valid file path.
# @return
#   0  PASS
#   1  FAIL
############################################################
_sgl_is_file()
{
  if _sgl_is_name "${1}" && [[ -f "${1}" ]]; then
    return 0
  fi
  return 1
}
readonly -f _sgl_is_file
