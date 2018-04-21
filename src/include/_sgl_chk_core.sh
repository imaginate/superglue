# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
################################################################################

############################################################
# @private
# @func _sgl_chk_core
# @use _sgl_chk_core DIR ...FILE
# @val DIR   Must be a valid `superglue' directory path.
# @val FILE  Must be a valid filename within DIR.
# @return
#   0  PASS
# @exit-on-error
############################################################
_sgl_chk_core()
{
  local dir="${1}"
  local path

  if ! _sgl_is_dir "${dir}"; then
    _sgl_err DPND "missing core directory \`${dir}' - reinstall \`${SGL}'"
  fi
  shift

  for path in "${@}"; do
    path="${dir}/${path}"
    if ! _sgl_is_read "${path}"; then
      _sgl_err DPND "missing core file \`${path}' - reinstall \`${SGL}'"
    fi
  done
  return 0
}
readonly -f _sgl_chk_core
