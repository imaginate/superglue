# @dest $LIB/superglue/_sgl_trim_ansi
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source trim_ansi
# @return
#   0  PASS
################################################################################

############################################################
# @func _sgl_trim_ansi
# @use _sgl_trim_ansi ANSI
# @val ANSI  Should be an ansi escape string.
# @return
#   0  PASS
############################################################
_sgl_trim_ansi()
{
  if [[ -n "${1}" ]]; then
    printf '%s' "${1}" \
      | ${sed} \
        -e 's/^\[//' \
        -e 's/m$//'  \
        -e 's/^\('"${ESC}"'\|\\e\|\\033\)//'
  fi
}
readonly -f _sgl_trim_ansi
