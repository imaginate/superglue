# @dest $LIB/superglue/sgl_source
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @return
#   0  PASS
################################################################################

############################################################
# Note that `sgl_source' is automatically sourced on `superglue' start.
#
# @func sgl_source
# @use sgl_source [...OPTION] ...FUNC
# @opt -h|-?|--help  Print help info and exit.
# @opt -Q|--silent   Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet    Disable `stdout' output.
# @opt -v|--version  Print version info and exit.
# @opt -|--          End the options.
# @val FUNC  Must be one of the below `superglue' functions. The `sgl_' prefix
#            is optional, and the globstar, `*', may be used.
#   sgl_chk_cmd
#   sgl_chk_dir
#   sgl_chk_exit
#   sgl_chk_file
#   sgl_chk_uid
#   sgl_color
#   sgl_cp
#   sgl_err
#   sgl_mk_dest
#   sgl_parse_args
#   sgl_print
#   sgl_rm_dest
#   sgl_set_color
#   sgl_source
# @return
#   0  PASS
############################################################
sgl_source()
{
  local -r FN='sgl_source'
  local -i i
  local -i len
  local -i quiet=${SGL_QUIET}
  local -i silent=${SGL_SILENT}
  local file
  local func
  local opt
  local -a funcs

  [[ ${SGL_SILENT_PARENT} -eq 1 ]] && silent=1
  [[ ${SGL_QUIET_PARENT}  -eq 1 ]] && quiet=1

  # parse each argument
  _sgl_parse_args "${FN}" \
    '-h|-?|--help' 0 \
    '-Q|--silent'  0 \
    '-q|--quiet'   0 \
    '-v|--version' 0 \
    -- "$@"

  # parse each OPTION
  len=${#_SGL_OPTS[@]}
  for ((i=0; i<len; i++)); do
    opt="${_SGL_OPTS[${i}]}"
    case "${opt}" in
      -h|-\?|--help)
        _sgl_help sgl_source
        ;;
      -Q|--silent)
        silent=1
        ;;
      -q|--quiet)
        quiet=1
        ;;
      -v|--version)
        _sgl_version
        ;;
      *)
        _sgl_err SGL "invalid parsed \`${FN}' OPTION \`${opt}'"
        ;;
    esac
  done

  # catch missing FUNC
  if [[ ${#_SGL_VALS[@]} -eq 0 ]]; then
    [[ ${silent} -eq 1 ]] && _sgl_err VAL
    _sgl_err VAL "missing \`${FN}' FUNC"
  fi

  # parse each FUNC
  # build the funcs array
  funcs=()
  for func in "${_SGL_VALS[@]}"; do
    if [[ ! "${func}" =~ ^[a-z_\*]+$ ]]; then
      [[ ${silent} -eq 1 ]] && _sgl_err VAL
      _sgl_err VAL "invalid \`${FN}' \`${func}' FUNC"
    fi
    [[ "${func}" =~ ^sgl_ ]] || func="sgl_${func}"
    # parse FUNC pattern
    if [[ "${func}" =~ \* ]]; then
      for file in ${SGL_LIB}/${func}; do
        if [[ ! -f "${file}" ]]; then
          [[ ${silent} -eq 1 ]] && _sgl_err VAL
          _sgl_err VAL "invalid \`${FN}' \`${func}' FUNC"
        fi
        funcs[${#funcs[@]}]=${file##*/}
      done
    # parse FUNC function
    else
      file="${SGL_LIB}/${func}"
      if [[ ! -f "${file}" ]]; then
        [[ ${silent} -eq 1 ]] && _sgl_err VAL
        _sgl_err VAL "invalid \`${FN}' \`${func}' FUNC"
      fi
      funcs[${#funcs[@]}]=${func}
    fi
  done

  # source each FUNC
  for func in "${funcs[@]}"; do
    if ! declare -F ${func} > ${NIL}; then
      . "${SGL_LIB}/${func}"
    fi
    if [[ "${SGL_ALIAS}" == '1' ]]; then
      case ${func} in
        sgl_chk_cmd)
          chk_cmd() { sgl_chk_cmd "$@"; }
          ;;
        sgl_chk_dir)
          chk_dir() { sgl_chk_dir "$@"; }
          ;;
        sgl_chk_exit)
          chk_exit() { sgl_chk_exit "$@"; }
          ;;
        sgl_chk_file)
          chk_file() { sgl_chk_file "$@"; }
          ;;
        sgl_chk_uid)
          chk_uid() { sgl_chk_uid "$@"; }
          ;;
        sgl_color)
          color() { sgl_color "$@"; }
          ;;
        sgl_cp)
          cp() { sgl_cp "$@"; }
          ;;
        sgl_err)
          err() { sgl_err "$@"; }
          ;;
        sgl_mk_dest)
          mk_dest() { sgl_mk_dest "$@"; }
          ;;
        sgl_parse_args)
          parse_args() { sgl_parse_args "$@"; }
          ;;
        sgl_print)
          print() { sgl_print "$@"; }
          ;;
        sgl_rm_dest)
          rm_dest() { sgl_rm_dest "$@"; }
          ;;
        sgl_set_color)
          set_color() { sgl_set_color "$@"; }
          ;;
        sgl_source)
          source() { sgl_source "$@"; }
          ;;
      esac
    fi
  done
}
readonly -f sgl_source
