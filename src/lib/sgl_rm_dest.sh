#!/bin/bash
#
# @dest $LIB/superglue/sgl_rm_dest
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl_source rm_dest
# @return
#   0  PASS
################################################################################

############################################################
# @public
# @func sgl_rm_dest
# @use sgl_rm_dest [...OPTION] ...SRC
# @opt -D|--defines=VARS     Define multiple VAR for any TAG VALUE to use.
# @opt -d|--define=VAR       Define one VAR for any TAG VALUE to use.
# @opt -E|--no-empty         Force SRC to contain at least one destination tag.
# @opt -e|--empty            Allow SRC to not contain a destination tag.
# @opt -F|--no-force         If destination exists do not overwrite it.
# @opt -f|--force            If a destination exists overwrite it.
# @opt -h|-?|--help          Print help info and exit.
# @opt -Q|--silent           Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet            Disable `stdout' output.
# @opt -r|--recursive        If SRC is a directory recursively process directories.
# @opt -t|--test=REGEX       Test each DEST path against REGEX (uses bash `=~').
# @opt -V|--verbose          Print exec status details.
# @opt -v|--version          Print version info and exit.
# @opt -x|--one-file-system  Stay on this file system.
# @opt -|--                  End the options.
# @val DEST   Must be a valid path. Can include defined VAR KEYs identified by a
#             leading `$' and optionally wrapped with curly brackets, `${KEY}'.
# @val REGEX  Can be any string. Refer to bash test `=~' operator for more details.
# @val SRC    Must be a valid file or directory path. If SRC is a directory each
#             child file path is processed as a SRC. Each SRC file must contain at
#             least one `dest' TAG (unless `--empty' is used), can contain one
#             `mode', `owner', and `version' TAG, and can contain multiple `include'
#             or `var' TAG. Note that OPTION values take priority over TAG values.
# @val TAG    A TAG is defined within a SRC file's contents. It must be a one-line
#             comment formatted as `# @TAG VALUE'. Spacing is optional except
#             between TAG and VALUE. The TAG must be one of the options below.
#   `dest'     Formatted `# @dest DEST'.
#   `include'  Formatted `# @include FILE'.
#   `mode'     Formatted `# @mode MODE'.
#   `owner'    Formatted `# @owner OWNER'.
#   `var'      Formatted `# @var KEY=VALUE'.
#   `version'  Formatted `# @version VERSION'.
# @val VAR    Must be a valid `KEY=VALUE' pair. The KEY must start with a character
#             matching `[a-zA-Z_]', can only contain `[a-zA-Z0-9_]', and must end
#             with `[a-zA-Z0-9]'. The VALUE must not contain a `,'.
# @val VARS   Must be a list of one or more VAR separated by `,'.
# @return
#   0  PASS
# @exit-on-error
############################################################
sgl_rm_dest()
{
  local -r FN='sgl_rm_dest'

  # tag patterns
  local -r dtag='^[[:blank:]]*#[[:blank:]]*@dest[[:blank:]]\+'

  # option flags
  local -i silent=${SGL_SILENT}
  local -i quiet=${SGL_QUIET}
  local -i deep=0
  local -i empty=0
  local -i force=0
  local regex='/[^/]+/[^/]+$'

  # parsed values
  local -a rm_opts
  local -A tag_vars

  __sgl_rm_dest__args "$@"
  __sgl_rm_dest__opts "${_SGL_OPTS[@]}"
  __sgl_rm_dest__vals "${_SGL_VALS[@]}"
}
readonly -f sgl_rm_dest

################################################################################
## DEFINE HELPER FUNCTIONS
################################################################################

