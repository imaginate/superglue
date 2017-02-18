# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_fail
# @use _sgl_fail ERR MSG
# @val ERR  Must be an error from the below options or any valid integer in the
#           range of `1' to `126'.
#   `ERR|MISC'  An unknown error.
#   `OPT'       An invalid option.
#   `VAL'       An invalid or missing value.
#   `AUTH'      A permissions error.
#   `DPND'      A dependency error.
#   `CHLD'      A child process exited unsuccessfully.
#   `SGL'       A `superglue' script error.
# @val MSG  Can be any string.
# @return
#   0  PASS
############################################################
_sgl_fail()
{
  local -r FN='_sgl_fail'
  local title

  case "${1}" in
    ERR|MISC)
      title='ERROR'
      ;;
    OPT)
      title='OPTION ERROR'
      ;;
    VAL)
      title='VALUE ERROR'
      ;;
    AUTH)
      title='AUTHORITY ERROR'
      ;;
    DPND)
      title='DEPENDENCY ERROR'
      ;;
    CHLD)
      title='CHILD ERROR'
      ;;
    SGL)
      title='SUPERGLUE ERROR'
      ;;
    *)
      if [[ ! "${1}" =~ ^[1-9][0-9]{,2}$ ]] || [[ ${1} -gt 126 ]]; then
        _sgl_err 0 SGL "invalid \`${FN}' ERR \`${1}'"
      fi
      title='ERROR'
      ;;
  esac

  if [[ "${SGL_COLOR_ON}" == '1' ]]; then
    title="${SGL_RED}${title}${SGL_UNCOLOR}"
  elif [[ "${SGL_COLOR_OFF}" != '1' ]] && [[ -t 1 ]]; then
    title="${SGL_RED}${title}${SGL_UNCOLOR}"
  fi

  if [[ "${SGL_SILENT}" != '1' ]]; then
    printf '%s\n' "${title} ${2}" 1>&2
    if [[ "${SGL_VERBOSE}" == '1' ]]; then
      local details="$(caller)"
      printf '%s %s %s\n' '-' 'LINE' "${details%% *}" 1>&2
      printf '%s %s %s\n' '-' 'FILE' "${details##* }" 1>&2
    fi
  fi

  return 0
}
readonly -f _sgl_fail
