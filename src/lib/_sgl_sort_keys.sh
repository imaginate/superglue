# @dest $LIB/superglue/_sgl_sort_keys
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
#
# @use _sgl_source sort_keys
# @return
#   0  PASS
##############################################################################

############################################################
# @private
# @func _sgl_sort_keys
# @use _sgl_sort_keys [...KEY]
# @val KEY
#   Must be a valid VAR key.
# @return
#   0  PASS
############################################################
_sgl_sort_keys()
{
  if [[ ${#} -eq 1 ]]; then
    printf '%s\n' "${1}"
  elif [[ ${#} -gt 1 ]]; then
    local key
    "${sort}" -u -r \
      <<< "$( \
        for key in "${@}"; do \
          printf '%s\n' "${key}"; \
        done )" \
      2> "${NIL}"
  fi
  return 0
}
readonly -f _sgl_sort_keys
