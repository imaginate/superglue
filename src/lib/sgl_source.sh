# @dest $LIB/superglue/sgl_source
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @return
#   0  PASS
################################################################################

_sgl_source chk_exit err get_alias get_quiet get_silent help is_set match_func \
  parse_args prefix version

############################################################
# Note that `sgl_source' is automatically sourced on `superglue' start.
#
# @public
# @func sgl_source
# @use sgl_source [...OPTION] ...FUNC
# @opt -A|--no-alias  Disable FUNC aliases without `sgl_' prefix (default).
# @opt -a|--alias     Enable FUNC aliases without `sgl_' prefix.
# @opt -h|-?|--help   Print help info and exit.
# @opt -Q|--silent    Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet     Disable `stdout' output.
# @opt -v|--version   Print version info and exit.
# @opt -|--           End the options.
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
# @exit-on-error
#   1  ERR   An unknown error.
#   2  OPT   An invalid option.
#   3  VAL   An invalid or missing value.
#   4  AUTH  A permissions error.
#   5  DPND  A dependency error.
#   6  CHLD  A child process exited unsuccessfully.
#   7  SGL   A `superglue' script error.
############################################################
sgl_source()
{
  local -r FN='sgl_source'
  local -i alias=$(_sgl_get_alias)
  local -i quiet=$(_sgl_get_quiet PRT)
  local -i silent=$(_sgl_get_silent PRT)
  local -a funcs=()
  local func
  local patt
  local opt
  local fn

  # parse each argument
  _sgl_parse_args ${FN} \
    '-A|--no-alias' 0 \
    '-a|--alias'    0 \
    '-h|-?|--help'  0 \
    '-Q|--silent'   0 \
    '-q|--quiet'    0 \
    '-v|--version'  0 \
    -- "${@}"

  # parse each OPTION
  if [[ ${#_SGL_OPTS[@]} -gt 0 ]]; then
    for opt in "${_SGL_OPTS[@]}"; do
      case "${opt}" in
        -A|--no-alias)
          alias=0
          ;;
        -a|--alias)
          alias=1
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
        -v|--version)
          _sgl_version
          ;;
        *)
          _sgl_err SGL "invalid parsed \`${FN}' OPTION \`${opt}'"
          ;;
      esac
    done
  fi

  # catch missing FUNC
  if [[ ${#_SGL_VALS[@]} -eq 0 ]]; then
    _sgl_err VAL "missing \`${FN}' FUNC"
  fi

  # parse each FUNC
  # build the funcs array
  for func in "${_SGL_VALS[@]}"; do
    if [[ ! "${func}" =~ ^[a-z_\*]+$ ]]; then
      _sgl_err VAL "invalid \`${FN}' FUNC \`${func}'"
    fi
    func="$(_sgl_prefix "${func}")"
    if ! _sgl_match_func "${func}"; then
      _sgl_err VAL "invalid \`${FN}' FUNC \`${func}'"
    fi
    # parse FUNC pattern
    if [[ "${func}" =~ \* ]]; then
      patt="^$(printf '%s' "${func}" | ${sed} -e 's/\*/[a-z_]*/g')\$"
      for fn in "${SGL_FUNCS[@]}"; do
        if [[ "${fn}" =~ ${patt} ]]; then
          funcs[${#funcs[@]}]="${fn}"
        fi
      done
    # parse FUNC function
    else
      funcs[${#funcs[@]}]="${func}"
    fi
  done

  # source each FUNC
  for func in "${funcs[@]}"; do
    if ! _sgl_is_set "${func}"; then
      . "${SGL_LIB}/${func}"
      _sgl_chk_exit ${?} '.' "${SGL_LIB}/${func}"
    fi
    if [[ ${alias} -eq 1 ]]; then
      case "${func}" in
        sgl_chk_cmd)    chk_cmd()    { sgl_chk_cmd    "${@}"; } ;;
        sgl_chk_dir)    chk_dir()    { sgl_chk_dir    "${@}"; } ;;
        sgl_chk_exit)   chk_exit()   { sgl_chk_exit   "${@}"; } ;;
        sgl_chk_file)   chk_file()   { sgl_chk_file   "${@}"; } ;;
        sgl_chk_uid)    chk_uid()    { sgl_chk_uid    "${@}"; } ;;
        sgl_color)      color()      { sgl_color      "${@}"; } ;;
        sgl_cp)         cp()         { sgl_cp         "${@}"; } ;;
        sgl_err)        err()        { sgl_err        "${@}"; } ;;
        sgl_mk_dest)    mk_dest()    { sgl_mk_dest    "${@}"; } ;;
        sgl_parse_args) parse_args() { sgl_parse_args "${@}"; } ;;
        sgl_print)      print()      { sgl_print      "${@}"; } ;;
        sgl_rm_dest)    rm_dest()    { sgl_rm_dest    "${@}"; } ;;
        sgl_set_color)  set_color()  { sgl_set_color  "${@}"; } ;;
        sgl_source)     source()     { sgl_source     "${@}"; } ;;
      esac
    fi
  done

  return 0
}
readonly -f sgl_source
