# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# Prints the boolean for the below globals.
#   `SGL_SILENT'
#   `SGL_SILENT_PARENT'
#   `SGL_SILENT_CHILD'
#
# @func _sgl_get_silent
# @use _sgl_get_silent [PROC]
# @val PROC  Must be one of the below options.
#   `CHLD'  Child process.
#   `PRT'   Parent process.
# @return
#   0  PASS
############################################################
_sgl_get_silent()
{
  local -i shh=0

  if _sgl_is_true "${SGL_SILENT}"; then
    shh=1
  else
    case "${1}" in
      CHLD)
        if _sgl_is_true "${SGL_SILENT_CHILD}"; then
          shh=1
        fi
        ;;
      PRT)
        if _sgl_is_true "${SGL_SILENT_PARENT}"; then
          shh=1
        fi
        ;;
    esac
  fi

  printf '%s' "${shh}"
}
readonly -f _sgl_get_silent
