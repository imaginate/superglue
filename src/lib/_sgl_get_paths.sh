# @dest $LIB/superglue/_sgl_get_paths
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source get_paths
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_get_paths
# @use _sgl_get_paths DIR
# @val DIR  Must be a valid directory.
# @return
#   0  PASS
############################################################
_sgl_get_paths()
{
  ${ls} -b -1 -A -- "${1}"
}
readonly -f _sgl_get_paths
