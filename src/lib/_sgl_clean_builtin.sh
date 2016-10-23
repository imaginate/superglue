#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_clean_builtin
# @use _sgl_clean_builtin
# @return
#   0  PASS
############################################################
_sgl_clean_builtin()
{
  # Clean [Special Builtins](http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_14)
  # Builtins are not unset because bash is expected to be in [posix mode](https://www.gnu.org/software/bash/manual/html_node/Bash-POSIX-Mode.html#Bash-POSIX-Mode)
  # which disallows function names to be the same as special builtin names.
  _sgl_unalias return # must be cleaned 1st for `_sgl_unalias'
  _sgl_unalias shift  # must be cleaned before `_sgl_unalias_each'
  _sgl_unalias_each break continue eval exec exit export readonly set times \
    trap unset

  # Clean [Bourne Builtins](https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#Bourne-Shell-Builtins)
  _sgl_unset_funcs cd getopts hash pwd test umask
  _sgl_unalias_each cd getopts hash pwd test umask

  # Clean [Bash Builtins](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#Bash-Builtins)
  _sgl_unset_funcs bind builtin caller command declare echo enable false fc \
    help history let local logout printf read shopt source type typeset ulimit
  _sgl_unalias_each bind builtin caller command declare echo enable false fc \
    help history let local logout printf read shopt source type typeset ulimit
}
readonly -f _sgl_clean_builtin
