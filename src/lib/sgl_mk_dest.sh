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
# @func sgl_mk_dest
# @use sgl_mk_dest [...OPTION] ...SRC
# @opt -B|--backup-ext=EXT   Override the usual backup file extension.
# @opt -b|--backup[=CTRL]    Make a backup of each existing destination file.
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
# @val ATTRS  A comma-separated list of file attributes from below options.
#   `mode'
#   `ownership'
#   `timestamps'
#   `context'
#   `links'
#   `xattr'
#   `all'
# @val CTRL   A version control method to use for backups from below options.
#   `none|off'      Never make backups (even if `--backup' is given).
#   `numbered|t'    Make numbered backups.
#   `existing|nil'  If numbered backups exist make numbered. Otherwise make simple.
#   `simple|never'  Always make simple backups.
# @val DEST   Must be a valid path.
# @val EXT    An extension to append to the end of a backup file. The default is `~'.
# @val MODE   Must be a valid file mode.
# @val OWNER  Must be a valid USER[:GROUP].
# @val REGEX  Can be any string. Refer to bash test `=~' operator for more details.
# @val SRC    Must be a valid file path. File must also contain at least one
#             destination tag: `# @dest DEST'.
# @return
#   0  PASS
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
  local -a opts
  local -a vals
  local regex='/[^/]+/[^/]+$'
  local attr
  local mode
  local own
  local opt
  local val
  local src
  local dest
  local parent
  local tag
  local space

  # parse each argument
  _sgl_parse_args "${FN}" \
    '-B|--backup-ext'   1 \
    '-b|--backup'       2 \
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
        val="${_SGL_OPT_VALS[${i}]}"
        if [[ -z "${val}" ]] || [[ "${val}" =~ [[:space:]] ]]; then
          _sgl_err VAL "invalid \`${FN}' \`${opt}' EXT \`${val}'"
        fi
        opts[${#opts[@]}]="--suffix=${val}"
        ;;
      -b|--backup)
        if [[ ${_SGL_OPT_BOOL[${i}]} -eq 1 ]]; then
          val="${_SGL_OPT_VALS[${i}]}"
          case "${val}" in
            none|off)     ;;
            numbered|t)   ;;
            existing|nil) ;;
            simple|never) ;;
            *)
              _sgl_err VAL "invalid \`${FN}' CTRL \`${val}'"
              ;;
          esac
          opts[${#opts[@]}]="--backup=${val}"
        else
          opts[${#opts[@]}]='--backup'
        fi
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
        ${cat} <<'EOF'

  sgl_mk_dest [...OPTION] ...SRC

  Options:
    -B|--backup-ext=EXT   Override the usual backup file extension.
    -b|--backup[=CTRL]    Make a backup of each existing destination file.
    -F|--no-force         If destination exists do not overwrite it.
    -f|--force            If destination exists overwrite it.
    -H|--cmd-dereference  Follow command-line SRC symlinks.
    -h|-?|--help          Print help info and exit.
    -K|--no-keep=ATTRS    Do not preserve the ATTRS.
    -k|--keep[=ATTRS]     Keep the ATTRS (default= `mode,ownership,timestamps').
    -L|--dereference      Always follow SRC symlinks.
    -l|--link             Hard link files instead of copying.
    -m|--mode=MODE        Set the file mode for each destination.
    -n|--no-clobber       If destination exists do not overwrite.
    -o|--owner=OWNER      Set the file owner for each destination.
    -P|--no-dereference   Never follow SRC symlinks.
    -Q|--silent           Disable `stderr' and `stdout' outputs.
    -q|--quiet            Disable `stdout' output.
    -s|--symlink          Make symlinks instead of copying.
    -t|--test=REGEX       Test each DEST path against REGEX (uses bash `=~').
    -u|--update           Copy only when SRC is newer than DEST.
    -V|--verbose          Print exec status details.
    -v|--version          Print version info and exit.
    -w|--warn             If destination exists prompt before overwrite.
    -x|--one-file-system  Stay on this file system.
    -|--                  End the options.

  Values:
    ATTRS  A comma-separated list of file attributes from below options.
      `mode'
      `ownership'
      `timestamps'
      `context'
      `links'
      `xattr'
      `all'
    CTRL   A version control method to use for backups from below options.
      `none|off'      Never make backups (even if `--backup' is given).
      `numbered|t'    Make numbered backups.
      `existing|nil'  If numbered backups exist make numbered. Otherwise make simple.
      `simple|never'  Always make simple backups.
    DEST   Must be a valid path.
    EXT    An extension to append to the end of a backup file. The default is `~'.
    MODE   Must be a valid file mode.
    OWNER  Must be a valid USER[:GROUP].
    REGEX  Can be any string. Refer to bash test `=~' operator for more details.
    SRC    Must be a valid file path. File must also contain at least one
           destination tag: `# @dest DEST'.

EOF
        exit 0
        ;;
      -K|--no-keep)
        val="${_SGL_OPT_VALS[${i}]}"
        if [[ -z "${val}" ]] || [[ ! "${val}" =~ ^[a-z]+(,[a-z]+)*$ ]]; then
          _sgl_err VAL "invalid \`${FN}' \`${opt}' ATTRS \`${val}'"
        fi
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
"${val},"
EOF
        opts[${#opts[@]}]="--no-preserve=${val}"
        ;;
      -k|--keep)
        if [[ ${_SGL_OPT_BOOL[${i}]} -eq 1 ]]; then
          val="${_SGL_OPT_VALS[${i}]}"
          if [[ -z "${val}" ]] || [[ ! "${val}" =~ ^[a-z]+(,[a-z]+)*$ ]]; then
            _sgl_err VAL "invalid \`${FN}' \`${opt}' ATTRS \`${val}'"
          fi
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
"${val},"
EOF
          opts[${#opts[@]}]="--preserve=${val}"
        else
          opts[${#opts[@]}]='--preserve'
        fi
        ;;
      -L|--dereference)
        opts[${#opts[@]}]='-L'
        ;;
      -l|--link)
        opts[${#opts[@]}]='--link'
        ;;
      -m|--mode)
        val="${_SGL_OPT_VALS[${i}]}"
        if [[ -z "${val}" ]] || [[ "${val}" =~ [[:space:]] ]]; then
          _sgl_err VAL "invalid \`${FN}' \`${opt}' MODE \`${val}'"
        fi
        mode="${val}"
        ;;
      -n|--no-clobber)
        force=0
        opts[${#opts[@]}]='--no-clobber'
        ;;
      -o|--owner)
        val="${_SGL_OPT_VALS[${i}]}"
        if [[ -z "${val}" ]] || [[ "${val}" =~ [[:space:]] ]]; then
          _sgl_err VAL "invalid \`${FN}' \`${opt}' OWNER \`${val}'"
        fi
        own="${val}"
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

  # set grep and sed regexps
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
      dest="$(printf '%s' "${dest}" | ${sed} -e "s/${tag}//" -e "s/${space}//" \
        -e 's|\$HOME\|\${HOME}|'"${HOME}"'|')"
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
