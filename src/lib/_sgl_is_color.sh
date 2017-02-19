# @dest $LIB/superglue/_sgl_is_color
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source is_color
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_is_color
# @use _sgl_is_color COLOR
# @val COLOR  Should be a color from the below options.
#   `black'
#   `blue'
#   `cyan'
#   `green'
#   `none'
#   `purple'
#   `red'
#   `white'
#   `yellow'
# @return
#   0  PASS  COLOR is valid.
#   1  FAIL  COLOR is invalid.
############################################################
_sgl_is_color()
{
  case "${1}" in
    black|Black|BLACK)    ;;
    blue|Blue|BLUE)       ;;
    cyan|Cyan|CYAN)       ;;
    green|Green|GREEN)    ;;
    none|None|NONE)       ;;
    purple|Purple|PURPLE) ;;
    red|Red|RED)          ;;
    white|White|WHITE)    ;;
    yellow|Yellow|YELLOW) ;;
    *)
      return 1
      ;;
  esac
  return 0
}
readonly -f _sgl_is_color
