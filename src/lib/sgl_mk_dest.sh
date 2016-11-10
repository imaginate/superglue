#!/bin/bash
#
# @dest $LIB/superglue/sgl_mk_dest
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl_source mk_dest
# @return
#   0  PASS
################################################################################

############################################################
# @public
# @func sgl_mk_dest
# @use sgl_mk_dest [...OPTION] ...SRC
# @opt -B|--backup-ext=EXT   Override the usual backup file extension.
# @opt -b|--backup[=CTRL]    Make a backup of each existing destination file.
# @opt -D|--defines=VARS     Define multiple VAR for any TAG VALUE to use.
# @opt -d|--define=VAR       Define one VAR for any TAG VALUE to use.
# @opt -E|--no-empty         Force SRC to contain at least one destination tag.
# @opt -e|--empty            Allow SRC to not contain a destination tag.
# @opt -F|--no-force         If destination exists do not overwrite it.
# @opt -f|--force            If a destination exists overwrite it.
# @opt -H|--cmd-dereference  Follow command-line SRC symlinks.
# @opt -h|-?|--help          Print help info and exit.
# @opt -I|--no-include       Disable `include' TAG processing and inserts.
# @opt -K|--no-keep=ATTRS    Do not preserve the ATTRS.
# @opt -k|--keep[=ATTRS]     Keep the ATTRS (default= `mode,ownership,timestamps').
# @opt -L|--dereference      Always follow SRC symlinks.
# @opt -l|--link             Hard link files instead of copying.
# @opt -m|--mode=MODE        Set the file mode for each destination.
# @opt -N|--no-insert        Disable `var' TAG processing and inserts.
# @opt -n|--no-clobber       If destination exists do not overwrite.
# @opt -o|--owner=OWNER      Set the file owner for each destination.
# @opt -P|--no-dereference   Never follow SRC symlinks.
# @opt -Q|--silent           Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet            Disable `stdout' output.
# @opt -r|--recursive        If SRC is a directory recursively process directories.
# @opt -s|--symlink          Make symlinks instead of copying.
# @opt -t|--test=REGEX       Test each DEST path against REGEX (uses bash `=~').
# @opt -u|--update           Copy only when SRC is newer than DEST.
# @opt -V|--verbose          Print exec status details.
# @opt -v|--version          Print version info and exit.
# @opt -w|--warn             If destination exists prompt before overwrite.
# @opt -x|--one-file-system  Stay on this file system.
# @opt -|--                  End the options.
# @val ATTR   Must be a file attribute from below options.
#   `mode'
#   `ownership'
#   `timestamps'
#   `context'
#   `links'
#   `xattr'
#   `all'
# @val ATTRS  Must be a list of one or more ATTR separated by `,'.
# @val CTRL   Must be a backup control method from below options.
#   `none|off'      Never make backups (even if `--backup' is given).
#   `numbered|t'    Make numbered backups.
#   `existing|nil'  If numbered backups exist make numbered. Otherwise make simple.
#   `simple|never'  Always make simple backups.
# @val DEST   Must be a valid path. Can include defined VAR KEYs identified by a
#             leading `$' and optionally wrapped with curly brackets, `${KEY}'.
# @val EXT    Must be a valid file extension to append to the end of a backup file.
#             The default is `~'. Spaces are not allowed.
# @val MODE   Must be a valid file mode.
# @val OWNER  Must be a valid USER[:GROUP].
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
#             matching `[a-zA-Z_]', only contain characters `[a-zA-Z0-9_]', and end
#             with a character matching `[a-zA-Z0-9]'.
# @val VARS   Must be a list of one or more VAR separated by `,'.
# @return
#   0  PASS
# @exit-on-error
############################################################
sgl_mk_dest()
{
  local -r FN='sgl_mk_dest'

  # tag patterns
  local -r dtag='^[[:blank:]]*#[[:blank:]]*@dest[[:blank:]]\+'
  local -r itag='^[[:blank:]]*#[[:blank:]]*@include[[:blank:]]\+'
  local -r mtag='^[[:blank:]]*#[[:blank:]]*@mode[[:blank:]]\+'
  local -r otag='^[[:blank:]]*#[[:blank:]]*@owner[[:blank:]]\+'
  local -r vtag='^[[:blank:]]*#[[:blank:]]*@var[[:blank:]]\+'
  local -r vertag='^[[:blank:]]*#[[:blank:]]*@version[[:blank:]]\+'

  # option flags
  local -i silent=${SGL_SILENT}
  local -i quiet=${SGL_QUIET}
  local -i deep=0
  local -i empty=0
  local -i force=0
  local -i insert=1
  local -i include=1
  local mode=''
  local owner=''
  local regex='/[^/]+/[^/]+$'

  # parsed values
  local -a cp_opts
  local -A tag_vars

  __sgl_mk_dest__args "$@"
  __sgl_mk_dest__opts "${_SGL_OPTS[@]}"
  __sgl_mk_dest__vals "${_SGL_VALS[@]}"
}
readonly -f sgl_mk_dest

