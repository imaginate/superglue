# @dest $LIB/superglue/_sgl_has_def
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
#
# @use _sgl_source has_def
# @return
#   0  PASS
################################################################################

############################################################
# @private
# @func _sgl_has_def
# @use _sgl_has_def KEY
# @val KEY  Should be a key name in the global, `_SGL_DEFS'.
# @return
#   0  PASS  The KEY is valid.
#   1  FAIL  The KEY is invalid.
############################################################
_sgl_has_def()
{
  local KEY="${1}"
  local key

  if [[ -z "${KEY}" ]]; then
    return 1
  fi

  for key in "${!_SGL_DEFS[@]}"; do
    if [[ "${KEY}" == "${key}" ]]; then
      return 0
    fi
  done
  return 1
}
readonly -f _sgl_has_def
