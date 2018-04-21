# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
################################################################################

############################################################
# Prints the boolean for the below globals.
#   `SGL_QUIET'
#   `SGL_QUIET_PARENT'
#   `SGL_QUIET_CHILD'
#
# @private
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
  local -i shh=0

  if _sgl_is_true "${SGL_QUIET}"; then
    shh=1
  else
    case "${1}" in
      CHLD)
        if _sgl_is_true "${SGL_QUIET_CHILD}"; then
          shh=1
        fi
        ;;
      PRT)
        if _sgl_is_true "${SGL_QUIET_PARENT}"; then
          shh=1
        fi
        ;;
    esac
  fi

  printf '%s' "${shh}"
}
readonly -f _sgl_get_quiet