################################################################################
## DEFINE HELPER FUNCTIONS
################################################################################

############################################################
# @private
# @func __sgl_mk_dest__add_cp_opt
# @use __sgl_mk_dest__add_cp_opt OPTION[=VALUE]
# @return
#   0  PASS
############################################################
__sgl_mk_dest__add_cp_opt()
{
  cp_opts[${#cp_opts[@]}]="$1"
}
readonly -f __sgl_mk_dest__add_cp_opt

############################################################
# @private
# @func __sgl_mk_dest__chk_mode
# @use __sgl_mk_dest__chk_mode MODE
# @return
#   0  PASS
#   1  FAIL
############################################################
__sgl_mk_dest__chk_mode()
{
  [[ "$1" =~ ^[ugoa]*([-+=]([rwxXst]+|[ugo]))+$ ]] && return 0
  [[ "$1" =~ ^[-+=]?[0-7]{1,4}$ ]] && return 0
  return 1
}
readonly -f __sgl_mk_dest__chk_mode

############################################################
# @private
# @func __sgl_mk_dest__chk_key
# @use __sgl_mk_dest__chk_key KEY
# @return
#   0  PASS
#   1  FAIL
############################################################
__sgl_mk_dest__chk_key()
{
  if [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] && [[ "$1" =~ [a-zA-Z0-9]$ ]]; then
    return 0
  fi
  return 1
}
readonly -f __sgl_mk_dest__chk_key

############################################################
# @private
# @func __sgl_mk_dest__has_key
# @use __sgl_mk_dest__has_key KEY
# @return
#   0  PASS
#   1  FAIL
############################################################
__sgl_mk_dest__has_key()
{
  local _key

  for _key in "${!tag_vars[@]}"; do
    [[ "$1" == "${_key}" ]] && return 0
  done
  return 1
}
readonly -f __sgl_mk_dest__has_key

############################################################
# @private
# @func __sgl_mk_dest__set_key
# @use __sgl_mk_dest__set_key LINE
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__set_key()
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
    if ! __sgl_mk_dest__chk_key "${key}"; then
      key="\`${FN}' KEY \`\${${key}}'"
      _sgl_err VAL "invalid ${key} at LINE \`${_line}' in SRC \`${src}'"
    fi
    if ! __sgl_mk_dest__has_key "${key}"; then
      key="\`${FN}' KEY \`\${${key}}'"
      _sgl_err VAL "undefined ${key} at LINE \`${_line}' in SRC \`${src}'"
    fi
  else
    key="$(printf '%s' "${key}" | ${sed} -e 's/[^a-zA-Z0-9_].*$//')"
    if ! __sgl_mk_dest__chk_key "${key}"; then
      key="\`${FN}' KEY \`\$${key}'"
      _sgl_err VAL "invalid ${key} at LINE \`${_line}' in SRC \`${src}'"
    fi
    if ! __sgl_mk_dest__has_key "${key}"; then
      key="\`${FN}' KEY \`\$${key}'"
      _sgl_err VAL "undefined ${key} at LINE \`${_line}' in SRC \`${src}'"
    fi
  fi
}
readonly -f __sgl_mk_dest__set_key

############################################################
# @private
# @func __sgl_mk_dest__set_val
# @use __sgl_mk_dest__set_val LINE
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__set_val()
{
  local _line="${1}"
  local _val
  local key

  val="$(__sgl_mk_dest__trim_tag "${_line}")"

  while [[ "${val}" =~ \$ ]]; do
    __sgl_mk_dest__set_key "${_line}"
    _val="${tag_vars[${key}]}"
    [[ "${val#*$}" =~ ^\{ ]] && key="{${key}}"
    key="\$${key}"
    val="$(printf '%s' "${val}" | ${sed} -e "s/${key}/${_val}/")"
  done
}
readonly -f __sgl_mk_dest__set_val

############################################################
# @private
# @func __sgl_mk_dest__trim_tag
# @use __sgl_mk_dest__trim_tag LINE
# @return
#   0  PASS
############################################################
__sgl_mk_dest__trim_tag()
{
  printf '%s' "${1}" | ${sed} \
    -e 's/^[[:blank:]]*#[[:blank:]]*@[[:lower:]]\+[[:blank:]]\+//' \
    -e 's/[[:blank:]]\+$//'
}
readonly -f __sgl_mk_dest__trim_tag

################################################################################
## DEFINE ARGUMENT FUNCTIONS
################################################################################

############################################################
# @private
# @func __sgl_mk_dest__args
# @use __sgl_mk_dest__args ...ARG
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__args()
{
  _sgl_parse_args "${FN}" \
    '-B|--backup-ext'   1 \
    '-b|--backup'       2 \
    '-D|--defines'      1 \
    '-d|--define'       1 \
    '-E|--no-empty'     0 \
    '-e|--empty'        0 \
    '-F|--no-force'     0 \
    '-f|--force'        0 \
    '-H|--cmd-dereference' 0 \
    '-h|-?|--help'      0 \
    '-I|--no-include'   0 \
    '-K|--no-keep'      1 \
    '-k|--keep'         2 \
    '-L|--dereference'  0 \
    '-l|--link'         0 \
    '-m|--mode'         1 \
    '-N|--no-insert'    0 \
    '-n|--no-clobber'   0 \
    '-o|--owner'        1 \
    '-P|--no-dereference' 0 \
    '-Q|--silent'       0 \
    '-q|--quiet'        0 \
    '-r|--recursive'    0 \
    '-s|--symlink'      0 \
    '-t|--test'         1 \
    '-u|--update'       0 \
    '-V|--verbose'      0 \
    '-v|--version'      0 \
    '-w|--warn'         0 \
    '-x|--one-file-system' 0 \
    -- "$@"
}
readonly -f __sgl_mk_dest__args

################################################################################
## DEFINE OPTION FUNCTIONS
################################################################################

############################################################
# @private
# @func __sgl_mk_dest__opts
# @use __sgl_mk_dest__opts ...OPT
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__opts()
{
  local -i _index=0
  local -i _bool
  local _opt
  local _val

  tag_vars=(['HOME']="$(_sgl_escape_val "${HOME}")")

  [[ ${SGL_QUIET_PARENT}  -eq 1 ]] && quiet=1
  [[ ${SGL_SILENT_PARENT} -eq 1 ]] && silent=1

  # parse each OPTION
  for _opt in "$@"; do
    _bool=${_SGL_OPT_BOOL[${_index}]}
    _val="${_SGL_OPT_VALS[${_index}]}"
    __sgl_mk_dest__opt "${_opt}" ${_bool} "${_val}"
    _index=$(( ++_index ))
  done

  # set empty regex to pass
  [[ -z "${regex}" ]] && regex='.*'

  # append target option
  __sgl_mk_dest__add_cp_opt '--no-target-directory'
}
readonly -f __sgl_mk_dest__opts

############################################################
# @private
# @func __sgl_mk_dest__opt
# @use __sgl_mk_dest__opt OPT BOOL VAL
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__opt()
{
  case "$1" in
    -B|--backup-ext)
      __sgl_mk_dest__opt_B "$@"
      ;;
    -b|--backup)
      __sgl_mk_dest__opt_b "$@"
      ;;
    -D|--defines)
      __sgl_mk_dest__opt_D "$@"
      ;;
    -d|--define)
      __sgl_mk_dest__opt_d "$@"
      ;;
    -E|--no-empty)
      empty=0
      ;;
    -e|--empty)
      empty=1
      ;;
    -F|--no-force)
      force=0
      __sgl_mk_dest__add_cp_opt '--no-clobber'
      ;;
    -f|--force)
      force=1
      __sgl_mk_dest__add_cp_opt '--force'
      ;;
    -H|--cmd-dereference)
      __sgl_mk_dest__add_cp_opt '-H'
      ;;
    -h|-\?|--help)
      _sgl_help sgl_mk_dest
      ;;
    -I|--no-include)
      include=0
      ;;
    -K|--no-keep)
      __sgl_mk_dest__opt_K "$@"
      ;;
    -k|--keep)
      __sgl_mk_dest__opt_k "$@"
      ;;
    -L|--dereference)
      __sgl_mk_dest__add_cp_opt '-L'
      ;;
    -l|--link)
      __sgl_mk_dest__add_cp_opt '--link'
      ;;
    -m|--mode)
      __sgl_mk_dest__opt_m "$@"
      ;;
    -N|--no-insert)
      insert=0
      ;;
    -n|--no-clobber)
      force=0
      __sgl_mk_dest__add_cp_opt '--no-clobber'
      ;;
    -o|--owner)
      __sgl_mk_dest__opt_o "$@"
      ;;
    -P|--no-dereference)
      __sgl_mk_dest__add_cp_opt '-P'
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
    -s|--symlink)
      __sgl_mk_dest__add_cp_opt '--symbolic-link'
      ;;
    -t|--test)
      regex="$3"
      ;;
    -u|--update)
      __sgl_mk_dest__add_cp_opt '--update'
      ;;
    -V|--verbose)
      __sgl_mk_dest__add_cp_opt '--verbose'
      ;;
    -v|--version)
      _sgl_version
      ;;
    -w|--warn)
      force=1
      __sgl_mk_dest__add_cp_opt '--interactive'
      ;;
    -x|--one-file-system)
      __sgl_mk_dest__add_cp_opt '--one-file-system'
      ;;
    *)
      _sgl_err SGL "invalid parsed \`${FN}' OPTION \`${1}'"
      ;;
  esac
}
readonly -f __sgl_mk_dest__opt

