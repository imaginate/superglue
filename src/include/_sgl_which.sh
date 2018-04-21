# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
################################################################################

############################################################
# @private
# @func _sgl_which
# @use _sgl_which CMD
# @val CMD  Must be an executable.
# @return
#   0  PASS
############################################################
_sgl_which()
{
  local cmd="${1}"

  if _sgl_is_cmd "/bin/${1}"; then
    cmd="/bin/${1}"
  elif _sgl_is_cmd "/usr/bin/${1}"; then
    cmd="/usr/bin/${1}"
  elif _sgl_is_cmd "/usr/local/bin/${1}"; then
    cmd="/usr/local/bin/${1}"
  fi
  printf '%s' "${cmd}"
}
readonly -f _sgl_which
