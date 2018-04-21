# @dest $LIB/superglue/_sgl_get_tmp
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
#
# @use _sgl_source get_tmp
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_get_tmp
# @use _sgl_get_tmp [PREFIX]
# @val PREFIX  Can be any string.
# @return
#   0  PASS
############################################################
_sgl_get_tmp()
{
  local base="${TMP}/.sgl"
  local pre="${1}"
  local -ir MAX=999999
  local -i i=0

  if [[ -n "${pre}" ]]; then
    pre=".${pre##.}"
    pre="${pre%%.}"
  fi

  while _sgl_is_file "${base}${pre}.${i}"; do
    i=$(( i + 1 ))
    if [[ ${i} -gt ${MAX} ]]; then
      if [[ "${pre}" =~ \.x+$ ]]; then
        _sgl_get_tmp "${pre}x"
      else
        _sgl_get_tmp "${pre}.x"
      fi
      return 0
    fi
  done
  printf '%s' "${base}${pre}.${i}"
}
readonly -f _sgl_get_tmp
