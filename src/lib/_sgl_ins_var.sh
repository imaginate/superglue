# @dest $LIB/superglue/_sgl_ins_var
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source ins_var
# @return
#   0  PASS
################################################################################

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

  # build the sed options
  local opts=()
  while IFS= read -r key; do
    val="${vars[${key}]}"
    key="^\([[:blank:]]*\)\([^#@].*\)\?@${key}"
    opts[${#opts[@]}]='-e'
    opts[${#opts[@]}]="s/${key}/\1\2${val}/g"
  done <<< "$(_sgl_sort_keys "${keys[@]}")"

  ${sed} -i "${opts[@]}" -- "${SRC}"
  _sgl_chk_exit ${?} ${sed} -i "${opts[@]}" -- "${SRC}"

  return 0
}
readonly -f _sgl_ins_var
