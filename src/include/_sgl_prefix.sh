# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
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
