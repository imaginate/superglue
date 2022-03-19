# @dest $LIB/superglue/_sgl_is_ctrl
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
#
# @use _sgl_source is_ctrl
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_is_ctrl
# @use _sgl_is_ctrl CTRL
# @val CTRL  Should be a backup control method from below options.
#   `none|off'
#   `numbered|t'
#   `existing|nil'
#   `simple|never'
# @return
#   0  PASS  The CTRL is valid.
#   1  FAIL  The CTRL is invalid.
############################################################
_sgl_is_ctrl()
{
  case "${1}" in
    none|off)     ;;
    numbered|t)   ;;
    existing|nil) ;;
    simple|never) ;;
    *)
      return 1
      ;;
  esac
  return 0
}
readonly -f _sgl_is_ctrl
