#!/bin/bash
#
# @dest /lib/superglue/sgl_mk_dest
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
# @opt -d|--define=VARS      Define variables for each DEST to use.
# @opt -E|--no-empty         Force SRC to contain at least one destination tag.
# @opt -e|--empty            Allow SRC to not contain a destination tag.
# @opt -F|--no-force         If destination exists do not overwrite it.
# @opt -f|--force            If a destination exists overwrite it.
# @opt -H|--cmd-dereference  Follow command-line SRC symlinks.
# @opt -h|-?|--help          Print help info and exit.
# @opt -K|--no-keep=ATTRS    Do not preserve the ATTRS.
# @opt -k|--keep[=ATTRS]     Keep the ATTRS (default= `mode,ownership,timestamps').
# @opt -L|--dereference      Always follow SRC symlinks.
# @opt -l|--link             Hard link files instead of copying.
# @opt -m|--mode=MODE        Set the file mode for each destination.
# @opt -n|--no-clobber       If destination exists do not overwrite.
# @opt -o|--owner=OWNER      Set the file owner for each destination.
# @opt -P|--no-dereference   Never follow SRC symlinks.
# @opt -Q|--silent           Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet            Disable `stdout' output.
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
# @val DEST   Must be a valid path.
# @val EXT    Must be a valid file extension to append to the end of a backup file.
#             The default is `~'. Spaces are not allowed.
# @val MODE   Must be a valid file mode.
# @val OWNER  Must be a valid USER[:GROUP].
# @val REGEX  Can be any string. Refer to bash test `=~' operator for more details.
# @val SRC    Must be a valid file path. File must also contain at least one
#             destination tag: `# @dest DEST'.
# @val VAR    Must be a valid `KEY=VALUE' pair. The KEY must start with a character
#             matching `[a-zA-Z_]', can only contain `[a-zA-Z0-9_]', and must end
#             with `[a-zA-Z0-9]'. The VALUE must not contain a `,'.
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

  # option flags
  local -i silent
  local -i quiet
  local -i force
  local -i empty
  local regex
  local mode
  local own

  # parsed values
  local -a cp_opts
  local -A vars

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

  for _key in "${!vars[@]}"; do
    [[ "$1" == "${_key}" ]] && return 0
  done
  return 1
}
readonly -f __sgl_mk_dest__has_key

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
    '-d|--define'       1 \
    '-E|--no-empty'     0 \
    '-e|--empty'        0 \
    '-F|--no-force'     0 \
    '-f|--force'        0 \
    '-H|--cmd-dereference' 0 \
    '-h|-?|--help'      0 \
    '-K|--no-keep'      1 \
    '-k|--keep'         2 \
    '-L|--dereference'  0 \
    '-l|--link'         0 \
    '-m|--mode'         1 \
    '-n|--no-clobber'   0 \
    '-o|--owner'        1 \
    '-P|--no-dereference' 0 \
    '-Q|--silent'       0 \
    '-q|--quiet'        0 \
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

  # set default values
  cp_opts=()
  vars=(['HOME']="$(printf '%s' "${HOME}" | ${sed} -e 's/[\/&]/\\&/g')")
  empty=0
  force=0
  regex='/[^/]+/[^/]+$'
  quiet=${SGL_QUIET}
  silent=${SGL_SILENT}
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
# @func __sgl_mk_dest__opt_d
# @use __sgl_mk_dest__opt_d OPT BOOL VAL
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__opt_d()
{
  local _var
  local _key
  local _val

  [[ -n "$3" ]] || _sgl_err VAL "missing \`${FN}' \`${1}' VARS"

  while IFS= read -r -d ',' _var; do
    if [[ ! "${_var}" =~ = ]]; then
      _sgl_err VAL "missing \`${FN}' \`${1}' VAR \`${_var}' VALUE"
    fi
    _key="${_var%%=*}"
    _val="${_var#*=}"
    if ! __sgl_mk_dest__chk_key "${_key}"; then
      _sgl_err VAL "invalid \`${FN}' \`${1}' VAR \`${_var}' KEY \`${_key}'"
    fi
    vars["${_key}"]="$(printf '%s' "${_val}" | ${sed} -e 's/[\/&]/\\&/g')"
  done <<EOF
${3},
EOF
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
  done <<EOF
${3},
EOF

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
  done <<EOF
${3},
EOF

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
  local -r _lmode='^[ugoa]*([-+=]([rwxXst]+|[ugo]))+$'
  local -r _omode='^[-+=]?[0-7]{1,4}$'

  [[ -n "$3" ]] || _sgl_err VAL "missing \`${FN}' \`${1}' MODE"

  if [[ ! "$3" =~ ${_lmode} ]] && [[ ! "$3" =~ ${_omode} ]]; then
    _sgl_err VAL "invalid \`${FN}' \`${1}' MODE \`${3}'"
  fi

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

  own="$3"
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

  for _src in "$@"; do
    __sgl_mk_dest__val "${_src}"
  done
}
readonly -f __sgl_mk_dest__vals

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
  local src="$1"
  local dst
  local _mode
  local _own

  [[ -f "${src}" ]] || _sgl_err VAL "invalid path for \`${FN}' SRC \`${src}'"

  # handle no dest tags in SRC
  if ! ${grep} "${dtag}" "${src}" > ${NIL} 2>&1; then
    [[ ${empty} -eq 1 ]] && return 0
    _sgl_err VAL "missing dest tag in \`${FN}' SRC \`${src}'"
  fi

  # set file mode
  if [[ -n "${mode}" ]]; then
    _mode="${mode}"
  else
    : # insert mode tag logic here
  fi

  # set file owner
  if [[ -n "${own}" ]]; then
    _own="${own}"
  else
    : # insert own tag logic here
  fi

  # parse each DEST
  while IFS= read -r dst; do
    __sgl_mk_dest__dst
    __sgl_mk_dest__cp
    __sgl_mk_dest__chmod "${_mode}"
    __sgl_mk_dest__chown "${_own}"
  done <<EOF
