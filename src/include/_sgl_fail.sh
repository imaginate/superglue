# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
################################################################################

############################################################
# @private
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
  local -i shh
  local title
  local err="${1}"

  case "${err}" in
    ERR|MISC)
      title='ERROR'
      err='ERR'
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
      if [[ ! "${err}" =~ ^[1-9][0-9]{,2}$ ]] || [[ ${err} -gt 126 ]]; then
        _sgl_err SGL "invalid \`${FN}' ERR \`${err}'"
      fi
      title='ERROR'
      err='ERR'
      ;;
  esac

  if _sgl_is_true "${silent}"; then
    shh=1
  elif _sgl_is_false "${silent}"; then
    shh=0
  elif [[ "${err}" == 'CHLD' ]]; then
    shh=$(_sgl_get_silent CHLD)
  else
    shh=$(_sgl_get_silent PRT)
  fi

  if [[ ${shh} -eq 0 ]]; then
    if _sgl_is_true "${SGL_COLOR_ON}"; then
      title="${SGL_RED}${title}${SGL_UNCOLOR}"
    elif ! _sgl_is_true "${SGL_COLOR_OFF}" && [[ -t 1 ]]; then
      title="${SGL_RED}${title}${SGL_UNCOLOR}"
    fi
    printf '%s\n' "${title} ${2}" 1>&2
    if _sgl_is_true "${SGL_VERBOSE}"; then
      local details="$(caller)"
      printf '%s %s %s\n' '-' 'LINE' "${details%% *}" 1>&2
      printf '%s %s %s\n' '-' 'FILE' "${details##* }" 1>&2
    fi
  fi

  return 0
}
readonly -f _sgl_fail
