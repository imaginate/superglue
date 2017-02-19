# @dest $LIB/superglue/_sgl_setup_defs
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
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
  declare -A _SGL_DEFS=( \
    ['HOME']="$(_sgl_esc_val "${HOME}")" \
    ['EUID']="$(_sgl_esc_val "${EUID}")" \
    ['PWD']="$(_sgl_esc_val "${PWD}")"   \
    ['UID']="$(_sgl_esc_val "${UID}")"   \
    ['USER']="$(_sgl_esc_val "${USER}")" )
  return 0
}
readonly -f _sgl_setup_defs