############################################################
# @private
# @func __sgl_rm_dest__add_rm_opt
# @use __sgl_rm_dest__add_rm_opt OPTION[=VALUE]
# @return
#   0  PASS
############################################################
__sgl_rm_dest__add_rm_opt()
{
  rm_opts[${#rm_opts[@]}]="$1"
}
readonly -f __sgl_rm_dest__add_rm_opt

############################################################
# @private
# @func __sgl_rm_dest__chk_key
# @use __sgl_rm_dest__chk_key KEY
# @return
#   0  PASS
#   1  FAIL
############################################################
__sgl_rm_dest__chk_key()
{
  if [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] && [[ "$1" =~ [a-zA-Z0-9]$ ]]; then
    return 0
  fi
  return 1
}
readonly -f __sgl_rm_dest__chk_key

############################################################
# @private
# @func __sgl_rm_dest__has_key
# @use __sgl_rm_dest__has_key KEY
# @return
#   0  PASS
#   1  FAIL
############################################################
__sgl_rm_dest__has_key()
{
  local _key

  for _key in "${!tag_vars[@]}"; do
    [[ "$1" == "${_key}" ]] && return 0
  done
  return 1
}
readonly -f __sgl_rm_dest__has_key

############################################################
# @private
# @func __sgl_rm_dest__set_key
# @use __sgl_rm_dest__set_key LINE
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_rm_dest__set_key()
{
  local _line="${1}"

  key="${val#*$}"

  if [[ -z "${key}" ]]; then
    _sgl_err VAL "invalid \`${FN}' KEY at LINE \`${_line}' in SRC \`${src}'"
  fi

  if [[ "${key}" =~ ^\{ ]]; then
    if [[ ! "${key}" =~ \} ]]; then
      key="\`${FN}' KEY \`\$${key%%\$*}'"
      _sgl_err VAL "invalid ${key} at LINE \`${_line}' in SRC \`${src}'"
    fi
    key="${key#\{}"
    key="${key%%\}*}"
    if ! __sgl_rm_dest__chk_key "${key}"; then
      key="\`${FN}' KEY \`\${${key}}'"
      _sgl_err VAL "invalid ${key} at LINE \`${_line}' in SRC \`${src}'"
    fi
    if ! __sgl_rm_dest__has_key "${key}"; then
      key="\`${FN}' KEY \`\${${key}}'"
      _sgl_err VAL "undefined ${key} at LINE \`${_line}' in SRC \`${src}'"
    fi
  else
    key="$(printf '%s' "${key}" | ${sed} -e 's/[^a-zA-Z0-9_].*$//')"
    if ! __sgl_rm_dest__chk_key "${key}"; then
      key="\`${FN}' KEY \`\$${key}'"
      _sgl_err VAL "invalid ${key} at LINE \`${_line}' in SRC \`${src}'"
    fi
    if ! __sgl_rm_dest__has_key "${key}"; then
      key="\`${FN}' KEY \`\$${key}'"
      _sgl_err VAL "undefined ${key} at LINE \`${_line}' in SRC \`${src}'"
    fi
  fi
}
readonly -f __sgl_rm_dest__set_key

############################################################
# @private
# @func __sgl_rm_dest__set_val
# @use __sgl_rm_dest__set_val LINE
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_rm_dest__set_val()
{
  local _line="${1}"
  local _val
  local key

  val="$(__sgl_rm_dest__trim_tag "${_line}")"

  while [[ "${val}" =~ \$ ]]; do
    __sgl_rm_dest__set_key "${_line}"
    _val="${tag_vars[${key}]}"
    [[ "${val#*$}" =~ ^\{ ]] && key="{${key}}"
    key="\$${key}"
    val="$(printf '%s' "${val}" | ${sed} -e "s/${key}/${_val}/")"
  done
}
readonly -f __sgl_rm_dest__set_val

############################################################
# @private
# @func __sgl_rm_dest__trim_tag
# @use __sgl_rm_dest__trim_tag LINE
# @return
#   0  PASS
############################################################
__sgl_rm_dest__trim_tag()
{
  printf '%s' "${1}" | ${sed} \
    -e 's/^[[:blank:]]*#[[:blank:]]*@[[:lower:]]\+[[:blank:]]\+//' \
    -e 's/[[:blank:]]\+$//'
}
readonly -f __sgl_rm_dest__trim_tag

################################################################################
## DEFINE ARGUMENT FUNCTIONS
################################################################################

############################################################
# @private
# @func __sgl_rm_dest__args
# @use __sgl_rm_dest__args ...ARG
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_rm_dest__args()
{
  _sgl_parse_args "${FN}" \
    '-D|--defines'      1 \
    '-d|--define'       1 \
    '-E|--no-empty'     0 \
    '-e|--empty'        0 \
    '-F|--no-force'     0 \
    '-f|--force'        0 \
    '-h|-?|--help'      0 \
    '-Q|--silent'       0 \
    '-q|--quiet'        0 \
    '-r|--recursive'    0 \
    '-t|--test'         1 \
    '-V|--verbose'      0 \
    '-v|--version'      0 \
    '-x|--one-file-system' 0 \
    -- "${@}"
}
readonly -f __sgl_rm_dest__args

################################################################################
## DEFINE OPTION FUNCTIONS
################################################################################

############################################################
# @private
# @func __sgl_rm_dest__opts
# @use __sgl_rm_dest__opts ...OPT
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_rm_dest__opts()
{
  local -i _index=0
  local -i _bool
  local _opt
  local _val

  tag_vars=( \
    ['HOME']="$(_sgl_escape_val "${HOME}")" \
    ['EUID']="$(_sgl_escape_val "${EUID}")" \
    ['UID']="$(_sgl_escape_val "${UID}")"   \
    ['USER']="$(_sgl_escape_val "${USER}")" \
  )

  [[ ${SGL_QUIET_PARENT}  -eq 1 ]] && quiet=1
  [[ ${SGL_SILENT_PARENT} -eq 1 ]] && silent=1

  # parse each OPTION
  for _opt in "${@}"; do
    _bool=${_SGL_OPT_BOOL[${_index}]}
    _val="${_SGL_OPT_VALS[${_index}]}"
    __sgl_rm_dest__opt "${_opt}" ${_bool} "${_val}"
    _index=$(( ++_index ))
  done

  # set empty regex to pass
  [[ -z "${regex}" ]] && regex='.*'
}
readonly -f __sgl_rm_dest__opts

############################################################
# @private
# @func __sgl_rm_dest__opt
# @use __sgl_rm_dest__opt OPT BOOL VAL
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_rm_dest__opt()
{
  case "${1}" in
    -D|--defines)
      __sgl_rm_dest__opt_D "${@}"
      ;;
    -d|--define)
      __sgl_rm_dest__opt_d "${@}"
      ;;
    -E|--no-empty)
      empty=0
      ;;
    -e|--empty)
      empty=1
      ;;
    -F|--no-force)
      force=0
      __sgl_rm_dest__add_rm_opt '-i'
      ;;
    -f|--force)
      force=1
      __sgl_rm_dest__add_rm_opt '-f'
      ;;
    -h|-\?|--help)
      _sgl_help sgl_rm_dest
      ;;
    -Q|--silent)
      silent=1
      ;;
    -q|--quiet)
      quiet=1
      ;;
    -r|--recursive)
      deep=1
      ;;
    -t|--test)
      regex="${3}"
      ;;
    -V|--verbose)
      __sgl_rm_dest__add_rm_opt '--verbose'
      ;;
    -v|--version)
      _sgl_version
      ;;
    -x|--one-file-system)
      __sgl_rm_dest__add_rm_opt '--one-file-system'
      ;;
    *)
      _sgl_err SGL "invalid parsed \`${FN}' OPTION \`${1}'"
      ;;
  esac
}
readonly -f __sgl_rm_dest__opt

