# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
################################################################################

############################################################
# @private
# @func _sgl_version
# @use _sgl_version
# @exit
#   0  PASS
############################################################
_sgl_version()
{
  printf '%s\n' "superglue v${SGL_VERSION}"
  exit 0
}
readonly -f _sgl_version
