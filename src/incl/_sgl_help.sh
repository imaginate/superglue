#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_help
# @use _sgl_help CMD|FUNC
# @val CMD   Must be a valid `superglue' command.
# @val FUNC  Must be a valid `superglue' function.
# @exit
#   0  PASS
############################################################
_sgl_help()
{
  local name="${1}"
  local dir="${SGL_HELP}"
  local path
  local -i rt

  if ! _sgl_is_dir "${dir}"; then
    _sgl_err 0 DPND "missing help dir \`${dir}' - reinstall \`${SGL}'"
  fi

  if [[ "${name}" == 'sgl' ]] || [[ "${name}" == 'sglue' ]]; then
    name='superglue'
  fi

  path="${dir}/${name}"

  if ! _sgl_is_read "${path}"; then
    _sgl_err 0 DPND "missing help file \`${path}' - reinstall \`${SGL}'"
  fi

  ${cat} -- "${path}"
  rt=${?}
  if [[ ${rt} -ne 0 ]]; then
    _sgl_err 0 CHLD "\`${cat} -- \"${path}\"' exited with \`${rt}'"
  fi

  exit 0
}
readonly -f _sgl_help
