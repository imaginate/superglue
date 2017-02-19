# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @private
# @func _sgl_prefix
# @use _sgl_prefix FUNC
# @val FUNC  Should be a valid `superglue' function. The `sgl_' prefix
#            is optional. The FUNC may contain `*' for pattern matching.
# @return
#   0  PASS
############################################################
_sgl_prefix()
{
  printf '%s%s' 'sgl_' "${1#sgl_}"
}
readonly -f _sgl_prefix
