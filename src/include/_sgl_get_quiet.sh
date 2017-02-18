# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# Prints the boolean for the below globals.
#   `SGL_QUIET'
#   `SGL_QUIET_PARENT'
#   `SGL_QUIET_CHILD'
#
# @func _sgl_get_quiet
# @use _sgl_get_quiet [PROC]
# @val PROC  Must be one of the below options.
#   `CHLD'  Child process.
#   `PRT'   Parent process.
# @return
#   0  PASS
############################################################
_sgl_get_quiet()
{
  local -i quiet=0

  if [[ "${SGL_QUIET}" == '1' ]]; then
    quiet=1
  else
    case "${1}" in
      CHLD)
        if [[ "${SGL_QUIET_CHILD}" == '1' ]]; then
          quiet=1
        fi
        ;;
      PRT)
        if [[ "${SGL_QUIET_PARENT}" == '1' ]]; then
          quiet=1
        fi
        ;;
    esac
  fi

  printf '%s' "${quiet}"
  return 0
}
readonly -f _sgl_get_quiet
