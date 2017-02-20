# @dest $LIB/superglue/sgl_cp
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl_source cp
# @return
#   0  PASS
################################################################################

_sgl_source chk_attrs chk_exit err get_quiet get_silent has_group has_user \
  help is_ctrl is_dir is_file is_flat is_group is_mode is_owner is_user \
  parse_args version

############################################################
# @public
# @func sgl_cp
# @use sgl_cp [...OPTION] SRC DEST
# @use sgl_cp [...OPTION] ...SRC DIR
# @use sgl_cp [...OPTION] -d DIR ...SRC
# @opt -B|--backup-ext=EXT   Override the default backup file extension, `~'.
# @opt -b|--backup[=CTRL]    Make a backup of each existing destination file.
# @opt -D|--no-dest-dir      Treat DEST as a normal file (not a DIR).
# @opt -d|--dest-dir=DIR     Copy each SRC into DIR.
# @opt -F|--no-force         If destination exists do not overwrite it.
# @opt -f|--force            If destination exists overwrite it.
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
# @opt -r|--recursive        Copy directories recursively.
# @opt -s|--symlink          Make symlinks instead of copying.
# @opt -T|--no-target-dir    Treat DEST as a normal file (not a DIR).
# @opt -t|--target-dir=DIR   Copy each SRC into DIR.
# @opt -u|--update           Copy only when SRC is newer than DEST.
# @opt -V|--verbose          Print exec status details.
# @opt -v|--version          Print version info and exit.
# @opt -w|--warn             If destination exists prompt before overwrite.
# @opt -x|--one-file-system  Stay on this file system.
# @opt -|--                  End the options.
# @val ATTR   Must be a file attribute from the below options.
#   `mode'
#   `ownership'
#   `timestamps'
#   `context'
#   `links'
#   `xattr'
#   `all'
# @val ATTRS  Must be a list of one or more ATTR separated by a `,'.
# @val CTRL   Must be a backup control method from the below options.
#   `none|off'      Never make backups (even if `--backup' is given).
#   `numbered|t'    Make numbered backups.
#   `existing|nil'  Make numbered backups if they exist. Otherwise make simple.
#   `simple|never'  Always make simple backups.
# @val DEST   Must be a valid file system path.
# @val DIR    Must be a valid directory path.
# @val EXT    Must be a valid file extension. No whitespace characters allowed.
# @val MODE   Must be a valid file mode. Symbolic and octal formats allowed.
#             See `man chmod' for more details about valid options.
# @val OWNER  Must be a valid USER and/or GROUP formatted as `[USER][:[GROUP]]'.
#             See `man chown' for more details about valid options.
# @val SRC    Must be a valid file system path.
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
sgl_cp()
{
  local -r FN='sgl_cp'
  local -i i=0
  local -i len=0
  local -i bkup=0
  local -i force=0
  local -i target=0
  local -i quiet=$(_sgl_get_quiet PRT)
  local -i silent=$(_sgl_get_silent PRT)
  local -a opts=()
  local bkext
  local mode
  local own
  local opt
  local val
  local src
  local dest

  # parse each argument
  _sgl_parse_args ${FN} \
    '-B|--backup-ext'      1 \
    '-b|--backup'          2 \
    '-D|--no-dest-dir'     0 \
    '-d|--dest-dir'        1 \
    '-F|--no-force'        0 \
    '-f|--force'           0 \
    '-H|--cmd-dereference' 0 \
    '-h|-?|--help'         0 \
    '-K|--no-keep|--no-preserve' 1 \
    '-k|--keep|--preserve' 2 \
    '-L|--dereference'     0 \
    '-l|--link'            0 \
    '-m|--mod|--mode'      1 \
    '-n|--no-clobber'      0 \
    '-o|--own|--owner'     1 \
    '-P|--no-dereference'  0 \
    '-Q|--silent'          0 \
    '-q|--quiet'           0 \
    '-r|--recursive'       0 \
    '-T|--no-target-dir|--no-target-directory' 0 \
    '-t|--target-dir|--target-directory' 1 \
    '-s|--symlink'         0 \
    '-u|--update'          0 \
    '-V|--verbose'         0 \
    '-v|--version'         0 \
    '-w|--warn'            0 \
    '-x|--one-file-system' 0 \
    -- "${@}"

  # parse each OPTION
  if [[ ${#_SGL_OPTS[@]} -gt 0 ]]; then
    for opt in "${_SGL_OPTS[@]}"; do
      case "${opt}" in
        -B|--backup-ext)
          bkext="${_SGL_OPT_VALS[${i}]}"
          if ! _sgl_is_flat "${bkext}"; then
            _sgl_err VAL "invalid \`${FN}' \`${opt}' EXT \`${bkext}'"
          fi
          opts[${#opts[@]}]="--suffix=${bkext}"
          ;;
        -b|--backup)
          if [[ ${_SGL_OPT_BOOL[${i}]} -eq 1 ]]; then
            val="${_SGL_OPT_VALS[${i}]}"
            if ! _sgl_is_ctrl "${val}"; then
              _sgl_err VAL "invalid \`${FN}' CTRL \`${val}'"
            fi
            opts[${#opts[@]}]="--backup=${val}"
          else
            opts[${#opts[@]}]='--backup'
          fi
          bkup=1
          ;;
        -D|--no-dest-dir)
          target=2
          dest=''
          opts[${#opts[@]}]='-T'
          ;;
        -d|--dest-dir)
          target=1
          dest="${_SGL_OPT_VALS[${i}]}"
          if ! _sgl_is_dir "${dest}"; then
            _sgl_err VAL "invalid \`${FN}' DIR \`${dest}'"
          fi
          opts[${#opts[@]}]='-t'
          opts[${#opts[@]}]="${dest}"
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
          _sgl_help ${FN}
          ;;
        -K|--no-keep|--no-preserve)
          val="${_SGL_OPT_VALS[${i}]}"
          opts[${#opts[@]}]="--no-preserve=${val}"
          _sgl_chk_attrs "${FN}" "${opt}" "${val}"
          ;;
        -k|--keep|--preserve)
          if [[ ${_SGL_OPT_BOOL[${i}]} -eq 1 ]]; then
            val="${_SGL_OPT_VALS[${i}]}"
            opts[${#opts[@]}]="--preserve=${val}"
            _sgl_chk_attrs "${FN}" "${opt}" "${val}"
          else
            opts[${#opts[@]}]='--preserve=mode,ownership,timestamps'
          fi
          ;;
        -L|--dereference)
          opts[${#opts[@]}]='-L'
          ;;
        -l|--link)
          opts[${#opts[@]}]='--link'
          ;;
        -m|--mod|--mode)
          mode="${_SGL_OPT_VALS[${i}]}"
          if ! _sgl_is_mode "${mode}"; then
            _sgl_err VAL "invalid \`${FN}' \`${opt}' MODE \`${mode}'"
          fi
          ;;
        -n|--no-clobber)
          force=0
          opts[${#opts[@]}]='--no-clobber'
          ;;
        -o|--own|--owner)
          own="${_SGL_OPT_VALS[${i}]}"
          if ! _sgl_is_owner "${own}"; then
            _sgl_err VAL "invalid \`${FN}' \`${opt}' OWNER \`${own}'"
          fi
          if _sgl_has_user "${own}" && ! _sgl_is_user "${own%:*}"; then
            _sgl_err VAL "invalid \`${FN}' \`${opt}' USER \`${own%:*}'"
          fi
          if _sgl_has_group "${own}" && ! _sgl_is_group "${own#*:}"; then
            _sgl_err VAL "invalid \`${FN}' \`${opt}' GROUP \`${own#*:}'"
          fi
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
        -T|--no-target-dir|--no-target-directory)
          target=2
          dest=''
          opts[${#opts[@]}]='-T'
          ;;
        -t|--target-dir|--target-directory)
          target=1
          dest="${_SGL_OPT_VALS[${i}]}"
          if ! _sgl_is_dir "${dest}"; then
            _sgl_err VAL "invalid \`${FN}' DIR \`${dest}'"
          fi
          opts[${#opts[@]}]='-t'
          opts[${#opts[@]}]="${dest}"
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
      i=$(( i + 1 ))
    done
  fi

  if [[ ${bkup} -eq 1 ]] && [[ -z "${bkext}" ]]; then
    opts[${#opts[@]}]='--suffix=~'
  fi

  # save number of SRC/DEST values
  len=${#_SGL_VALS[@]}

  # catch missing SRC
  if [[ ${len} -eq 0 ]]; then
    _sgl_err VAL "missing \`${FN}' SRC"
  fi

  # assign unknown target
  if [[ ${target} -eq 0 ]]; then
    if [[ ${len} -eq 1 ]]; then
      _sgl_err VAL "missing \`${FN}' DEST"
    fi
    if [[ ${len} -eq 2 ]] && ! _sgl_is_dir "${_SGL_VALS[1]}"; then
      target=2
    else
      target=1
    fi
  fi

  # pass to correct handler
  case ${target} in

    # handle file-to-directory copy
    1)
      # parse DIR
      if [[ -z "${dest}" ]]; then
        len=$(( len - 1 ))
        dest="${_SGL_VALS[@]: -1:1}"
        if ! _sgl_is_dir "${dest}"; then
          _sgl_err VAL "invalid \`${FN}' DIR \`${dest}'"
        fi
        opts[${#opts[@]}]='-t'
        opts[${#opts[@]}]="${dest}"
      fi

      # parse each SRC
      local -a dests=()
      opts[${#opts[@]}]='--'
      for src in "${_SGL_VALS[@]:0:${len}}"; do
        if ! _sgl_is_file "${src}"; then
          _sgl_err VAL "invalid \`${FN}' SRC \`${src}'"
        fi
        opts[${#opts[@]}]="${src}"
        val="${dest}/${src##*/}"
        if _sgl_is_file "${val}" && [[ ${force} -ne 1 ]]; then
          val="DEST \`${val}' already exists"
          _sgl_err VAL "${val} (use \`--force' to overwrite)"
        fi
        dests[${#dests[@]}]="${val}"
      done

      # copy files
      ${cp} "${opts[@]}"
      _sgl_chk_exit ${?} ${cp} "${opts[@]}"

      # set file modes
      if [[ -n "${mode}" ]]; then
        ${chmod} -- "${mode}" "${dests[@]}"
        _sgl_chk_exit ${?} ${chmod} -- "${mode}" "${dests[@]}"
      fi

      # set file owners
      if [[ -n "${own}" ]]; then
        ${chown} -- "${own}" "${dests[@]}"
        _sgl_chk_exit ${?} ${chown} -- "${own}" "${dests[@]}"
      fi
      ;;

    # handle file-to-file copy
    2)
      # catch invalid SRC/DEST count
      if [[ ${len} -eq 1 ]]; then
        _sgl_err VAL "missing \`${FN}' DEST"
      fi
      if [[ ${len} -ne 2 ]]; then
        _sgl_err VAL "only 1 \`${FN} -D' SRC and DEST"
      fi

      # save SRC/DEST
      src="${_SGL_VALS[0]}"
      dest="${_SGL_VALS[1]}"

      # catch invalid SRC/DEST paths
      if ! _sgl_is_file "${src}"; then
        _sgl_err VAL "invalid \`${FN}' SRC path \`${src}'"
      fi
      if _sgl_is_dir "${dest}"; then
        _sgl_err VAL "existing \`${FN}' DEST dir \`${dest}'"
      fi
      if _sgl_is_file "${dest}" && [[ ${force} -ne 1 ]]; then
        dest="DEST \`${dest}' already exists"
        _sgl_err VAL "${dest} (use \`--force' to overwrite)"
      fi

      # copy files
      ${cp} "${opts[@]}" -- "${src}" "${dest}"
      _sgl_chk_exit ${?} ${cp} "${opts[@]}" -- "${src}" "${dest}"

      # set file modes
      if [[ -n "${mode}" ]]; then
        ${chmod} -- "${mode}" "${dest}"
        _sgl_chk_exit ${?} ${chmod} -- "${mode}" "${dest}"
      fi

      # set file owners
      if [[ -n "${own}" ]]; then
        ${chown} -- "${own}" "${dest}"
        _sgl_chk_exit ${?} ${chown} -- "${own}" "${dest}"
      fi
      ;;

    # catch bug
    *)
      _sgl_err SGL "invalid \`${FN}' \$target value \`${target}'"
      ;;
  esac
  return 0
}
readonly -f sgl_cp
