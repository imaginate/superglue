# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
################################################################################

############################################################
# @private
# @func _sgl_is_false
# @use _sgl_is_false BOOL
# @val BOOL  Should be a boolean value from the below options.
#   `0|n|no'   FALSE
#   `1|y|yes'  TRUE
# @return
#   0  PASS  The BOOL is FALSE.
#   1  FAIL  The BOOL is TRUE or unset.
############################################################
_sgl_is_false()
{
  if [[ -n "${1}" ]]; then
    case "${1}" in
      0|n|N|f|F|no|No|NO|false|False|FALSE)
        return 0
        ;;
    esac
  fi
  return 1
}
readonly -f _sgl_is_false
