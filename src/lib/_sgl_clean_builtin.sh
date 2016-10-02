#!/bin/bash
#
# @dest /lib/superglue/_sgl_clean_builtin
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source clean_builtin
# @return
#   0  PASS
################################################################################

############################################################
# @func _sgl_clean_builtin
# @use _sgl_clean_builtin ...BUILTIN
# @val BUILTIN  Must be a builtin command.
# @return
#   0  PASS
############################################################
_sgl_clean_builtin()
{
  # clean builtins used by `_sgl_unalias' and `_sgl_unset_func'
  unalias true   2> ${NIL} || :
  unalias shift  2> ${NIL} || :
  unalias unset  2> ${NIL} || :
  unalias return 2> ${NIL} || :
  unset -f true  2> ${NIL} || :

  # clean special builtins
  _sgl_unalias break continue eval exec exit export readonly set trap

  # clean remaining builtins
  _sgl_unset_func bind builtin caller cd command declare echo enable false fc \
    hash help history let local logout printf pwd read source test times trap \
    type typeset ulimit umask
  _sgl_unalias bind builtin caller cd command declare echo enable false fc \
    hash help history let local logout printf pwd read source test times trap \
    type typeset ulimit umask
}
