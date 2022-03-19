# @dest $LIB/superglue/_sgl_get_color
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
#
# @use _sgl_source get_color
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_get_color
# @use _sgl_get_color COLOR
# @val COLOR  Should be a color from the below options.
#   `black'   Prints global `SGL_BLACK'.
#   `blue'    Prints global `SGL_BLUE'.
#   `cyan'    Prints global `SGL_CYAN'.
#   `green'   Prints global `SGL_GREEN'.
#   `none'    Prints no color.
#   `purple'  Prints global `SGL_PURPLE'.
#   `red'     Prints global `SGL_RED'.
#   `white'   Prints global `SGL_WHITE'.
#   `yellow'  Prints global `SGL_YELLOW'.
# @return
#   0  PASS
############################################################
_sgl_get_color()
{
  local color="${1}"

  case "${color}" in
    black|Black|BLACK)
      color="${SGL_BLACK}"
      ;;
    blue|Blue|BLUE)
      color="${SGL_BLUE}"
      ;;
    cyan|Cyan|CYAN)
      color="${SGL_CYAN}"
      ;;
    green|Green|GREEN)
      color="${SGL_GREEN}"
      ;;
    purple|Purple|PURPLE)
      color="${SGL_PURPLE}"
      ;;
    red|Red|RED)
      color="${SGL_RED}"
      ;;
    white|White|WHITE)
      color="${SGL_WHITE}"
      ;;
    yellow|Yellow|YELLOW)
      color="${SGL_YELLOW}"
      ;;
    *)
      return 0
      ;;
  esac

  printf '%s' "${color}"
}
readonly -f _sgl_get_color