############################################################
# @private
# @func __sgl_mk_dest__opt_B
# @use __sgl_mk_dest__opt_B OPT BOOL VAL
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__opt_B()
{
  [[ -n "$3" ]] || _sgl_err VAL "missing \`${FN}' \`${1}' EXT"

  if [[ "$3" =~ [[:space:]] ]]; then
    _sgl_err VAL "invalid space in \`${FN}' \`${1}' EXT \`${3}'"
  fi

  __sgl_mk_dest__add_cp_opt "--suffix=${3}"
}
readonly -f __sgl_mk_dest__opt_B

############################################################
# @private
# @func __sgl_mk_dest__opt_b
# @use __sgl_mk_dest__opt_b OPT BOOL VAL
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__opt_b()
{
  if [[ $2 -eq 0 ]]; then
    __sgl_mk_dest__add_cp_opt '--backup'
    return 0
  fi

  case "$3" in
    none|off)     ;;
    numbered|t)   ;;
    existing|nil) ;;
    simple|never) ;;
    *)
      _sgl_err VAL "invalid \`${FN}' \`${1}' CTRL \`${3}'"
      ;;
  esac
  __sgl_mk_dest__add_cp_opt "--backup=${3}"
}
readonly -f __sgl_mk_dest__opt_b

############################################################
# @private
# @func __sgl_mk_dest__opt_D
# @use __sgl_mk_dest__opt_D OPT BOOL VAL
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__opt_D()
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
    if ! __sgl_mk_dest__chk_key "${_key}"; then
      _sgl_err VAL "invalid \`${FN}' \`${1}' VAR \`${_var}' KEY \`${_key}'"
    fi
    tag_vars["${_key}"]="$(_sgl_escape_val "${_val}")"
  done <<< "${3},"
}
readonly -f __sgl_mk_dest__opt_D

