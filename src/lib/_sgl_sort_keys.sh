# @dest $LIB/superglue/_sgl_sort_keys
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source sort_keys
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_sort_keys
# @use _sgl_sort_keys [...KEY]
# @val KEY  Must be a valid VAR key.
# @return
#   0  PASS
############################################################
_sgl_sort_keys()
{
  case ${#} in
    0)
      ;;
    1)
      printf '%s\n' "${1}"
      ;;
    *)
      local key
      for key in "${@}"; do
        printf '%s\n' "${key}"
      done | ${sort} -u -r
      ;;
  esac
  return 0
}
readonly -f _sgl_sort_keys
