# @dest $LIB/superglue/_sgl_ins_incl
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
#
# @use _sgl_source ins_incl
# @return
#   0  PASS
##############################################################################

_sgl_source chk_exit err esc_cont esc_key get_keys get_paths get_tmp has_tag \
  ins_var is_dir is_file is_read match_patt trim_tag

############################################################
# @private
# @func _sgl_ins_incl
# @use _sgl_ins_incl PRG INS DIR SRC
# @val DIR  Must be the SRC parent directory path (enables tmp SRC paths).
# @val INS  Must be the boolean value for `--insert'.
# @val PRG  Must be the name of the calling command or function.
# @val SRC  Must be a valid file path.
# @return
#   0  PASS
# @exit-on-error
#   1  ERR   An unknown error.
#   2  OPT   An invalid option.
#   3  VAL   An invalid or missing value.
#   4  AUTH  A permissions error.
#   5  DPND  A dependency error.
#   6  CHLD  A child process exited unsuccessfully.
#   7  SGL   A `superglue' script error.
############################################################
_sgl_ins_incl()
{
  local -r PRG="${1}"
  local -r INS="${2}"
  local -r DIR="${3}"
  local -r SRC="${4}"
  local -r PATT='^[[:blank:]]*#[[:blank:]]*@incl\(ude\)\?[[:blank:]]\+'
  local dir
  local key
  local val
  local line
  local name
  local path
  local -a paths

  if ! _sgl_has_tag "${SRC}" INCL; then
    return 0
  fi

  while IFS= read -r line; do
    path="$(_sgl_trim_tag "${line}")"

    if [[ "${path:0:1}" == "'" ]]; then
      path="${path:1}"
      path="${path%\'}"
    else

      if [[ "${path:0:1}" == '"' ]]; then
        path="${path:1}"
        path="${path%\"}"
      fi

      while IFS= read -r key; do
        if [[ -z "${key}" ]]; then
          continue
        fi

        name="${key:1}"
        if [[ "${key:1:1}" == '{' ]]; then
          name="${name:1}"
          name="${name%\}}"
        fi

        key="$(_sgl_esc_key "${key}")"
        val="${_SGL_DEFS[${name}]}"
        if [[ "${path:0:1}" == '$' ]]; then
          key="^${key}"
        else
          key="\([^\\]\)${key}"
          val="\1${val}"
        fi
        path="$(printf '%s' "${path}" | ${sed} -e "s/${key}/${val}/")"
      done <<< "$(_sgl_get_keys "${path}")"
    fi

    if [[ -z "${path}" ]]; then
      path="FILE path at LINE \`${line}'"
      _sgl_err VAL "missing \`${PRG}' ${path} in SRC \`${SRC}'"
    fi

    if [[ "${path:0:1}" != '/' ]]; then
      path="${DIR}/${path}"
    fi

    if [[ "${path##*/}" =~ \* ]]; then
      if ! _sgl_is_dir "${path%/*}"; then
        path="parent directory for FILE path \`${path}' at LINE \`${line}'"
        _sgl_err VAL "invalid \`${PRG}' ${path} in SRC \`${SRC}'"
      fi

      key="$(_sgl_esc_key "${path##*/}" | ${sed} -e 's/\\\*/[^\/]*/g')"
      key="^\(.*/\)\?${key}\$"
      paths=()
      while IFS= read -r path; do
        if _sgl_is_file "${path}" && _sgl_match_patt "${key}" "${path}"; then
          paths[${#paths[@]}]="${path}"
          if ! _sgl_is_read "${path}"; then
            path="FILE path \`${path}' at LINE \`${line}'"
            _sgl_err VAL "unreadable \`${PRG}' ${path} in SRC \`${SRC}'"
          fi
        fi
      done <<< "$(_sgl_get_paths "${path%/*}")"

      key="$(_sgl_esc_key "${line}")"

      if [[ ${#paths[@]} -gt 0 ]]; then
        for path in "${paths[@]}"; do
          # make new DIR path
          dir="${path%/*}"

          # copy SRC to temporary file path
          val="${path}"
          path="$(_sgl_get_tmp incl)"
          ${cp} -T -- "${val}" "${path}"
          _sgl_chk_exit ${?} ${cp} -T -- "${val}" "${path}"

          if [[ ${INS} -eq 1 ]]; then
            _sgl_ins_var "${path}"
          fi

          _sgl_ins_incl "${PRG}" ${INS} "${dir}" "${path}"

          val="$(_sgl_esc_cont "${path}")\\n&"
          ${sed} -i -e "s/${key}/${val}/" -- "${SRC}"
          _sgl_chk_exit ${?} ${sed} -i -e "s/${key}/${val}/" -- "${SRC}"
        done
      fi

      ${sed} -i -e "/${key}/ d" -- "${SRC}"
      _sgl_chk_exit ${?} ${sed} -i -e "/${key}/ d" -- "${SRC}"
    else
      if ! _sgl_is_read "${path}"; then
        if ! _sgl_is_file "${path}"; then
          path="FILE path \`${path}' at LINE \`${line}'"
          _sgl_err VAL "invalid \`${PRG}' ${path} in SRC \`${SRC}'"
        fi
        path="FILE path \`${path}' at LINE \`${line}'"
        _sgl_err VAL "unreadable \`${PRG}' ${path} in SRC \`${SRC}'"
      fi

      # make new DIR path
      dir="${path%/*}"

      # copy SRC to temporary file path
      val="${path}"
      path="$(_sgl_get_tmp incl)"
      ${cp} -T -- "${val}" "${path}"
      _sgl_chk_exit ${?} ${cp} -T -- "${val}" "${path}"

      if [[ ${INS} -eq 1 ]]; then
        _sgl_ins_var "${path}"
      fi

      _sgl_ins_incl "${PRG}" ${INS} "${dir}" "${path}"

      key="$(_sgl_esc_key "${line}")"
      val="$(_sgl_esc_cont "${path}")"
      ${sed} -i -e "s/${key}/${val}/" -- "${SRC}"
      _sgl_chk_exit ${?} ${sed} -i -e "s/${key}/${val}/" -- "${SRC}"
    fi
  done <<< "$(${grep} -e "${PATT}" -- "${SRC}")"

  return 0
}
readonly -f _sgl_ins_incl