############################################################
# @private
# @func __sgl_mk_dest__opt_d
# @use __sgl_mk_dest__opt_d OPT BOOL VAL
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__opt_d()
{
  local _key
  local _val

  [[ -n "${3}" ]] || _sgl_err VAL "missing \`${FN}' \`${1}' VAR"

  [[ "${3}" =~ = ]] || _sgl_err VAL "missing \`${FN}' \`${1}' VAR \`${3}' VALUE"

  _key="${3%%=*}"
  _val="${3#*=}"

  if ! __sgl_mk_dest__chk_key "${_key}"; then
    _sgl_err VAL "invalid \`${FN}' \`${1}' VAR \`${3}' KEY \`${_key}'"
  fi

  tag_vars["${_key}"]="$(_sgl_escape_val "${_val}")"
}
readonly -f __sgl_mk_dest__opt_d

############################################################
# @private
# @func __sgl_mk_dest__opt_K
# @use __sgl_mk_dest__opt_K OPT BOOL VAL
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__opt_K()
{
  local _attr

  [[ -n "$3" ]] || _sgl_err VAL "missing \`${FN}' \`${1}' ATTRS"

  # check each ATTR
  while IFS= read -r -d ',' _attr; do
    case "${_attr}" in
      mode)       ;;
      ownership)  ;;
      timestamps) ;;
      context)    ;;
      links)      ;;
      xattr)      ;;
      all)        ;;
      *)
        _sgl_err VAL "invalid \`${FN}' \`${1}' ATTR \`${_attr}'"
        ;;
    esac
  done <<< "${3},"

  __sgl_mk_dest__add_cp_opt "--no-preserve=${3}"
}
readonly -f __sgl_mk_dest__opt_K

