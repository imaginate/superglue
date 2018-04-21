# @dest $LIB/superglue/_sgl_get_keys
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
#
# @use _sgl_source get_keys
# @return
#   0  PASS
################################################################################

_sgl_source has_key

############################################################
# @private
# @func _sgl_get_keys
# @use _sgl_get_keys VALUE
# @val VALUE  Should be a TAG value.
# @return
#   0  PASS
############################################################
_sgl_get_keys()
{
  local val="${1}"

  while _sgl_has_key "${val}"; do
    while [[ "${val:0:1}" != '$' ]]; do
      val="$(printf '%s' "${val}" | ${sed} -e 's/^\\\$//' \
        -e 's/^[^\$]*\([^\$]\$\)/\1/' -e 's/^[^\\\$]//')"
    done
    if [[ ${#val} -eq 1 ]]; then
      return 0
    elif [[ "${val:1:1}" == '{' ]]; then
      if [[ "${val}" =~ \} ]]; then
        printf '%s\n' "${val%%\}*}}"
        val="${val#*\}}"
      else
        printf '%s\n' "${val}"
        return 0
      fi
    elif [[ "${val:1:1}" =~ [a-zA-Z0-9_] ]]; then
      printf '%s\n' "${val}" | ${sed} -e 's/^\(\$[a-zA-Z0-9_]\+\).*$/\1/'
      val="$(printf '%s' "${val:1}" | ${sed} -e 's/^[a-zA-Z0-9_]\+//')"
    else
      printf '%s\n' "${val:0:2}"
      return 0
    fi
  done
  return 0
}
readonly -f _sgl_get_keys
