#!/bin/bash
#
# @dest /lib/superglue/sgl_cp
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl_source cp
# @return
#   0  PASS
################################################################################

############################################################
# @func sgl_cp
# @use sgl_cp [...OPTION] SRC DEST
# @use sgl_cp [...OPTION] ...SRC DEST_DIR
# @use sgl_cp [...OPTION] -d DEST_DIR ...SRC
# @opt -B|--backup-ext=EXT   Override the usual backup file extension.
# @opt -b|--backup[=CTRL]    Make a backup of each existing destination file.
# @opt -D|--no-dest-dir      Treat DEST as a normal file (not a DEST_DIR).
# @opt -d|--dest-dir=DIR     Copy each SRC into DIR.
# @opt -F|--no-force         If destination exists do not overwrite it.
# @opt -f|--force            If destination exists overwrite it.
# @opt -H|--cmd-dereference  Follow command-line SRC symlinks.
# @opt -h|--help             Print help info and exit.
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
# @opt -r|--recursive        Copy directories recursively.
# @opt -s|--symlink          Make symlinks instead of copying.
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
# @val DIR    Must be a valid directory path.
# @val EXT    An extension to append to the end of a backup file. The default is `~'.
# @val MODE   Must be a valid file mode.
# @val OWNER  Must be a valid USER[:GROUP].
# @val SRC    Must be a valid file path.
# @return
#   0  PASS
############################################################
sgl_cp()
{
  local -r FN='sgl_cp'
  local -i RT
  local -i i
  local -i len
  local -i force=0
  local -i target=0
  local -i quiet=${SGL_QUIET}
  local -i silent=${SGL_SILENT}
  local -a opts
  local -a dests
  local attr
  local mode
  local own
  local opt
  local val
  local src
  local dest

  # parse each argument
  _sgl_parse_args "${FN}" \
    '-B|--backup-ext'   1 \
    '-b|--backup'       2 \
    '-D|--no-dest-dir'  0 \
    '-d|--dest-dir'     1 \
    '-F|--no-force'     0 \
    '-f|--force'        0 \
    '-H|--cmd-dereference' 0 \
    '-h|--help'         0 \
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
    '-r|--recursive'    0 \
    '-s|--symlink'      0 \
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
      -D|--no-dest-dir)
        target=2
        dest=''
        opts[${#opts[@]}]='--no-target-directory'
        ;;
      -d|--dest-dir)
        target=1
        val="${_SGL_OPT_VALS[${i}]}"
        [[ -d "${val}" ]] || _sgl_err VAL "invalid \`${FN}' DEST_DIR \`${val}'"
        dest="${val}"
        opts[${#opts[@]}]="--target-directory=${val}"
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
      -h|--help)
        ${cat} <<'EOF'

  sgl_cp [...OPTION] SRC DEST
  sgl_cp [...OPTION] ...SRC DEST_DIR
  sgl_cp [...OPTION] -d DEST_DIR ...SRC

  Options:
    -B|--backup-ext=EXT   Override the usual backup file extension.
    -b|--backup[=CTRL]    Make a backup of each existing destination file.
    -D|--no-dest-dir      Treat DEST as a normal file (not a DEST_DIR).
    -d|--dest-dir=DIR     Copy each SRC into DIR.
    -F|--no-force         If destination exists do not overwrite it.
    -f|--force            If destination exists overwrite it.
    -H|--cmd-dereference  Follow command-line SRC symlinks.
    -h|--help             Print help info and exit.
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
    -r|--recursive        Copy directories recursively.
    -s|--symlink          Make symlinks instead of copying.
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
    DIR    Must be a valid directory path.
    EXT    An extension to append to the end of a backup file. The default is `~'.
    MODE   Must be a valid file mode.
    OWNER  Must be a valid USER[:GROUP].
    SRC    Must be a valid file path.

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
      -r|--recursive)
        opts[${#opts[@]}]='-R'
        ;;
      -s|--symlink)
        opts[${#opts[@]}]='--symbolic-link'
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

  # save number of SRC/DEST values
  len=${#_SGL_VALS[@]}

  # catch missing SRC
  [[ ${len} -gt 0 ]] || _sgl_err VAL "missing \`${FN}' SRC"

  # assign unknown target
  if [[ ${target} -eq 0 ]]; then
    [[ ${len} -gt 1 ]] || _sgl_err VAL "missing \`${FN}' DEST"
    if [[ ${len} -eq 2 ]] && [[ ! -d "${_SGL_VALS[1]}" ]]; then
      target=2
    else
      target=1
    fi
  fi

  # pass to correct handler
  case ${target} in

    # handle file-to-directory copy
    1)
      # parse DEST_DIR
      if [[ -z "${dest}" ]]; then
        len=$(( len - 1 ))
        dest="${_SGL_VALS[@]: -1:1}"
        [[ -d "${dest}" ]] || _sgl_err VAL "invalid \`${FN}' DEST_DIR \`${dest}'"
        opts[${#opts[@]}]="--target-directory=${dest}"
      fi

      # parse each SRC
      dests=()
      for src in "${_SGL_VALS[@]:0:${len}}"; do
        [[ -f "${src}" ]] || _sgl_err VAL "invalid \`${FN}' SRC \`${src}'"
        opts[${#opts[@]}]="${src}"
        val="${dest}/$(printf '%s' "${src}" | ${sed} -e 's|^.*/||')"
        if [[ -f "${val}" ]] && [[ ${force} -ne 1 ]]; then
          _sgl_err VAL "DEST \`${val}' already exists (use \`--force' to overwrite)"
        fi
        dests[${#dests[@]}]="${val}"
      done

      # copy files
      ${cp} "${opts[@]}"
      RT=$?
      if [[ ${RT} -ne 0 ]]; then
        _sgl_err CHLD "\`${cp}' in \`${FN}' exited with \`${RT}'"
      fi

      # set file modes
      if [[ -n "${mode}" ]]; then
        ${chmod} "${mode}" "${dests[@]}"
        RT=$?
        if [[ ${RT} -ne 0 ]]; then
          _sgl_err CHLD "\`${chmod}' in \`${FN}' exited with \`${RT}'"
        fi
      fi

      # set file owners
      if [[ -n "${own}" ]]; then
        ${chown} "${own}" "${dests[@]}"
        RT=$?
        if [[ ${RT} -ne 0 ]]; then
          _sgl_err CHLD "\`${chown}' in \`${FN}' exited with \`${RT}'"
        fi
      fi
      ;;

    # handle file-to-file copy
    2)
      # catch invalid SRC/DEST count
      [[ ${len} -gt 1 ]] || _sgl_err VAL "missing \`${FN}' DEST"
      [[ ${len} -eq 2 ]] || _sgl_err VAL "only 1 \`${FN} -D' SRC and DEST"

      # save SRC/DEST
      src="${_SGL_VALS[0]}"
      dest="${_SGL_VALS[1]}"

      # catch invalid SRC/DEST paths
      [[ -f "${src}"  ]] || _sgl_err VAL "invalid \`${FN}' SRC path \`${src}'"
      [[ -d "${dest}" ]] && _sgl_err VAL "existing \`${FN}' DEST dir \`${dest}'"
      if [[ -f "${dest}" ]] && [[ ${force} -ne 1 ]]; then
        _sgl_err VAL "DEST \`${dest}' already exists (use \`--force' to overwrite)"
      fi

      # copy files
      ${cp} "${opts[@]}" "${src}" "${dest}"
      RT=$?
      if [[ ${RT} -ne 0 ]]; then
        _sgl_err CHLD "\`${cp}' in \`${FN}' exited with \`${RT}'"
      fi

      # set file modes
      if [[ -n "${mode}" ]]; then
        ${chmod} "${mode}" "${dest}"
        RT=$?
        if [[ ${RT} -ne 0 ]]; then
          _sgl_err CHLD "\`${chmod}' in \`${FN}' exited with \`${RT}'"
        fi
      fi

      # set file owners
      if [[ -n "${own}" ]]; then
        ${chown} "${own}" "${dest}"
        RT=$?
        if [[ ${RT} -ne 0 ]]; then
          _sgl_err CHLD "\`${chown}' in \`${FN}' exited with \`${RT}'"
        fi
      fi
      ;;

    # catch bug
    *)
      _sgl_err SGL "invalid \`${FN}' \$target value \`${target}'"
      ;;
  esac
}
readonly -f sgl_cp