############################################################
# @private
# @func __sgl_mk_dest__opt_k
# @use __sgl_mk_dest__opt_k OPT BOOL VAL
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__opt_k()
{
  local _attr

  if [[ $2 -eq 0 ]]; then
    __sgl_mk_dest__add_cp_opt '--preserve'
    return 0
  fi

  [[ -n "$3" ]] || _sgl_err VAL "missing \`${FN}' \`${1}' ATTRS"

  # check each ATTR
  while IFS= read -r -d ',' _attr; do
    case "${_attr}" in
      mode)       ;;
      ownership)  ;;
      timestamps) ;;
      context)    ;;
      links)      ;;
      xattr)      ;;
      all)        ;;
      *)
        _sgl_err VAL "invalid \`${FN}' \`${1}' ATTR \`${_attr}'"
        ;;
    esac
  done <<< "${3},"

  __sgl_mk_dest__add_cp_opt "--preserve=${3}"
}
readonly -f __sgl_mk_dest__opt_k

############################################################
# @private
# @func __sgl_mk_dest__opt_m
# @use __sgl_mk_dest__opt_m OPT BOOL VAL
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__opt_m()
{
  [[ -n "$3" ]] || _sgl_err VAL "missing \`${FN}' \`${1}' MODE"

  __sgl_mk_dest__chk_mode "$3" \
    || _sgl_err VAL "invalid \`${FN}' \`${1}' MODE \`${3}'"

  mode="$3"
}
readonly -f __sgl_mk_dest__opt_m

############################################################
# @private
# @func __sgl_mk_dest__opt_o
# @use __sgl_mk_dest__opt_o OPT BOOL VAL
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__opt_o()
{
  [[ -n "$3" ]] || _sgl_err VAL "missing \`${FN}' \`${1}' OWNER"

  if [[ "$3" =~ [[:space:]] ]]; then
    _sgl_err VAL "invalid space in \`${FN}' \`${1}' OWNER \`${3}'"
  fi

  owner="$3"
}
readonly -f __sgl_mk_dest__opt_o

################################################################################
## DEFINE VALUE FUNCTIONS
################################################################################

