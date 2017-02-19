# @dest $LIB/superglue/_sgl_is_key
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source is_key
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_is_key
# @use _sgl_is_key VAR
# @val VAR  Should be a valid KEY=VALUE pair.
# @return
#   0  PASS  The KEY is valid.
#   1  FAIL  The KEY is invalid.
############################################################
_sgl_is_key()
{
  if [[ "${1}" =~ ^[a-zA-Z0-9_]+$ ]] && \
     [[ "${1}" =~ ^[a-zA-Z_]      ]] && \
     [[ "${1}" =~  [a-zA-Z0-9]$   ]]
  then
    return 0
  fi
  return 1
}
readonly -f _sgl_is_key
