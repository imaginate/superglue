# @dest $LIB/superglue/_sgl_is_key
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
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
