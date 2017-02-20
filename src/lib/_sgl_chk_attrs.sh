# @dest $LIB/superglue/_sgl_chk_attrs
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source chk_attrs
# @return
#   0  PASS
################################################################################

_sgl_source err is_attr

############################################################
# @private
# @func _sgl_chk_attrs
# @use _sgl_chk_attrs PRG OPT ATTRS
# @val OPT    Must be a valid PRG option.
# @val PRG    Must be a the name of the command or function calling this helper.
# @val ATTR   Must be a file attribute from the below options.
#   `mode'
#   `ownership'
#   `timestamps'
#   `context'
#   `links'
#   `xattr'
#   `all'
# @val ATTRS  Must be a list of one or more ATTR separated by a `,'.
# @return
#   0  PASS
# @exit-on-error
#   3  VAL  An invalid or missing value.
############################################################
_sgl_chk_attrs()
{
  local -r PRG="${1}"
  local -r OPT="${2}"
  local -r ATTRS="${3}"
  local attr

  if [[ -z "${ATTRS}" ]]; then
    _sgl_err VAL "missing \`${PRG}' \`${OPT}' ATTRS"
  fi

  if [[ ! "${ATTRS}" =~ ^[a-z,]+$ ]]; then
    _sgl_err VAL "invalid \`${PRG}' \`${OPT}' ATTRS \`${ATTRS}'"
  fi

  while IFS= read -r -d ',' attr; do
    if ! _sgl_is_attr "${attr}"; then
      _sgl_err VAL "invalid \`${PRG}' \`${OPT}' ATTR \`${attr}'"
    fi
  done <<< "${ATTRS%,},"
  return 0
}
readonly -f _sgl_chk_attrs
