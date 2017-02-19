# @dest $LIB/superglue/_sgl_is_mode
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
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
