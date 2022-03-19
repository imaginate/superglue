# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
################################################################################

############################################################
# @private
# @func _sgl_is_true
# @use _sgl_is_true BOOL
# @val BOOL  Should be a boolean value from the below options.
#   `0|n|no'   FALSE
#   `1|y|yes'  TRUE
# @return
#   0  PASS  The BOOL is TRUE.
#   1  FAIL  The BOOL is FALSE or unset.
############################################################
_sgl_is_true()
{
  if [[ -n "${1}" ]]; then
    case "${1}" in
      1|y|Y|t|T|yes|Yes|YES|true|True|TRUE)
        return 0
        ;;
    esac
  fi
  return 1
}
readonly -f _sgl_is_true
