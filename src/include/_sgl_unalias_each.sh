# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
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
