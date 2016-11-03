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
  local -i RT
  local -i i
  local -i len
  local -i force=0
  local -i quiet=${SGL_QUIET}
  local -i silent=${SGL_SILENT}
  local -a modes
  local -a owns
  local -a opts
  local -a vals
  local -a vars
  local -A keys
  local -A paths
  local regex='/[^/]+/[^/]+$'
  local mode
  local own
  local key
  local opt
  local val
  local var
  local src
  local tag
  local dest
  local path
  local space
  local parent

  # setup VARS
  vars=(HOME)
  keys[HOME]='\$HOME\|\${HOME}' # regex `$KEY|${KEY}'
  paths[HOME]="$(printf '%s' ${HOME} | ${sed} -e 's/[\/&]/\\&/g')"

  # parse each argument
  _sgl_parse_args "${FN}" \
    '-B|--backup-ext'   1 \
    '-b|--backup'       2 \
    '-d|--define'       1 \
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

  # parse each OPTION
  len=${#_SGL_OPTS[@]}
  opts=()
  for ((i=0; i<len; i++)); do
    opt="${_SGL_OPTS[${i}]}"
    case "${opt}" in
      -B|--backup-ext)
        __sgl_mk_dest__opt_B "${_SGL_OPT_VALS[${i}]}"
        ;;
      -b|--backup)
        __sgl_mk_dest__opt_b ${_SGL_OPT_BOOL[${i}]} "${_SGL_OPT_VALS[${i}]}"
        ;;
      -d|--define)
        __sgl_mk_dest__opt_d "${_SGL_OPT_VALS[${i}]}"
        ;;
      -F|--no-force)
        force=0
        opts[${#opts[@]}]='--no-clobber'
        ;;
      -f|--force)
        force=1
        opts[${#opts[@]}]='--force'
        ;;
      -H|--cmd-dereference)
        opts[${#opts[@]}]='-H'
        ;;
      -h|-\?|--help)
        _sgl_help sgl_mk_dest
        ;;
      -K|--no-keep)
        __sgl_mk_dest__opt_K "${_SGL_OPT_VALS[${i}]}"
        ;;
      -k|--keep)
        __sgl_mk_dest__opt_k ${_SGL_OPT_BOOL[${i}]} "${_SGL_OPT_VALS[${i}]}"
        ;;
      -L|--dereference)
        opts[${#opts[@]}]='-L'
        ;;
      -l|--link)
        opts[${#opts[@]}]='--link'
        ;;
      -m|--mode)
        __sgl_mk_dest__opt_m "${_SGL_OPT_VALS[${i}]}"
        ;;
      -n|--no-clobber)
        force=0
        opts[${#opts[@]}]='--no-clobber'
        ;;
      -o|--owner)
        __sgl_mk_dest__opt_o "${_SGL_OPT_VALS[${i}]}"
        ;;
      -P|--no-dereference)
        opts[${#opts[@]}]='-P'
        ;;
      -Q|--silent)
        silent=1
        ;;
      -q|--quiet)
        quiet=1
        ;;
      -s|--symlink)
        opts[${#opts[@]}]='--symbolic-link'
        ;;
      -t|--test)
        regex="${_SGL_OPT_VALS[${i}]}"
        ;;
      -u|--update)
        opts[${#opts[@]}]='--update'
        ;;
      -V|--verbose)
        opts[${#opts[@]}]='--verbose'
        ;;
      -v|--version)
        _sgl_version
        ;;
      -w|--warn)
        force=1
        opts[${#opts[@]}]='--interactive'
        ;;
      -x|--one-file-system)
        opts[${#opts[@]}]='--one-file-system'
        ;;
      *)
        _sgl_err SGL "invalid parsed \`${FN}' OPTION \`${opt}'"
        ;;
    esac
  done

  # append target option
  opts[${#opts[@]}]='--no-target-directory'

  # catch missing SRC
  [[ ${#_SGL_VALS[@]} -gt 0 ]] || _sgl_err VAL "missing \`${FN}' SRC"

  # set grep/sed regexps and home replace
  tag='^[[:blank:]]*#[[:blank:]]*@dest[[:blank:]]\+'
  space='[[:blank:]]\+$'

  # build values
  vals=()
  for src in "${_SGL_VALS[@]}"; do
    [[ -f "${src}" ]] || _sgl_err VAL "invalid \`${FN}' SRC path \`${src}'"

    # catch missing dest tag in SRC
    ${grep} "${tag}" "${src}" > ${NIL}
    RT=$?
    [[ ${RT} -eq 1 ]] && _sgl_err VAL "missing \`${FN}' SRC \`${src}' dest tag"
    if [[ ${RT} -ne 0 ]]; then
      _sgl_err CHLD "\`${grep}' in \`${FN}' exited with \`${RT}'"
    fi

    # parse each DEST
    while IFS= read -r dest; do
      dest="$(printf '%s' "${dest}" | ${sed} -e "s/${tag}//" -e "s/${space}//")"
      for var in "${vars[@]}"; do
        [[ "${dest}" =~ ${var} ]] || continue
        key="${keys[${var}]}"
        path="${paths[${var}]}"
        dest="$(printf '%s' "${dest}" | ${sed} -e "s/${key}/${path}/g")"
      done
      if [[ -n "${regex}" ]] && [[ ! "${dest}" =~ ${regex} ]]; then
        _sgl_err VAL "invalid \`${FN}' SRC \`${src}' DEST path \`${dest}'"
      fi
      parent="$(printf '%s' "${dest}" | ${sed} -e 's|/[^/]\+$||')"
      if [[ ! -d "${parent}" ]]; then
        _sgl_err VAL "invalid \`${FN}' SRC \`${src}' DEST path \`${dest}'"
      fi
      if [[ -d "${dest}" ]]; then
        _sgl_err VAL "a DEST dir \`${dest}' already exists in SRC \`${src}'"
      fi
      if [[ -f "${dest}" ]] && [[ ${force} -ne 1 ]]; then
        _sgl_err VAL "DEST \`${dest}' already exists (use \`--force' to overwrite)"
      fi

      # append SRC and DEST
      vals[${#vals[@]}]="${src}"
      vals[${#vals[@]}]="${dest}"
    done <<EOF
$(${grep} "${tag}" "${src}")
EOF
  done

  # make each DEST
  len=${#vals[@]}
  for ((i=0; i<len; i++)); do
    src="${vals[${i}]}"
    i=$(( ++i ))
    dest="${vals[${i}]}"

    # copy SRC
    ${cp} "${opts[@]}" "${src}" "${dest}"
    RT=$?
    if [[ ${RT} -ne 0 ]]; then
      _sgl_err CHLD "\`${cp}' in \`${FN}' exited with \`${RT}'"
    fi

    # set DEST file mode
    if [[ -n "${mode}" ]]; then
      ${chmod} "${mode}" "${dest}"
      RT=$?
      if [[ ${RT} -ne 0 ]]; then
        _sgl_err CHLD "\`${chmod}' in \`${FN}' exited with \`${RT}'"
      fi
    fi

    # set DEST file owner
    if [[ -n "${own}" ]]; then
      ${chown} "${own}" "${dest}"
      RT=$?
      if [[ ${RT} -ne 0 ]]; then
        _sgl_err CHLD "\`${chown}' in \`${FN}' exited with \`${RT}'"
      fi
    fi
  done
}
readonly -f sgl_mk_dest

############################################################
# @private
# @func __sgl_mk_dest__opt_B
# @use __sgl_mk_dest__opt_B EXT
# @val EXT  Must be a valid file extension to append to the end of a backup file.
#           The default is `~'. Spaces are not allowed.
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__opt_B()
{
  [[ -n "$1" ]] || _sgl_err VAL "missing \`${FN}' \`${opt}' EXT"

  if [[ "$1" =~ [[:space:]] ]]; then
    _sgl_err VAL "invalid space in \`${FN}' \`${opt}' EXT \`${1}'"
  fi

  opts[${#opts[@]}]="--suffix=${1}"
}
readonly -f __sgl_mk_dest__opt_B

############################################################
# @private
# @func __sgl_mk_dest__opt_b
# @use __sgl_mk_dest__opt_b BOOL CTRL
# @val BOOL  Must be a boolean (false=`0'|true=`1') that indicates whether CTRL
#            should be parsed.
# @val CTRL  Must be a backup control method from below options.
#   `none|off'      Never make backups (even if `--backup' is given).
#   `numbered|t'    Make numbered backups.
#   `existing|nil'  If numbered backups exist make numbered. Otherwise make simple.
#   `simple|never'  Always make simple backups.
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__opt_b()
{
  if [[ $1 -eq 0 ]]; then
    opts[${#opts[@]}]='--backup'
    return 0
  fi

  case "$2" in
    none|off)     ;;
    numbered|t)   ;;
    existing|nil) ;;
    simple|never) ;;
    *)
      _sgl_err VAL "invalid \`${FN}' \`${opt}' CTRL \`${2}'"
      ;;
  esac
  opts[${#opts[@]}]="--backup=${2}"
}
readonly -f __sgl_mk_dest__opt_b

############################################################
# @private
# @func __sgl_mk_dest__opt_d
# @use __sgl_mk_dest__opt_d VARS
# @val VAR   Must be a valid `KEY=VALUE' pair. The KEY must start with a character
#            matching `[a-zA-Z_]', can only contain `[a-zA-Z0-9_]', and must end
#            with `[a-zA-Z0-9]'. The VALUE must not contain a `,'.
# @val VARS  Must be a list of one or more VAR separated by `,'.
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__opt_d()
{
  local -r chars='^[a-zA-Z_][a-zA-Z0-9_]*$'
  local -r endchar='[a-zA-Z0-9]$'
  local var
  local key
  local path

  [[ -n "$1" ]] || _sgl_err VAL "missing \`${FN}' \`${opt}' VARS"

  while IFS= read -r -d ',' var; do
    if [[ ! "${var}" =~ = ]]; then
      _sgl_err VAL "missing \`${FN}' \`${opt}' VAR \`${var}' VALUE"
    fi
    key="${var%%=*}"
    path="${var#*=}"
    if [[ ! "${key}" =~ ${chars} ]] || [[ ! "${key}" =~ ${endchar} ]]; then
      _sgl_err VAL "invalid \`${FN}' \`${opt}' VAR \`${var}' KEY \`${key}'"
    fi
    vars[${#vars[@]}]="${key}"
    keys[${key}]='\$'"${key}"'\|\${'"${key}"'}' # regex `$KEY|${KEY}'
    paths[${key}]="$(printf '%s' "${path}" | ${sed} -e 's/[\/&]/\\&/g')"
  done <<EOF
${1},
EOF
}
readonly -f __sgl_mk_dest__opt_d

############################################################
# @private
# @func __sgl_mk_dest__opt_K
# @use __sgl_mk_dest__opt_K ATTRS
# @val ATTR   Must be a file attribute from below options.
#   `mode'
#   `ownership'
#   `timestamps'
#   `context'
#   `links'
#   `xattr'
#   `all'
# @val ATTRS  Must be a list of one or more ATTR separated by `,'.
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__opt_K()
{
  local attr

  [[ -n "$1" ]] || _sgl_err VAL "missing \`${FN}' \`${opt}' ATTRS"

  # check each ATTR
  while IFS= read -r -d ',' attr; do
    case "${attr}" in
      mode)       ;;
      ownership)  ;;
      timestamps) ;;
      context)    ;;
      links)      ;;
      xattr)      ;;
      all)        ;;
      *)
        _sgl_err VAL "invalid \`${FN}' \`${opt}' ATTR \`${attr}'"
        ;;
    esac
  done <<EOF
${1},
EOF

  opts[${#opts[@]}]="--no-preserve=${1}"
}
readonly -f __sgl_mk_dest__opt_K

############################################################
# @private
# @func __sgl_mk_dest__opt_k
# @use __sgl_mk_dest__opt_k BOOL ATTRS
# @val ATTR   Must be a file attribute from below options.
#   `mode'
#   `ownership'
#   `timestamps'
#   `context'
#   `links'
#   `xattr'
#   `all'
# @val ATTRS  Must be a list of one or more ATTR separated by `,'.
# @val BOOL  Must be a boolean (false=`0'|true=`1') that indicates whether ATTRS
#            should be parsed.
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__opt_k()
{
  local attr

  if [[ $1 -eq 0 ]]; then
    opts[${#opts[@]}]='--preserve'
    return 0
  fi

  [[ -n "$2" ]] || _sgl_err VAL "missing \`${FN}' \`${opt}' ATTRS"

  # check each ATTR
  while IFS= read -r -d ',' attr; do
    case "${attr}" in
      mode)       ;;
      ownership)  ;;
      timestamps) ;;
      context)    ;;
      links)      ;;
      xattr)      ;;
      all)        ;;
      *)
        _sgl_err VAL "invalid \`${FN}' \`${opt}' ATTR \`${attr}'"
        ;;
    esac
  done <<EOF
${2},
EOF

  opts[${#opts[@]}]="--preserve=${2}"
}
readonly -f __sgl_mk_dest__opt_k

############################################################
# @private
# @func __sgl_mk_dest__opt_m
# @use __sgl_mk_dest__opt_m MODE
# @val MODE  Must be a valid file mode.
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__opt_m()
{
  local -r lmode='^[ugoa]*([-+=]([rwxXst]+|[ugo]))+$'
  local -r omode='^[-+=]?[0-7]{1,4}$'

  [[ -n "$1" ]] || _sgl_err VAL "missing \`${FN}' \`${opt}' MODE"

  if [[ ! "$1" =~ ${lmode} ]] && [[ ! "$1" =~ ${omode} ]]; then
    _sgl_err VAL "invalid \`${FN}' \`${opt}' MODE \`${1}'"
  fi

  mode="$1"
}
readonly -f __sgl_mk_dest__opt_m

############################################################
# @private
# @func __sgl_mk_dest__opt_o
# @use __sgl_mk_dest__opt_o OWNER
# @val OWNER  Must be a valid USER[:GROUP].
# @return
#   0  PASS
# @exit-on-error
############################################################
__sgl_mk_dest__opt_o()
{
  [[ -n "$1" ]] || _sgl_err VAL "missing \`${FN}' \`${opt}' OWNER"

  if [[ "$1" =~ [[:space:]] ]]; then
    _sgl_err VAL "invalid space in \`${FN}' \`${opt}' OWNER \`${1}'"
  fi

  own="$1"
}
readonly -f __sgl_mk_dest__opt_o
