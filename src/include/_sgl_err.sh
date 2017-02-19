# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @private
# @func _sgl_err
# @use _sgl_err ERR [MSG]
# @val ERR  Must be an error from the below options or any valid integer
#               in the range of `1' to `126'.
#   `ERR|MISC'  An unknown error.
#   `OPT'       An invalid option.
#   `VAL'       An invalid or missing value.
#   `AUTH'      A permissions error.
#   `DPND'      A dependency error.
#   `CHLD'      A child process exited unsuccessfully.
#   `SGL'       A `superglue' script error.
# @val MSG  Can be any string.
# @exit
#   1  ERR|MISC
#   2  OPT
#   3  VAL
#   4  AUTH
#   5  DPND
#   6  CHLD
#   7  INTL
############################################################
_sgl_err()
{
  local -r FN='_sgl_err'
  local -i code
  local -i shh
  local title
  local err="${1}"

  case "${err}" in
    ERR|MISC)
      title='ERROR'
      code=1
      err='ERR'
      ;;
    OPT)
      title='OPTION ERROR'
      code=2
      ;;
    VAL)
      title='VALUE ERROR'
      code=3
      ;;
    AUTH)
      title='AUTHORITY ERROR'
      code=4
      ;;
    DPND)
      title='DEPENDENCY ERROR'
      code=5
      ;;
    CHLD)
      title='CHILD ERROR'
      code=6
      ;;
    SGL)
      title='SUPERGLUE ERROR'
      ;;
    *)
      if [[ ! "${err}" =~ ^[1-9][0-9]{,2}$ ]] || [[ ${err} -gt 126 ]]; then
        _sgl_err SGL "invalid \`${FN}' ERR \`${err}'"
      fi
      title='ERROR'
      code=${err}
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

  exit ${code}
}
readonly -f _sgl_err
