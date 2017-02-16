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
#   0  PASS  A successful exit.
#   6  CHLD  A child process exited unsuccessfully.
#   7  SGL   A `superglue' script error.
############################################################
_sgl_help()
{
  local -r FN='_sgl_help'
  local name="${1}"
  local path
  local -i ret

  if [[ "${name}" == 'sgl' ]] || [[ "${name}" == 'sglue' ]]; then
    name='superglue'
  fi

  if [[ "${name}" != 'superglue' ]] && ! _sgl_is_func "${name}"; then
    _sgl_err 0 SGL "invalid \`${FN}' CMD|FUNC \`${name}'"
  fi

  path="${SGL_HELP}/${name}"
  ${cat} -- "${path}"
  ret=${?}
  if [[ ${ret} -ne 0 ]]; then
    _sgl_err 0 CHLD "\`${cat} -- \"${path}\"' exited with \`${ret}'"
  fi
  exit 0
}
readonly -f _sgl_help
