# @dest $LIB/superglue/_sgl_trim_ansi
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
#
# @use _sgl_source trim_ansi
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_trim_ansi
# @use _sgl_trim_ansi ANSI
# @val ANSI  Should be an ansi escape string.
# @return
#   0  PASS
############################################################
_sgl_trim_ansi()
{
  if [[ -z "${1}" ]]; then
    return 0
  fi

  printf '%s' "${1}" \
    | ${sed} \
      -e 's/^\[//' \
      -e 's/m$//'  \
      -e 's/^\('"${ESC}"'\|\\e\|\\033\)//'
}
readonly -f _sgl_trim_ansi
