# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
################################################################################

############################################################
# @private
# @func _sgl_unset_funcs
# @use _sgl_unset_funcs ...BUILTIN
# @val BUILTIN  Must be a builtin command.
# @return
#   0  PASS
############################################################
_sgl_unset_funcs()
{
  while [[ ${#} -gt 0 ]]; do
    _sgl_unset_func ${1}
    shift
  done
}
readonly -f _sgl_unset_funcs
