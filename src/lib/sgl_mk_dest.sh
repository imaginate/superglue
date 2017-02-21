# @dest $LIB/superglue/sgl_mk_dest
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl_source mk_dest
# @return
#   0  PASS
################################################################################

_sgl_source chk_attrs chk_exit chk_tags err get_quiet get_silent get_tag \
  get_tags get_tmp get_verbose has_group has_tag has_user help ins_incl \
  ins_var is_ctrl is_dir is_file is_flat is_group is_mode is_owner is_path \
  is_read is_user parse_args parse_def parse_defs setup_defs version

############################################################
# @public
# @func sgl_mk_dest
# @use sgl_mk_dest [...OPTION] ...SRC
# @opt -B|--backup-ext=EXT   Override the default backup file extension, `~'.
# @opt -b|--backup[=CTRL]    Make a backup of each existing destination file.
# @opt -D|--defines=VARS     Define multiple VAR for any TAG VALUE to use.
# @opt -d|--define=VAR       Define one VAR for any TAG VALUE to use.
# @opt -E|--no-empty         Force SRC to contain at least one `dest' TAG (default).
# @opt -e|--empty            Allow SRC to not contain a `destination' TAG.
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
# @opt -N|--no-insert        Disable `set' TAG processing and inserts.
# @opt -n|--no-clobber       If destination exists do not overwrite.
# @opt -o|--owner=OWNER      Set the file owner for each destination.
# @opt -P|--no-dereference   Never follow SRC symlinks.
# @opt -Q|--silent           Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet            Disable `stdout' output.
# @opt -r|--recursive        If SRC is a directory recursively process directories.
# @opt -s|--symlink          Make symlinks instead of copying.
# @opt -T|--no-test          Disable REGEX testing for each DEST.
# @opt -t|--test=REGEX       Test each DEST path against REGEX (uses bash `=~').
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
# @val DEST   Must be a valid path. Can include defined VAR KEYs identified by a
#             leading `$' and optionally wrapped with curly brackets, `${KEY}'.
# @val EXT    Must be a valid file extension. No whitespace characters allowed.
# @val MODE   Must be a valid file mode. Symbolic and octal formats allowed.
#             See `man chmod' for more details about valid options.
# @val OWNER  Must be a valid USER and/or GROUP formatted as `[USER][:[GROUP]]'.
#             See `man chown' for more details about valid options.
# @val REGEX  Can be any string. Refer to bash test `=~' operator for more details.
# @val SRC    Must be a valid file or directory path. If SRC is a directory each
#             child file path is processed as a SRC. Each SRC file must contain at
#             least one `dest' TAG (unless `--empty' is used), can contain one
#             `mode', `owner', and `version' TAG, and can contain multiple `include'
#             or `set' TAG. Note that OPTION values take priority over TAG values.
# @val TAG    A TAG is defined within a SRC file's contents. It must be a one-line
#             comment formatted as `# @TAG VALUE'. Spacing is optional except
#             between TAG and VALUE. The TAG must be one of the options below.
#   `dest|destination'  Formatted `# @dest DEST'.
#   `incl|include'      Formatted `# @incl FILE'.
#   `mod|mode'          Formatted `# @mod MODE'.
#   `own|owner'         Formatted `# @own OWNER'.
#   `set|var|variable'  Formatted `# @set KEY=VALUE'.
#   `vers|version'      Formatted `# @vers VERSION'.
# @val VAR    Must be a valid `KEY=VALUE' pair. The KEY must start with a character
#             matching `[a-zA-Z_]', only contain characters `[a-zA-Z0-9_]', and end
#             with a character matching `[a-zA-Z0-9]'.
# @val VARS   Must be a list of one or more VAR separated by a `,'.
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
sgl_mk_dest()
{
  local -r FN='sgl_mk_dest'
  local -i i=0
  local -i bkup=0
  local -i deep=0
  local -i test=1
  local -i empty=0
  local -i force=0
  local -i insert=1
  local -i include=1
  local -i quiet=$(_sgl_get_quiet PRT)
  local -i silent=$(_sgl_get_silent PRT)
  local -i verbose=$(_sgl_get_verbose)
  local -a files=()
  local -a dirs=()
  local -a opts=()
  local OWNER
  local MODE
  local src
  local tmp
  local dir
  local opt
  local val
  local dest
  local file
  local mode=''
  local owner=''
  local bkext=''
  local regex='/[^/]+/[^/]+$'

  _sgl_parse_args ${FN} \
    '-B|--backup-ext'      1 \
    '-b|--backup'          2 \
    '-D|--defines'         1 \
    '-d|--define'          1 \
    '-E|--no-empty'        0 \
    '-e|--empty'           0 \
    '-F|--no-force'        0 \
    '-f|--force'           0 \
    '-H|--cmd-dereference' 0 \
    '-h|-?|--help'         0 \
    '-I|--no-include'      0 \
    '-K|--no-keep|--no-preserve' 1 \
    '-k|--keep|--preserve' 2 \
    '-L|--dereference'     0 \
    '-l|--link'            0 \
    '-m|--mod|--mode'      1 \
    '-N|--no-insert'       0 \
    '-n|--no-clobber'      0 \
    '-o|--own|--owner'     1 \
    '-P|--no-dereference'  0 \
    '-Q|--silent'          0 \
    '-q|--quiet'           0 \
    '-r|--recursive'       0 \
    '-s|--symlink'         0 \
    '-T|--no-test'         0 \
    '-t|--test'            1 \
    '-u|--update'          0 \
    '-V|--verbose'         0 \
    '-v|--version'         0 \
    '-w|--warn'            0 \
    '-x|--one-file-system' 0 \
    -- "${@}"

  _sgl_setup_defs

  if [[ ${#_SGL_OPTS[@]} -gt 0 ]]; then
    for opt in "${_SGL_OPTS[@]}"; then
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
              _sgl_err VAL "invalid \`${FN}' \`${opt}' CTRL \`${val}'"
            fi
            opts[${#opts[@]}]="--backup=${val}"
          else
            opts[${#opts[@]}]='--backup'
          fi
          bkup=1
          ;;
        -D|--defines)
          _sgl_parse_defs "${FN}" "${opt}" "${_SGL_OPT_VALS[${i}]}"
          ;;
        -d|--define)
          _sgl_parse_def "${FN}" "${opt}" "${_SGL_OPT_VALS[${i}]}"
          ;;
        -E|--no-empty)
          empty=0
          ;;
        -e|--empty)
          empty=1
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
        -I|--no-include)
          include=0
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
        -N|--no-insert)
          insert=0
          ;;
        -n|--no-clobber)
          force=0
          opts[${#opts[@]}]='--no-clobber'
          ;;
        -o|--own|--owner)
          owner="${_SGL_OPT_VALS[${i}]}"
          if ! _sgl_is_owner "${owner}"; then
            _sgl_err VAL "invalid \`${FN}' \`${opt}' OWNER \`${owner}'"
          fi
          if _sgl_has_user "${owner}" && ! _sgl_is_user "${owner%:*}"; then
            _sgl_err VAL "invalid \`${FN}' \`${opt}' USER \`${owner%:*}'"
          fi
          if _sgl_has_group "${owner}" && ! _sgl_is_group "${owner#*:}"; then
            _sgl_err VAL "invalid \`${FN}' \`${opt}' GROUP \`${owner#*:}'"
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
          deep=1
          ;;
        -s|--symlink)
          opts[${#opts[@]}]='--symbolic-link'
          ;;
        -T|--no-test)
          test=1
          ;;
        -t|--test)
          regex="${_SGL_OPT_VALS[${i}]}"
          test=1
          ;;
        -u|--update)
          opts[${#opts[@]}]='--update'
          ;;
        -V|--verbose)
          verbose=1
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

  if [[ -n "${mode}" ]]; then
    MODE="${mode}"
  fi
  local -r MODE

  if [[ -n "${owner}" ]]; then
    OWNER="${owner}"
  fi
  local -r OWNER

  if [[ -z "${regex}" ]]; then
    test=0
  fi

  if [[ ${#_SGL_VALS[@]} -eq 0 ]]; then
    _sgl_err VAL "missing \`${FN}' SRC"
  fi

  # check each SRC path
  for val in "${_SGL_VALS[@]}"; do
    if _sgl_is_dir "${val}"; then
      dirs[${#dirs[@]}]="${val}"
    elif _sgl_is_file "${val}"; then
      files[${#files[@]}]="${val}"
    else
      _sgl_err VAL "invalid \`${FN}' SRC file path \`${val}'"
    fi
  done

  # handle each SRC directory
  i=0
  while [[ ${i} -lt ${#dirs[@]} ]]; do
    dir="${dirs[${i}]}"
    for val in "${dir}"/*; do
      if _sgl_is_dir "${val}"; then
        if [[ ${deep} -eq 1 ]]; then
          dirs[${#dirs[@]}]="${val}"
        fi
      elif _sgl_is_file "${val}"; then
        files[${#files[@]}]="${val}"
      fi
    done
    i=$(( i + 1 ))
  done

  # return if SRC directory has no files
  if [[ ${#files[@]} -eq 0 ]]; then
    return 0
  fi

  # parse each SRC file path
  for src in "${files[@]}"; do

    # check each SRC file path
    if ! _sgl_is_read "${src}"; then
      _sgl_err AUTH "unreadable \`${FN}' SRC file path \`${src}'"
    fi
    if ! _sgl_has_tag "${src}" DEST; then
      if [[ ${empty} -eq 1 ]]; then
        continue
      fi
      _sgl_err VAL "missing \`dest' TAG for \`${FN}' SRC \`${src}'"
    fi
    _sgl_chk_tags ${FN} "${src}" DEST INCL MODE OWN SET VERS

    # parse file mode TAG
    if _sgl_has_tag "${src}" MODE; then
      mode="$(_sgl_get_tag "${src}" MODE)"
      if ! _sgl_is_mode "${mode}"; then
        _sgl_err VAL "invalid \`${FN}' SRC \`${src}' MODE \`${mode}'"
      fi
    fi
    if [[ -n "${MODE}" ]]; then
      mode="${MODE}"
    fi

    # parse file owner TAG
    if _sgl_has_tag "${src}" OWN; then
      owner="$(_sgl_get_tag "${src}" OWN)"
      if ! _sgl_is_owner "${owner}"; then
        _sgl_err VAL "invalid \`${FN}' SRC \`${src}' OWNER \`${owner}'"
      fi
      if _sgl_has_user "${owner}" && ! _sgl_is_user "${owner%:*}"; then
        _sgl_err VAL "invalid \`${FN}' SRC \`${src}' USER \`${owner%:*}'"
      fi
      if _sgl_has_group "${owner}" && ! _sgl_is_group "${owner#*:}"; then
        _sgl_err VAL "invalid \`${FN}' SRC \`${src}' GROUP \`${owner#*:}'"
      fi
    fi
    if [[ -n "${OWNER}" ]]; then
      owner="${OWNER}"
    fi

    # copy SRC to temporary file path
    tmp="$(_sgl_get_tmp dest)"
    ${cp} -T -- "${src}" "${tmp}"
    _sgl_chk_exit ${?} ${cp} -T -- "${src}" "${tmp}"

    if [[ ${insert} -eq 1 ]]; then
      _sgl_ins_var "${tmp}"
    fi

    if [[ ${include} -eq 1 ]]; then
      _sgl_ins_incl ${FN} ${insert} "${tmp}"
    fi

    # parse each dest TAG
    while IFS= read -r dest; do

      if [[ ${test} -eq 1 ]] && [[ ! "${dest}" =~ ${regex} ]]; then
        dest="DEST \`${dest}' in SRC \`${src}'"
        _sgl_err VAL "\`${FN}' ${dest} failed the REGEX \`${regex}' test"
      fi

      dir="${dest%/*}"
      if [[ -n "${dir}" ]] && ! _sgl_is_dir "${dir}"; then
        dest="DEST \`${dest}' in SRC \`${src}'"
        _sgl_err VAL "invalid \`${FN}' parent path \`${dir}' for ${dest}"
      fi

      if ! _sgl_is_file "${dest}"; then
        if _sgl_is_dir "${dest}"; then
          dest="DEST \`${dest}' in SRC \`${src}'"
          _sgl_err VAL "a directory already exists for \`${FN}' ${dest}"
        elif _sgl_is_path "${dest}"; then
          dest="DEST \`${dest}' in SRC \`${src}'"
          _sgl_err VAL "a non-file already exists for \`${FN}' ${dest}"
        fi
      elif [[ ${force} -ne 1 ]]; then
        dest="\`${FN}' DEST \`${dest}' in SRC \`${src}'"
        val="(use \`--force' to overwrite)"
        _sgl_err VAL "a file already exists for ${dest} ${val}"
      fi

      ${cp} "${opts[@]}" -T -- "${tmp}" "${dest}"
      _sgl_chk_exit ${?} ${cp} "${opts[@]}" -T -- "${tmp}" "${dest}"

      if [[ -n "${mode}" ]]; then
        ${chmod} -- "${mode}" "${dest}"
        _sgl_chk_exit ${?} ${chmod} -- "${mode}" "${dest}"
      fi

      if [[ -n "${owner}" ]]; then
        ${chown} -- "${owner}" "${dest}"
        _sgl_chk_exit ${?} ${chown} -- "${owner}" "${dest}"
      fi

    done <<< "$(_sgl_get_tags "${src}" DEST)"
  done
  return 0
}
readonly -f sgl_mk_dest