############################################################
# @private
# @func __sgl_rm_dest__opt_D
# @use __sgl_rm_dest__opt_D OPT BOOL VAL
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_rm_dest__opt_D()
{
  local _var
  local _key
  local _val

  [[ -n "${3}" ]] || _sgl_err VAL "missing \`${FN}' \`${1}' VARS"

  while IFS= read -r -d ',' _var; do
    if [[ ! "${_var}" =~ = ]]; then
      _sgl_err VAL "missing \`${FN}' \`${1}' VAR \`${_var}' VALUE"
    fi
    _key="${_var%%=*}"
    _val="${_var#*=}"
    if ! __sgl_rm_dest__chk_key "${_key}"; then
      _sgl_err VAL "invalid \`${FN}' \`${1}' VAR \`${_var}' KEY \`${_key}'"
    fi
    tag_vars["${_key}"]="$(_sgl_escape_val "${_val}")"
  done <<< "${3},"
}
readonly -f __sgl_rm_dest__opt_D

############################################################
# @private
# @func __sgl_rm_dest__opt_d
# @use __sgl_rm_dest__opt_d OPT BOOL VAL
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_rm_dest__opt_d()
{
  local _key
  local _val

  [[ -n "${3}" ]] || _sgl_err VAL "missing \`${FN}' \`${1}' VAR"

  [[ "${3}" =~ = ]] || _sgl_err VAL "missing \`${FN}' \`${1}' VAR \`${3}' VALUE"

  _key="${3%%=*}"
  _val="${3#*=}"

  if ! __sgl_rm_dest__chk_key "${_key}"; then
    _sgl_err VAL "invalid \`${FN}' \`${1}' VAR \`${3}' KEY \`${_key}'"
  fi

  tag_vars["${_key}"]="$(_sgl_escape_val "${_val}")"
}
readonly -f __sgl_rm_dest__opt_d