############################################################
# @private
# @func __sgl_mk_dest__vals
# @use __sgl_mk_dest__vals ...SRC
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__vals()
{
  local _src

  [[ $# -eq 0 ]] && _sgl_err VAL "missing \`${FN}' SRC"

  for _src in "${@}"; do
    if [[ -d "${_src}" ]]; then
      if [[ ${deep} -eq 1 ]]; then
        __sgl_mk_dest__dirs "${_src}"
      else
        __sgl_mk_dest__dir "${_src}"
      fi
    else
      __sgl_mk_dest__val "${_src}"
    fi
  done
}
readonly -f __sgl_mk_dest__vals

############################################################
# @private
# @func __sgl_mk_dest__dir
# @use __sgl_mk_dest__dir SRCDIR
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__dir()
{
  local _src

  for _src in "${1}"/*; do
    [[ -f "${_src}" ]] && __sgl_mk_dest__val "${_src}"
  done
}
readonly -f __sgl_mk_dest__dir

############################################################
# @private
# @func __sgl_mk_dest__dirs
# @use __sgl_mk_dest__dirs SRCDIR
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__dirs()
{
  local _src

  for _src in "${1}"/*; do
    if [[ -d "${_src}" ]]; then
      __sgl_mk_dest__dirs "${_src}"
    elif [[ -f "${_src}" ]]; then
      __sgl_mk_dest__val "${_src}"
    fi
  done
}
readonly -f __sgl_mk_dest__dirs

############################################################
# @private
# @func __sgl_mk_dest__val
# @use __sgl_mk_dest__val SRC
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__val()
{
  local src="${1}"
  local dst
  local val
  local -A src_vars
  local _line
  local _mode
  local _owner

  [[ -f "${src}" ]] || _sgl_err VAL "invalid path for \`${FN}' SRC \`${src}'"

  # handle no dest tags in SRC
  if ! ${grep} "${dtag}" "${src}" > ${NIL} 2>&1; then
    [[ ${empty} -eq 1 ]] && return 0
    _sgl_err VAL "missing dest tag in \`${FN}' SRC \`${src}'"
  fi

  __sgl_mk_dest__src_vars

  # set file mode
  if [[ -n "${mode}" ]]; then
    _mode="${mode}"
  elif ${grep} "${mtag}" "${src}" > ${NIL} 2>&1; then
    if [[ "$(${grep} -c "${mtag}" "${src}" 2> ${NIL})" != '1' ]]; then
      _sgl_err VAL "only 1 mode tag allowed in \`${FN}' SRC \`${src}'"
    fi
    __sgl_mk_dest__set_val "$(${grep} "${mtag}" "${src}" 2> ${NIL})"
    _mode="${val}"
    __sgl_mk_dest__chk_mode "${_mode}" \
      || _sgl_err VAL "invalid \`${FN}' SRC \`${src}' MODE \`${_mode}'"
  fi

  # set file owner
  if [[ -n "${owner}" ]]; then
    _owner="${owner}"
  elif ${grep} "${otag}" "${src}" > ${NIL} 2>&1; then
    if [[ "$(${grep} -c "${otag}" "${src}" 2> ${NIL})" != '1' ]]; then
      _sgl_err VAL "only 1 owner tag allowed in \`${FN}' SRC \`${src}'"
    fi
    __sgl_mk_dest__set_val "$(${grep} "${otag}" "${src}" 2> ${NIL})"
    _owner="${val}"
    if [[ "${_owner}" =~ [[:space:]] ]]; then
      _sgl_err VAL "invalid space in \`${FN}' SRC \`${src}' OWNER \`${_owner}'"
    fi
  fi

  # parse each DEST
  while IFS= read -r _line; do
    __sgl_mk_dest__dst "${_line}"
    __sgl_mk_dest__cp
    __sgl_mk_dest__insert
    __sgl_mk_dest__include
    __sgl_mk_dest__chmod "${_mode}"
    __sgl_mk_dest__chown "${_owner}"
  done <<< "$(${grep} "${dtag}" "${src}" 2> ${NIL})"
}
readonly -f __sgl_mk_dest__val

############################################################
# @private
# @func __sgl_mk_dest__src_vars
# @use __sgl_mk_dest__src_vars
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__src_vars()
{
  local _key
  local _val
  local _line

  [[ ${insert} -eq 1 ]] || return 0

  # parse VERSION
  if ${grep} "${vertag}" "${src}" > ${NIL} 2>&1; then
    if [[ "$(${grep} -c "${vertag}" "${src}" 2> ${NIL})" != '1' ]]; then
      _sgl_err VAL "only 1 version tag allowed in \`${FN}' SRC \`${src}'"
    fi
    __sgl_mk_dest__set_val "$(${grep} "${vertag}" "${src}" 2> ${NIL})"
    src_vars=(['VERSION']="$(_sgl_escape_val "${val}")")
  fi

  # parse each KEY=VALUE
  if ${grep} "${vtag}" "${src}" > ${NIL} 2>&1; then
    local -r squote='^[^=]+=[[:blank:]]*'"'"
    local -r dquote='^"'
    while IFS= read -r _line; do
      __sgl_mk_dest__set_val "${_line}"
      if [[ ! "${val}" =~ = ]]; then
        _val="\`${FN}' VALUE"
        _sgl_err VAL "missing ${_val} at LINE \`${_line}' in SRC \`${src}'"
      fi
      _key="$(printf '%s' "${val%%=*}" | ${sed} -e 's/[[:blank:]]\+$//')"
      if ! __sgl_mk_dest__chk_key "${_key}"; then
        _key="\`${FN}' KEY \`${_key}'"
        _sgl_err VAL "invalid ${_key} at LINE \`${_line}' in SRC \`${src}'"
      fi
      if [[ "${_line}" =~ ${squote} ]]; then
        _val="$(printf '%s' "${_line#*=}" | ${sed} -e 's/^[[:blank:]]\+//')"
        _val="${_val#'}"
        _val="${_val%'}"
      else
        _val="$(printf '%s' "${val#*=}" | ${sed} -e 's/^[[:blank:]]\+//')"
        if [[ "${_val}" =~ ${dquote} ]]; then
          _val="${_val#\"}"
          _val="${_val%\"}"
        fi
      fi
      src_vars["${_key}"]="$(_sgl_escape_val "${_val}")"
    done <<< "$(${grep} "${vtag}" "${src}" 2> ${NIL})"
  fi
}
readonly -f __sgl_mk_dest__src_vars

############################################################
# @private
# @func __sgl_mk_dest__dst
# @use __sgl_mk_dest__dst LINE
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__dst()
{
  local _key
  local _val

  __sgl_mk_dest__set_val "${1}"

  dst="${val}"
  [[ "${dst}" =~ ^/ ]] || dst="${src%/*}/${dst}"

  if [[ ! "${dst}" =~ ${regex} ]] || [[ ! -d "${dst%/*}" ]]; then
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
  elif [[ ${force} -ne 1 ]]; then
    dst="\`${FN}' DEST \`${dst}' at LINE \`${1}' in SRC \`${src}'"
    _sgl_err VAL "a file already exists for ${dst} (use \`--force' to overwrite)"
  fi
}
readonly -f __sgl_mk_dest__dst

############################################################
# @private
# @func __sgl_mk_dest__cp
# @use __sgl_mk_dest__cp
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__cp()
{
  ${cp} "${cp_opts[@]}" "${src}" "${dst}" \
    || _sgl_err CHLD "\`${cp}' in \`${FN}' exited with \`$?'"
}
readonly -f __sgl_mk_dest__cp

############################################################
# @private
# @func __sgl_mk_dest__insert
# @use __sgl_mk_dest__insert
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__insert()
{
  local _key
  local _val

  [[ ${insert} -eq 1 ]] || return 0

  for _key in "${!src_vars[@]}"; do
    _val="${src_vars[${_key}]}"
    _key="^\([[:blank:]]*\)\([^#@].*\)\?@${_key}"
    ${sed} -i -e "s/${_key}/\1\2${_val}/g" "${dst}" \
      || _sgl_err CHLD "\`${sed}' in \`${FN}' exited with \`$?'"
  done
}
readonly -f __sgl_mk_dest__insert

############################################################
# @private
# @func __sgl_mk_dest__include
# @use __sgl_mk_dest__include
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__include()
{
  local _line
  local _path
  local _content

  [[ ${include} -eq 1 ]] || return 0

  if ${grep} "${itag}" "${src}" > ${NIL} 2>&1; then
    while IFS= read -r _line; do
      __sgl_mk_dest__set_val "${_line}"
      _path="${val}"
      [[ "${_path}" =~ ^/ ]] || _path="${src%/*}/${_path}"
      if [[ ! -f "${_path}" ]]; then
        _path="\`${FN}' FILE \`${_path}'"
        _sgl_err VAL "invalid ${_path} at LINE \`${_line}' in SRC \`${src}'"
      fi
      _line="$(_sgl_escape_key "${_line}")"
      _content="$(_sgl_escape_cont "${_path}")"
      ${sed} -i -e "s/${_line}/${_content}/" "${dst}"
    done <<< "$(${grep} "${itag}" "${src}" 2> ${NIL})"
  fi
}
readonly -f __sgl_mk_dest__include

############################################################
# @private
# @func __sgl_mk_dest__chmod
# @use __sgl_mk_dest__chmod MODE
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__chmod()
{
  [[ -n "${1}" ]] || return 0

  ${chmod} "${1}" "${dst}" \
    || _sgl_err CHLD "\`${chmod}' in \`${FN}' exited with \`$?'"
}
readonly -f __sgl_mk_dest__chmod

############################################################
# @private
# @func __sgl_mk_dest__chown
# @use __sgl_mk_dest__chown OWNER
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__chown()
{
  [[ -n "${1}" ]] || return 0

  ${chown} "${1}" "${dst}" \
    || _sgl_err CHLD "\`${chown}' in \`${FN}' exited with \`$?'"
}
readonly -f __sgl_mk_dest__chown
