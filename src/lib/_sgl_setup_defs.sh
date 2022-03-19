# @dest $LIB/superglue/_sgl_setup_defs
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
#
# @use _sgl_source setup_defs
# @return
#   0  PASS
################################################################################

_sgl_source esc_val

############################################################
# Initializes the global associative array, `_SGL_DEFS',
# with default values from the bash environment.
#
# @private
# @func _sgl_setup_defs
# @use _sgl_setup_defs
# @return
#   0  PASS
############################################################
_sgl_setup_defs()
{
  _SGL_DEFS=( \
    ['HOME']="$(_sgl_esc_val "${HOME}")" \
    ['EUID']="$(_sgl_esc_val "${EUID}")" \
    ['PWD']="$(_sgl_esc_val "${PWD}")"   \
    ['UID']="$(_sgl_esc_val "${UID}")"   \
    ['USER']="$(_sgl_esc_val "${USER}")" )
  return 0
}
readonly -f _sgl_setup_defs