################################################################################
## DEFINE VALUE FUNCTIONS
################################################################################

############################################################
# @private
# @func __sgl_rm_dest__vals
# @use __sgl_rm_dest__vals ...SRC
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_rm_dest__vals()
{
  local _src

  [[ $# -eq 0 ]] && _sgl_err VAL "missing \`${FN}' SRC"

  for _src in "${@}"; do
    if [[ -d "${_src}" ]]; then
      if [[ ${deep} -eq 1 ]]; then
        __sgl_rm_dest__dirs "${_src}"
      else
        __sgl_rm_dest__dir "${_src}"
      fi
    else
      __sgl_rm_dest__val "${_src}"
    fi
  done
}
readonly -f __sgl_rm_dest__vals

############################################################
# @private
# @func __sgl_rm_dest__dir
# @use __sgl_rm_dest__dir SRCDIR
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_rm_dest__dir()
{
  local _src

  for _src in "${1}"/*; do
    [[ -f "${_src}" ]] && __sgl_rm_dest__val "${_src}"
  done
}
readonly -f __sgl_rm_dest__dir

############################################################
# @private
# @func __sgl_rm_dest__dirs
# @use __sgl_rm_dest__dirs SRCDIR
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_rm_dest__dirs()
{
  local _src

  for _src in "${1}"/*; do
    if [[ -d "${_src}" ]]; then
      __sgl_rm_dest__dirs "${_src}"
    elif [[ -f "${_src}" ]]; then
      __sgl_rm_dest__val "${_src}"
    fi
  done
}
readonly -f __sgl_rm_dest__dirs

############################################################
# @private
# @func __sgl_rm_dest__val
# @use __sgl_rm_dest__val SRC
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_rm_dest__val()
{
  local src="${1}"
  local dst
  local val
  local _line

  [[ -f "${src}" ]] || _sgl_err VAL "invalid path for \`${FN}' SRC \`${src}'"

  # handle no dest tags in SRC
  if ! ${grep} "${dtag}" "${src}" > ${NIL} 2>&1; then
    [[ ${empty} -eq 1 ]] && return 0
    _sgl_err VAL "missing dest tag in \`${FN}' SRC \`${src}'"
  fi

  # parse each DEST
  while IFS= read -r _line; do
    __sgl_rm_dest__dst "${_line}"
    __sgl_rm_dest__rm
  done <<< "$(${grep} "${dtag}" "${src}" 2> ${NIL})"
}
readonly -f __sgl_rm_dest__val

############################################################
# @private
# @func __sgl_rm_dest__dst
# @use __sgl_rm_dest__dst LINE
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_rm_dest__dst()
{
  local _key
  local _val

  __sgl_rm_dest__set_val "${1}"

  dst="${val}"
  [[ "${dst}" =~ ^/ ]] || dst="${src%/*}/${dst}"

  if [[ ! "${dst}" =~ ${regex} ]]; then
    dst="\`${FN}' DEST \`${dst}'"
    _sgl_err VAL "invalid ${dst} at LINE \`${1}' in SRC \`${src}'"
  fi

  if [[ ! -f "${dst}" ]]; then
    if [[ -d "${dst}" ]]; then
      dst="\`${FN}' DEST \`${dst}' at LINE \`${1}'"
      _sgl_err VAL "a dir already exists for ${dst} in SRC \`${src}'"
    fi
    if [[ -a "${dst}" ]]; then
      dst="\`${FN}' DEST \`${dst}' at LINE \`${1}'"
      _sgl_err VAL "a non-file already exists for ${dst} in SRC \`${src}'"
    fi
  fi
}
readonly -f __sgl_rm_dest__dst

############################################################
# @private
# @func __sgl_rm_dest__rm
# @use __sgl_rm_dest__rm
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_rm_dest__rm()
{
  ${rm} "${rm_opts[@]}" "${dst}" \
    || _sgl_err CHLD "\`${rm}' in \`${FN}' exited with \`$?'"
}
readonly -f __sgl_rm_dest__rm
