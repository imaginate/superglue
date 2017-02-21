# @dest $LIB/superglue/sgl_rm_dest
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl_source rm_dest
# @return
#   0  PASS
################################################################################

_sgl_source chk_exit chk_tag err get_quiet get_silent get_tags get_verbose \
  has_tag help is_dir is_file is_path is_read parse_args parse_def parse_defs \
  setup_defs version

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
# @opt -T|--no-test          Disable REGEX testing for each DEST (default).
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
#             matching `[a-zA-Z_]', can only contain `[a-zA-Z0-9_]', and must end
#             with `[a-zA-Z0-9]'. The VALUE must not contain a `,'.
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
sgl_rm_dest()
{
  local -r FN='sgl_rm_dest'
  local -i i=0
  local -i deep=0
  local -i test=0
  local -i empty=0
  local -i force=0
  local -i quiet=$(_sgl_get_quiet PRT)
  local -i silent=$(_sgl_get_silent PRT)
  local -i verbose=$(_sgl_get_verbose)
  local -a files=()
  local -a dirs=()
  local -a opts=()
  local src
  local dir
  local opt
  local val
  local dest
  local file
  local regex='/[^/]+/[^/]+$'

  _sgl_parse_args ${FN} \
    '-D|--defines'         1 \
    '-d|--define'          1 \
    '-E|--no-empty'        0 \
    '-e|--empty'           0 \
    '-F|--no-force'        0 \
    '-f|--force'           0 \
    '-h|-?|--help'         0 \
    '-Q|--silent'          0 \
    '-q|--quiet'           0 \
    '-r|--recursive'       0 \
    '-T|--no-test'         0 \
    '-t|--test'            1 \
    '-V|--verbose'         0 \
    '-v|--version'         0 \
    '-x|--one-file-system' 0 \
    -- "${@}"

  _sgl_setup_defs

  if [[ ${#_SGL_OPTS[@]} -gt 0 ]]; then
    for opt in "${_SGL_OPTS[@]}"; then
      case "${opt}" in
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
          opts[${#opts[@]}]='-i'
          ;;
        -f|--force)
          force=1
          opts[${#opts[@]}]='-f'
          ;;
        -h|-\?|--help)
          _sgl_help ${FN}
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
        -T|--no-test)
          test=0
          ;;
        -t|--test)
          regex="${_SGL_OPT_VALS[${i}]}"
          test=1
          ;;
        -V|--verbose)
          verbose=1
          opts[${#opts[@]}]='--verbose'
          ;;
        -v|--version)
          _sgl_version
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
    _sgl_chk_tag ${FN} "${src}" DEST

    # parse each dest TAG
    while IFS= read -r dest; do

      if [[ ${test} -eq 1 ]] && [[ ! "${dest}" =~ ${regex} ]]; then
        dest="DEST \`${dest}' in SRC \`${src}'"
        _sgl_err VAL "\`${FN}' ${dest} failed the REGEX \`${regex}' test"
      fi

      if [[ "${dest:0:1}" != '/' ]]; then
        dest="${src%/*}/${dest}"
      fi

      if ! _sgl_is_file "${dest}"; then
        if _sgl_is_dir "${dest}"; then
          dest="DEST \`${dest}' in SRC \`${src}'"
          _sgl_err VAL "a directory already exists for \`${FN}' ${dest}"
        elif _sgl_is_path "${dest}"; then
          dest="DEST \`${dest}' in SRC \`${src}'"
          _sgl_err VAL "a non-file already exists for \`${FN}' ${dest}"
        fi
      fi

      ${rm} "${opts[@]}" -- "${dest}"
      _sgl_chk_exit ${?} ${rm} "${opts[@]}" -- "${dest}"

    done <<< "$(_sgl_get_tags "${src}" DEST)"
  done
  return 0
}
readonly -f sgl_rm_dest
