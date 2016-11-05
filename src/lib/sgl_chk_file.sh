#!/bin/bash
#
# @dest /lib/superglue/sgl_chk_file
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl_source chk_file
# @return
#   0  PASS
################################################################################

############################################################
# @func sgl_chk_file
# @use sgl_chk_file [...OPTION] ...FILE
# @opt -h|-?|--help            Print help info and exit.
# @opt -m|--msg|--message=MSG  Override the default fail message.
# @opt -p|--prg|--program=PRG  Include the parent PRG in the fail message.
# @opt -Q|--silent             Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet              Disable `stdout' output.
# @opt -v|--version            Print version info and exit.
# @opt -x|--exit[=ERR]         Exit on check fail (default= `DPND').
# @opt -|--                    End the options.
# @val ERR   Must be an error from the below options or any valid integer in the
#            range of `1' to `126'.
#   `MISC'  An unknown error (exit= `1').
#   `OPT'   An invalid option (exit= `2').
#   `VAL'   An invalid or missing value (exit= `3').
#   `AUTH'  A permissions error (exit= `4').
#   `DPND'  A dependency error (exit= `5').
#   `CHLD'  A child process exited unsuccessfully (exit= `6').
#   `SGL'   A `superglue' script error (exit= `7').
# @val FILE  A valid file path.
# @val MSG   Can be any string. The patterns, `FILE' and `PRG', are substituted
#            with the proper values. The default MSG is:
#              `invalid [`PRG' ]file path `FILE''
# @val PRG   Can be any string.
# @return
#   0  PASS
#   1  FAIL
############################################################
sgl_chk_file()
{
  local -r FN='sgl_chk_file'
  local -i i
  local -i len
  local -i code=0
  local -i quiet=${SGL_QUIET}
  local -i silent=${SGL_SILENT}
  local file
  local err=DPND
  local msg
  local prg
  local opt

  # parse each argument
  _sgl_parse_args "${FN}"  \
    '-h|-?|--help'       0 \
    '-m|--msg|--message' 1 \
    '-p|--prg|--program' 1 \
    '-Q|--silent'        0 \
    '-q|--quiet'         0 \
    '-v|--version'       0 \
    '-x|--exit'          2 \
    -- "$@"

  # parse each OPTION
  len=${#_SGL_OPTS[@]}
  for ((i=0; i<len; i++)); do
    opt="${_SGL_OPTS[${i}]}"
    case "${opt}" in
      -h|-\?|--help)
        _sgl_help sgl_chk_file
        ;;
      -m|--msg|--message)
        msg="${_SGL_OPT_VALS[${i}]}"
        ;;
      -p|--prg|--program)
        prg="${_SGL_OPT_VALS[${i}]}"
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
      -x|--exit)
        [[ ${_SGL_OPT_BOOL[${i}]} -eq 1 ]] && err="${_SGL_OPT_VALS[${i}]}"
        code=$(_sgl_err_code "${err}")
        [[ ${code} -eq 0 ]] && _sgl_err VAL "invalid \`${FN}' ERR \`${err}'"
        ;;
      *)
        _sgl_err SGL "invalid parsed \`${FN}' OPTION \`${opt}'"
        ;;
    esac
  done

  # catch missing FILE
  [[ ${#_SGL_VALS[@]} -gt 0 ]] || _sgl_err VAL "missing \`${FN}' FILE"

  # build error message
  if [[ ${silent} -ne 1 ]] && [[ ${SGL_SILENT_PARENT} -ne 1 ]]; then
    if [[ -n "${prg}" ]]; then
      if [[ -n "${msg}" ]]; then
        msg="$(printf '%s' "${msg}" | ${sed} -e "s|PRG|${prg}|g")"
      else
        msg="invalid \`${prg}' file path \`FILE'"
      fi
    elif [[ -z "${msg}" ]]; then
      msg="invalid file path \`FILE'"
    fi
  fi

  # parse FILE
  for file in "${_SGL_VALS[@]}"; do
    [[ -n "${file}" ]] || _sgl_err VAL "empty \`${FN}' FILE"
    [[ -f "${file}" ]] && continue
    if [[ -n "${msg}" ]]; then
      msg="$(printf '%s' "${msg}" | ${sed} -e "s|FILE|${file}|g")"
      [[ ${code} -eq 0 ]] || _sgl_err ${err} "${msg}"
      _sgl_fail MISC "${msg}"
    fi
    [[ ${code} -eq 0 ]] || exit ${code}
    return 1
  done
  return 0
}
readonly -f sgl_chk_file
