# @dest $LIB/superglue/_sgl_ins_var
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
#
# @use _sgl_source ins_var
# @return
#   0  PASS
##############################################################################

_sgl_source chk_exit esc_val get_tag get_tags has_tag sort_keys

############################################################
# @private
# @func _sgl_ins_var
# @use _sgl_ins_var SRC
# @val SRC  Must be a valid file path.
# @return
#   0  PASS
# @exit-on-error
#   6  CHLD  A child process exited unsuccessfully.
############################################################
_sgl_ins_var()
{
  local -r SRC="${1}"
  local key
  local val
  local -A vars
  local -a keys=()

  # parse version TAG
  if _sgl_has_tag "${SRC}" VERS; then
    key='VERSION'
    val="$(_sgl_get_tag "${SRC}" VERS)"
    keys[${#keys[@]}]="${key}"
    vars["${key}"]="$(_sgl_esc_val "${val}")"
  fi

  # parse each set TAG
  if _sgl_has_tag "${SRC}" SET; then
    while IFS= read -r val; do
      key="${val%%=*}"
      val="${val#*=}"
      keys[${#keys[@]}]="${key}"
      vars["${key}"]="$(_sgl_esc_val "${val}")"
    done <<< "$(_sgl_get_tags "${SRC}" SET)"
  fi

  # return if no keys exist
  if [[ ${#keys[@]} -eq 0 ]]; then
    return 0
  fi

  # build the sed script
  local script='/^[[:blank:]]*[^#].*@[a-zA-Z_]/ {'
  while IFS= read -r key; do
    script="${script}"' s/@'"${key}"'/'"${vars[${key}]}"'/g;'
  done <<< "$(_sgl_sort_keys "${keys[@]}")"
  script="${script}"' }'

  "${sed}" -i -e "${script}" -- "${SRC}"
  _sgl_chk_exit ${?} "${sed}" -i -e "${script}" -- "${SRC}"

  return 0
}
readonly -f _sgl_ins_var
