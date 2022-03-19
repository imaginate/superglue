# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
################################################################################

############################################################
# @private
# @func _sgl_unalias_each
# @use _sgl_unalias_each ...BUILTIN
# @val BUILTIN  Must be a built-in command.
# @return
#   0  PASS
############################################################
_sgl_unalias_each()
{
  while [[ ${#} -gt 0 ]]; do
    _sgl_unalias ${1}
    shift
  done
}
readonly -f _sgl_unalias_each
