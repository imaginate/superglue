#!/bin/bash
#
# @dest $LIB/superglue/sgl_chk_cmd
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl_source chk_cmd
# @return
#   0  PASS
################################################################################

############################################################
# @func sgl_chk_cmd
# @use sgl_chk_cmd [...OPTION] ...CMD
# @opt -h|-?|--help            Print help info and exit.
# @opt -m|--msg|--message=MSG  Override the default fail message.
# @opt -p|--prg|--program=PRG  Include the parent PRG in the fail message.
# @opt -Q|--silent             Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet              Disable `stdout' output.
# @opt -v|--version            Print version info and exit.
# @opt -x|--exit[=ERR]         Exit on check fail (default= `DPND').
# @opt -|--                    End the options.
# @val CMD  A valid file path to an executable binary.
# @val ERR  Must be an error from the below options or any valid integer
#           in the range of `1' to `126'.
#   `ERR|MISC'  An unknown error (exit= `1').
#   `OPT'       An invalid option (exit= `2').
#   `VAL'       An invalid or missing value (exit= `3').
#   `AUTH'      A permissions error (exit= `4').
#   `DPND'      A dependency error (exit= `5').
#   `CHLD'      A child process exited unsuccessfully (exit= `6').
#   `SGL'       A `superglue' script error (exit= `7').
# @val MSG  Can be any string. The patterns, `CMD' and `PRG', are substituted
#           with the proper values. The default MSG is:
#             invalid executable path `CMD'[ for `PRG']
# @val PRG  Can be any string.
# @return
#   0  PASS  Each CMD is a valid file path to an executable.
#   1  FAIL  A CMD is not a valid file path to an executable.
############################################################
sgl_chk_cmd()
{
  local -r FN='sgl_chk_cmd'
  local -i i
  local -i len
  local -i code=0
  local -i quiet=$(_sgl_get_quiet)
  local -i silent=$(_sgl_get_silent PRT)
  local cmd
  local err=DPND
  local msg
  local prg
  local opt

  # parse each argument
  _sgl_parse_args ${silent} "${FN}" \
    '-h|-?|--help'       0 \
    '-m|--msg|--message' 1 \
    '-p|--prg|--program' 1 \
    '-Q|--silent'        0 \
    '-q|--quiet'         0 \
    '-v|--version'       0 \
    '-x|--exit'          2 \
    -- "${@}"

  # parse each OPTION
  len=${#_SGL_OPTS[@]}
  for (( i=0; i<len; i++ )); do
    opt="${_SGL_OPTS[${i}]}"
    case "${opt}" in
      -h|-\?|--help)
        _sgl_help ${FN}
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
        if [[ ${_SGL_OPT_BOOL[${i}]} -eq 1 ]]; then
          err="${_SGL_OPT_VALS[${i}]}"
        fi
        code=$(_sgl_err_code "${err}")
        if [[ ${code} -eq 0 ]]; then
          _sgl_err ${silent} VAL "invalid \`${FN}' ERR \`${err}'"
        fi
        ;;
      *)
        _sgl_err ${silent} SGL "invalid parsed \`${FN}' OPTION \`${opt}'"
        ;;
    esac
  done

  # catch missing CMD
  if [[ ${#_SGL_VALS[@]} -eq 0 ]]; then
    _sgl_err ${silent} VAL "missing a CMD for \`${FN}'"
  fi

  # build error message
  if [[ ${silent} -ne 1 ]]; then
    if [[ -n "${prg}" ]]; then
      if [[ -n "${msg}" ]]; then
        prg="$(_sgl_escape_val "${prg}")"
        msg="$(printf '%s' "${msg}" | ${sed} -e "s/PRG/${prg}/g")"
      else
        msg="invalid executable path \`CMD' for \`${prg}'"
      fi
    elif [[ -z "${msg}" ]]; then
      msg="invalid executable path \`CMD'"
    fi
  fi

  # parse CMD
  for cmd in "${_SGL_VALS[@]}"; do
    if _sgl_is_cmd "${cmd}"; then
      continue
    fi
    if [[ -n "${msg}" ]]; then
      cmd="$(_sgl_escape_val "${cmd}")"
      msg="$(printf '%s' "${msg}" | ${sed} -e "s/CMD/${cmd}/g")"
      if [[ ${code} -eq 0 ]]; then
        if [[ ${silent} -ne 1 ]]; then
          _sgl_fail ${err} "${msg}"
        fi
      else
        _sgl_err ${silent} ${err} "${msg}"
      fi
    elif [[ ${code} -ne 0 ]]; then
      exit ${code}
    fi
    return 1
  done
  return 0
}
readonly -f sgl_chk_cmd

if ! _sgl_is_set _sgl_err_code; then
  # @include ../include/_sgl_err_code.sh
fi

if ! _sgl_is_set _sgl_escape_val; then
  # @include ../include/_sgl_escape_val.sh
fi

if ! _sgl_is_set _sgl_escape_vals; then
  # @include ../include/_sgl_escape_vals.sh
fi
