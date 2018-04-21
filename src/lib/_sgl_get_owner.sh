# @dest $LIB/superglue/_sgl_get_owner
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
#
# @use _sgl_source get_owner
# @return
#   0  PASS
################################################################################

_sgl_source is_group is_path is_user

############################################################
# @private
# @func _sgl_get_owner
# @use _sgl_get_owner PATH
# @val PATH  Must be a valid file system path.
# @return
#   0  PASS
############################################################
_sgl_get_owner()
{
  local -r PATH="${1}"
  local user
  local group

  if ! _sgl_is_path "${PATH}"; then
    return 0
  fi

  val="$(${ls} -b -d -l -L -- "${PATH}")"
  val="${val#* }"
  val="${val#* }"
  user="${val%% *}"
  val="${val#* }"
  group="${val%% *}"

  if ! _sgl_is_user "${user}" || ! _sgl_is_group "${group}"; then
    return 0
  fi

  printf '%s' "${user}:${group}"
}
readonly -f _sgl_get_owner
