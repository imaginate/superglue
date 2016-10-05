#!/bin/bash
#
# @dest /lib/superglue/_sgl_get_color
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source get_color
# @return
#   0  PASS
################################################################################

############################################################
# @func _sgl_get_color
# @use _sgl_get_color COLOR
# @val COLOR  Should be a color from the below options.
#   `black'   Prints $SGL_BLACK.
#   `red'     Prints $SGL_RED.
#   `green'   Prints $SGL_GREEN.
#   `yellow'  Prints $SGL_YELLOW.
#   `blue'    Prints $SGL_BLUE.
#   `purple'  Prints $SGL_PURPLE.
#   `cyan'    Prints $SGL_CYAN.
#   `white'   Prints $SGL_WHITE.
# @return
#   0  PASS  COLOR is valid.
#   1  FAIL  COLOR is invalid.
############################################################
_sgl_get_color()
{
  case "$1" in
    black)
      printf '%s' "${SGL_BLACK}"
      ;;
    red)
      printf '%s' "${SGL_RED}"
      ;;
    green)
      printf '%s' "${SGL_GREEN}"
      ;;
    yellow)
      printf '%s' "${SGL_YELLOW}"
      ;;
    blue)
      printf '%s' "${SGL_BLUE}"
      ;;
    purple)
      printf '%s' "${SGL_PURPLE}"
      ;;
    cyan)
      printf '%s' "${SGL_CYAN}"
      ;;
    white)
      printf '%s' "${SGL_WHITE}"
      ;;
    *)
      return 1
      ;;
  esac
  return 0
}
readonly -f _sgl_get_color
