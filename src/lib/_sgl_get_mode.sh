# @dest $LIB/superglue/_sgl_get_mode
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
#
# @use _sgl_source get_mode
# @return
#   0  PASS
################################################################################

_sgl_source is_path

############################################################
# @private
# @func _sgl_get_mode
# @use _sgl_get_mode PATH
# @val PATH  Must be a valid file system path.
# @return
#   0  PASS
############################################################
_sgl_get_mode()
{
  local -r PATH="${1}"
  local -i mod
  local mode
  local val

  if ! _sgl_is_path "${PATH}"; then
    return 0
  fi

  val="$(${ls} -b -d -l -L -- "${PATH}")"
  val="${val%% *}"

  if [[ -z "${val}" ]] || [[ ! "${val}" =~ ^[-d]([-r][-w][-x]){3}$ ]]; then
    return 0
  fi

  mode='0'
  for val in "${val:1:3}" "${val:4:3}" "${val:7:3}"; do
    mod=0
    if [[ "${val:0:1}" == 'r' ]]; then
      mod=$(( mod + 4 ))
    fi
    if [[ "${val:1:1}" == 'w' ]]; then
      mod=$(( mod + 2 ))
    fi
    if [[ "${val:2:1}" == 'x' ]]; then
      mod=$(( mod + 1 ))
    fi
    mode="${mode}${mod}"
  done

  printf '%s' "${mode}"
}
readonly -f _sgl_get_mode
