# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_err
# @use _sgl_err SILENT ERR [MSG]
# @val ERR      Must be an error from the below options or any valid integer
#               in the range of `1' to `126'.
#   `ERR|MISC'  An unknown error.
#   `OPT'       An invalid option.
#   `VAL'       An invalid or missing value.
#   `AUTH'      A permissions error.
#   `DPND'      A dependency error.
#   `CHLD'      A child process exited unsuccessfully.
#   `SGL'       A `superglue' script error.
# @val MSG     Can be any string.
# @val SILENT  Must be a `0' to print an error message or `1' to not.
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
  local title

  if [[ "${1}" != '0' ]] && [[ "${1}" != '1' ]]; then
    _sgl_err 0 SGL "invalid \`${FN}' SILENT \`${1}'"
  fi

  case "${2}" in
    ERR|MISC)
      title='ERROR'
      code=1
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
      if [[ "${2}" =~ ^[1-9][0-9]{,2}$ ]] && [[ ${2} -lt 127 ]]; then
        title='ERROR'
        code=${2}
      else
        _sgl_err ${1} SGL "invalid \`${FN}' ERR \`${2}'"
      fi
      ;;
  esac

  if [[ "${1}" == '0' ]]; then
    if [[ "${SGL_COLOR_ON}" == '1' ]]; then
      title="${SGL_RED}${title}${SGL_UNCOLOR}"
    elif [[ "${SGL_COLOR_OFF}" != '1' ]] && [[ -t 1 ]]; then
      title="${SGL_RED}${title}${SGL_UNCOLOR}"
    fi
    if [[ "${SGL_SILENT}" != '1' ]]; then
      printf '%s\n' "${title} ${3}" 1>&2
      if [[ "${SGL_VERBOSE}" == '1' ]]; then
        local details="$(caller)"
        printf '%s %s %s\n' '-' 'LINE' "${details%% *}" 1>&2
        printf '%s %s %s\n' '-' 'FILE' "${details##* }" 1>&2
      fi
    fi
  fi

  exit ${code}
}
readonly -f _sgl_err
