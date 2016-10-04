#!/bin/bash
#
# @dest /lib/superglue/sgl_chk_cmd
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl_source chk_cmd
# @return
#   0  PASS
################################################################################

############################################################
# @func sgl_chk_cmd
# @use sgl_chk_cmd [...OPTION] ...CMD
# @opt -h|--help               Print help info and exit.
# @opt -m|--msg|--message=MSG  Override the default fail message.
# @opt -p|--prg|--program=PRG  Include the parent PRG in the fail message.
# @opt -Q|--silent             Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet              Disable `stdout' output.
# @opt -v|--version            Print version info and exit.
# @opt -x|--exit[=ERR]         Exit on check fail (default= `DPND').
# @opt -|--                    End the options.
# @val CMD  A valid file path to an executable binary.
# @val ERR  Must be an error from the below options or any valid integer in the
#           range of `1' to `126'.
#   `MISC'  An unknown error (exit= `1').
#   `OPT'   An invalid option (exit= `2').
#   `VAL'   An invalid or missing value (exit= `3').
#   `AUTH'  A permissions error (exit= `4').
#   `DPND'  A dependency error (exit= `5').
#   `CHLD'  A child process exited unsuccessfully (exit= `6').
#   `SGL'   A `superglue' script error (exit= `7').
# @val MSG  Can be any string. The patterns, `CMD' and `PRG', are substituted
#           with the proper values. The default MSG is:
#             `missing executable `CMD'[ for `PRG']'
# @val PRG  Can be any string.
# @return
#   0  PASS
#   1  FAIL
############################################################
sgl_chk_cmd()
{
  local -r FN='sgl_chk_cmd'
  local -i i
  local -i len
  local -i code=0
  local -i quiet=${SGL_QUIET}
  local -i silent=${SGL_SILENT}
  local cmd
  local err=DPND
  local msg
  local prg
  local opt

  # parse each argument
  _sgl_parse_args "${FN}"  \
    '-h|--help'          0 \
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
      -h|--help)
        ${cat} <<'EOF'

  sgl_chk_cmd [...OPTION] ...CMD

  Options:
    -h|--help               Print help info and exit.
    -m|--msg|--message=MSG  Override the default fail message.
    -p|--prg|--program=PRG  Include the parent PRG in the fail message.
    -Q|--silent             Disable `stderr' and `stdout' outputs.
    -q|--quiet              Disable `stdout' output.
    -v|--version            Print version info and exit.
    -x|--exit[=ERR]         Exit on check fail (default= `DPND').
    -|--                    End the options.

  Values:
    CMD  A valid file path to an executable binary.
    ERR  Must be an error from the below options or any valid integer in the
         range of `1' to `126'.
      `MISC'  An unknown error (exit= `1').
      `OPT'   An invalid option (exit= `2').
      `VAL'   An invalid or missing value (exit= `3').
      `AUTH'  A permissions error (exit= `4').
      `DPND'  A dependency error (exit= `5').
      `CHLD'  A child process exited unsuccessfully (exit= `6').
      `SGL'   A `superglue' script error (exit= `7').
    MSG  Can be any string. The patterns, `CMD' and `PRG', are substituted
         with the proper values. The default MSG is:
           `missing executable `CMD'[ for `PRG']'
    PRG  Can be any string.

  Returns:
    0  PASS
    1  FAIL

EOF
        exit 0
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

  # catch missing CMD
  [[ ${#_SGL_VALS[@]} -gt 0 ]] || _sgl_err VAL "missing \`${FN}' CMD"

  # build error message
  if [[ ${silent} -ne 1 ]] && [[ ${SGL_SILENT_PARENT} -ne 1 ]]; then
    if [[ -n "${prg}" ]]; then
      if [[ -n "${msg}" ]]; then
        msg="$(printf '%s' "${msg}" | ${sed} -e "s|PRG|${prg}|g")"
      else
        msg="missing executable \`CMD' for \`${prg}'"
      fi
    elif [[ -z "${msg}" ]]; then
      msg="missing executable \`CMD'"
    fi
  fi

  # parse CMD
  for cmd in "${_SGL_VALS[@]}"; do
    [[ -n "${cmd}" ]] || _sgl_err VAL "empty \`${FN}' CMD"
    [[ -x "${cmd}" ]] && continue
    if [[ -n "${msg}" ]]; then
      msg="$(printf '%s' "${msg}" | ${sed} -e "s|CMD|${cmd}|g")"
      [[ ${code} -eq 0 ]] || _sgl_err ${err} "${msg}"
      _sgl_fail MISC "${msg}"
    fi
    [[ ${code} -eq 0 ]] || exit ${code}
    return 1
  done
  return 0
}
readonly -f sgl_chk_cmd
