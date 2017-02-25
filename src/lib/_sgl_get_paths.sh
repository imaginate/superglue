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

_sgl_source is_dir is_path

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
  local -r DIR="${1%/}"
  local path

  if ! _sgl_is_dir "${DIR}"; then
    return 0
  fi

  while IFS= read -r path; do
    path="${DIR}/${path##*/}"
    if _sgl_is_path "${path}"; then
      printf '%s\n' "${path}"
    fi
  done <<< "$(${ls} -b -1 -A -- "${DIR}")"
  return 0
}
readonly -f _sgl_get_paths
