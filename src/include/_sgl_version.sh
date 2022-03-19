# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
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
