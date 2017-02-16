#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_get_color
# @use _sgl_get_color COLOR
# @val COLOR  Should be a color from the below options.
#   `black'   Prints $SGL_BLACK.
#   `blue'    Prints $SGL_BLUE.
#   `cyan'    Prints $SGL_CYAN.
#   `green'   Prints $SGL_GREEN.
#   `none'    Prints no color.
#   `purple'  Prints $SGL_PURPLE.
#   `red'     Prints $SGL_RED.
#   `white'   Prints $SGL_WHITE.
#   `yellow'  Prints $SGL_YELLOW.
# @return
#   0  PASS  COLOR is valid.
#   1  FAIL  COLOR is invalid.
############################################################
_sgl_get_color()
{
  case "${1}" in
    black|Black|BLACK)
      printf '%s' "${SGL_BLACK}"
      ;;
    blue|Blue|BLUE)
      printf '%s' "${SGL_BLUE}"
      ;;
    cyan|Cyan|CYAN)
      printf '%s' "${SGL_CYAN}"
      ;;
    green|Green|GREEN)
      printf '%s' "${SGL_GREEN}"
      ;;
    none|None|NONE)
      ;;
    purple|Purple|PURPLE)
      printf '%s' "${SGL_PURPLE}"
      ;;
    red|Red|RED)
      printf '%s' "${SGL_RED}"
      ;;
    white|White|WHITE)
      printf '%s' "${SGL_WHITE}"
      ;;
    yellow|Yellow|YELLOW)
      printf '%s' "${SGL_YELLOW}"
      ;;
    *)
      return 1
      ;;
  esac
  return 0
}
readonly -f _sgl_get_color
