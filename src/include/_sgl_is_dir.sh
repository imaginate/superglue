# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_is_dir
# @use _sgl_is_dir DIR
# @val DIR  Should be a valid directory path.
# @return
#   0  PASS
#   1  FAIL
############################################################
_sgl_is_dir()
{
  if _sgl_is_name "${1}" && [[ -d "${1}" ]]; then
    return 0
  fi
  return 1
}
readonly -f _sgl_is_dir
