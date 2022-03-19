# @dest $LIB/superglue/_sgl_is_mode
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
#
# @use _sgl_source is_mode
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_is_mode
# @use _sgl_is_mode MODE
# @val MODE  Should be a valid file mode.
# @return
#   0  PASS  The MODE is valid.
#   1  FAIL  The MODE is invalid.
############################################################
_sgl_is_mode()
{
  if [[ -n "${1}" ]]; then
    if [[ "${1}" =~ ^[ugoa]*([-+=]([rwxXst]+|[ugo]))+$ ]] || \
       [[ "${1}" =~ ^[-+=]?[0-7]{1,4}$ ]]
    then
      return 0
    fi
  fi
  return 1
}
readonly -f _sgl_is_mode
