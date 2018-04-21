# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
################################################################################

############################################################
# @private
# @func _sgl_source
# @use _sgl_source ...FUNC
# @val FUNC  Must be a private `superglue' function.
# @return
#   0  PASS
# @exit-on-error
############################################################
_sgl_source()
{
  local func
  local path

  if [[ ${#} -eq 0 ]]; then
    return 0
  fi

  for func in "${@}"; do
    func="_sgl_${func}"
    if _sgl_is_set "${func}"; then
      continue
    fi
    path="${SGL_LIB}/${func}"
    if ! _sgl_is_read "${path}"; then
      _sgl_err DPND "missing core file \`${path}' - reinstall \`${SGL}'"
    fi
    . "${path}"
  done
  return 0
}
readonly -f _sgl_source
