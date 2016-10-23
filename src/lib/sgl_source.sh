#!/bin/bash
#
# @dest /lib/superglue/sgl_source
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use . /lib/superglue/sgl_source
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
#   sgl_set_color
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
  [[ ${#_SGL_VALS[@]} -gt 0 ]] || _sgl_err VAL "missing \`${FN}' FUNC"

  # parse each FUNC
  for func in "${_SGL_VALS[@]}"; do
    if [[ ! "${func}" =~ ^[a-z_\*]+$ ]]; then
      _sgl_err VAL "invalid \`${FN}' \`${func}' FUNC"
    fi
    [[ "${func}" =~ ^sgl_ ]] || func="sgl_${func}"

    # handle FUNC pattern
    if [[ "${func}" =~ \* ]]; then
      for file in ${SGL_LIB}/${func}; do
        [[ -f "${file}" ]] || _sgl_err VAL "invalid \`${FN}' \`${func}' FUNC"
        func=$(printf '%s' "${file}" | ${sed} -e "s|^${SGL_LIB}/||")
        if declare -F ${func} > ${NIL}; then
          :
        else
          . ${file}
        fi
      done
    # handle FUNC function
    else
      file="${SGL_LIB}/${func}"
      [[ -f "${file}" ]] || _sgl_err VAL "invalid \`${FN}' \`${func}' FUNC"
      if declare -F ${func} > ${NIL}; then
        :
      else
        . ${file}
      fi
    fi
    shift
  done
}
readonly -f sgl_source
