#!/bin/bash --posix
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

############################################################
# @func _sgl_err
# @use _sgl_err ERR [MSG]
# @val MSG  Can be any string.
# @val ERR  Must be an error from the below options or any valid integer in the
#           range of `1' to `126'.
#   `MISC'  An unknown error.
#   `OPT'   An invalid option.
#   `VAL'   An invalid or missing value.
#   `AUTH'  A permissions error.
#   `DPND'  A dependency error.
#   `CHLD'  A child process exited unsuccessfully.
#   `SGL'   A `superglue' script error.
# @exit
#   1  MISC
#   2  OPT
#   3  VAL
#   4  AUTH
#   5  DPND
#   6  CHLD
#   7  INTL
############################################################
_sgl_err()
{
  [[ $# -gt 1 ]] && _sgl_fail "$@"
  case "$1" in
    MISC)
      exit 1
      ;;
    OPT)
      exit 2
      ;;
    VAL)
      exit 3
      ;;
    AUTH)
      exit 4
      ;;
    DPND)
      exit 5
      ;;
    CHLD)
      exit 6
      ;;
    SGL)
      exit 7
      ;;
  esac
  exit $1
}
readonly -f _sgl_err
