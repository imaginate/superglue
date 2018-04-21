# @dest $LIB/superglue/_sgl_is_attr
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
#
# @use _sgl_source is_attr
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_is_attr
# @use _sgl_is_attr ATTR
# @val ATTR  Should be a file attribute from below options.
#   `mode'
#   `ownership'
#   `timestamps'
#   `context'
#   `links'
#   `xattr'
#   `all'
# @return
#   0  PASS  The ATTR is valid.
#   1  FAIL  The ATTR is invalid.
############################################################
_sgl_is_attr()
{
  case "${1}" in
    mode)       ;;
    ownership)  ;;
    timestamps) ;;
    context)    ;;
    links)      ;;
    xattr)      ;;
    all)        ;;
    *)
      return 1
      ;;
  esac
  return 0
}
readonly -f _sgl_is_attr
