# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
################################################################################

############################################################
# @private
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

  case "${name}" in
    sgl|sglue)
      name='superglue'
      ;;
    superglue)
      ;;
    *)
      if ! _sgl_is_func "${name}"; then
        _sgl_err SGL "invalid \`${FN}' CMD|FUNC \`${name}'"
      fi
      ;;
  esac

  path="${SGL_HELP}/${name}"
  ${cat} -- "${path}"
  _sgl_chk_exit ${?} ${cat} -- "${path}"

  exit 0
}
readonly -f _sgl_help
