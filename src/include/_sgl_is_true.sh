# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_is_true
# @use _sgl_is_true BOOL
# @val BOOL  Should be a boolean value from the below options.
#   `0|n|no'   FALSE
#   `1|y|yes'  TRUE
# @return
#   0  TRUE
#   1  FALSE
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