$(${grep} "${dtag}" "${src}" 2> ${NIL})
EOF
}
readonly -f __sgl_mk_dest__val

############################################################
# @private
# @func __sgl_mk_dest__dst
# @use __sgl_mk_dest__dst
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__dst()
{
  local -r _blank='[[:blank:]]\+$'
  local _key
  local _val

  # trim dest tag and blank space from DEST
  dst="$(printf '%s' "${dst}" | ${sed} -e "s/${dtag}//" -e "s/${_blank}//")"

  # replace vars in DEST
  while [[ "${dst}" =~ \$ ]]; do
    _key="${dst#*$}"
    if [[ -z "${_key}" ]]; then
      _sgl_err VAL "invalid \`${FN}' SRC \`${src}' DEST \`${dst}'"
    fi
    if [[ "${_key}" =~ ^\{ ]]; then
      if [[ ! "${_key}" =~ \} ]]; then
        _key="KEY \`\$${_key%%\$*}'"
        _sgl_err VAL "invalid \`${FN}' SRC \`${src}' DEST \`${dst}' ${_key}"
      fi
      _key="${_key#\{}"
      _key="${_key%%\}*}"
      if ! __sgl_mk_dest__chk_key "${_key}"; then
        _key="KEY \`\${${_key}}'"
        _sgl_err VAL "invalid \`${FN}' SRC \`${src}' DEST \`${dst}' ${_key}"
      fi
      if ! __sgl_mk_dest__has_key "${_key}"; then
        _key="KEY \`\${${_key}}'"
        _sgl_err VAL "undefined \`${FN}' SRC \`${src}' DEST \`${dst}' ${_key}"
      fi
      _val="${vars[${_key}]}"
      _key='\${'"${_key}"'}'
      dst="$(printf '%s' "${dst}" | ${sed} -e "s/${_key}/${_val}/")"
    else
      _key="$(printf '%s' "${_key}" | ${sed} -e 's/[^a-zA-Z0-9_].*$//')"
      if ! __sgl_mk_dest__chk_key "${_key}"; then
        _key="KEY \`\$${_key}'"
        _sgl_err VAL "invalid \`${FN}' SRC \`${src}' DEST \`${dst}' ${_key}"
      fi
      if ! __sgl_mk_dest__has_key "${_key}"; then
        _key="KEY \`\$${_key}'"
        _sgl_err VAL "undefined \`${FN}' SRC \`${src}' DEST \`${dst}' ${_key}"
      fi
      _val="${vars[${_key}]}"
      _key='\$'"${_key}"
      dst="$(printf '%s' "${dst}" | ${sed} -e "s/${_key}/${_val}/")"
    fi
  done

  # check DEST
  if [[ ! "${dst}" =~ ${regex} ]] || [[ ! -d "${dst%/*}" ]]; then
    _sgl_err VAL "invalid \`${FN}' SRC \`${src}' DEST \`${dst}'"
  fi
  if [[ ! -f "${dst}" ]]; then
    if [[ -d "${dst}" ]]; then
      _sgl_err VAL "a dir already exists for DEST \`${dst}' in SRC \`${src}'"
    fi
    if [[ -a "${dst}" ]]; then
      _sgl_err VAL "a non-file already exists for DEST \`${dst}' in SRC \`${src}'"
    fi
  elif [[ ${force} -ne 1 ]]; then
    _sgl_err VAL "DEST \`${dst}' already exists (use \`--force' to overwrite)"
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
