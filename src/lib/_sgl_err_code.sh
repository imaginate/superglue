# @dest $LIB/superglue/_sgl_err_code
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
#
# @use _sgl_source err_code
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_err_code
# @use _sgl_err_code ERR
# @val ERR  Must be an error from the below options or any valid integer in the
#           range of `1' to `126'.
#   `ERR|MISC'  An unknown error.
#   `OPT'       An invalid option.
#   `VAL'       An invalid or missing value.
#   `AUTH'      A permissions error.
#   `DPND'      A dependency error.
#   `CHLD'      A child process exited unsuccessfully.
#   `SGL'       A `superglue' script error.
# @return
#   0  PASS
############################################################
_sgl_err_code()
{
  local -i code=0

  case "${1}" in
    ERR|MISC)
      code=1
      ;;
    OPT)
      code=2
      ;;
    VAL)
      code=3
      ;;
    AUTH)
      code=4
      ;;
    DPND)
      code=5
      ;;
    CHLD)
      code=6
      ;;
    SGL)
      code=7
      ;;
    *)
      if [[ "${1}" =~ ^[1-9][0-9]{,2}$ ]] && [[ ${1} -lt 127 ]]; then
        code=${1}
      fi
      ;;
  esac

  printf '%s' ${code}
}
readonly -f _sgl_err_code
