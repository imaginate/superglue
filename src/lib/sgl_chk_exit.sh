# @dest $LIB/superglue/sgl_chk_exit
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
#
# @use sgl_source chk_exit
# @return
#   0  PASS
################################################################################

_sgl_source err err_code esc_val fail get_quiet get_silent help parse_args \
  version

############################################################
# @public
# @func sgl_chk_exit
# @use sgl_chk_exit [...OPTION] CODE
# @opt -h|-?|--help            Print help info and exit.
# @opt -c|--cmd|--command=CMD  Include the CMD string in the fail message.
# @opt -m|--msg|--message=MSG  Override the default fail message.
# @opt -p|--prg|--program=PRG  Include the parent PRG in the fail message.
# @opt -Q|--silent             Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet              Disable `stdout' output.
# @opt -v|--version            Print version info and exit.
# @opt -x|--exit[=ERR]         Exit on check fail (default= `CHLD').
# @opt -|--                    End the options.
# @val CMD   Can be any string. The default is `a command'.
# @val CODE  Must be an integer in the range of `0' to `255'.
# @val ERR   Must be an error from the below options or any valid integer
#            in the range of `1' to `126'.
#   `ERR|MISC'  An unknown error (exit= `1').
#   `OPT'       An invalid option (exit= `2').
#   `VAL'       An invalid or missing value (exit= `3').
#   `AUTH'      A permissions error (exit= `4').
#   `DPND'      A dependency error (exit= `5').
#   `CHLD'      A child process exited unsuccessfully (exit= `6').
#   `SGL'       A `superglue' script error (exit= `7').
# @val MSG   Can be any string. The patterns, `CMD', `PRG', and `CODE', are
#            substituted with the proper values. The default MSG is:
#              `CMD'[ in `PRG'] exited with `CODE'
# @val PRG   Can be any string.
# @return
#   0  PASS  The exit CODE is zero.
#   1  FAIL  The exit CODE is non-zero.
############################################################
sgl_chk_exit()
{
  local -r FN='sgl_chk_exit'
  local -i i=0
  local -i code=0
  local -i xcode=0
  local -i quiet=$(_sgl_get_quiet PRT)
  local -i silent=$(_sgl_get_silent PRT)
  local cmd='a command'
  local err=CHLD
  local msg
  local prg
  local opt

  # parse each argument
  _sgl_parse_args ${FN} \
    '-h|-?|--help'       0 \
    '-c|--cmd|--command' 1 \
    '-m|--msg|--message' 1 \
    '-p|--prg|--program' 1 \
    '-Q|--silent'        0 \
    '-q|--quiet'         0 \
    '-v|--version'       0 \
    '-x|--exit'          2 \
    -- "${@}"

  # parse each OPTION
  if [[ ${#_SGL_OPTS[@]} -gt 0 ]]; then
    for opt in "${_SGL_OPTS[@]}"; do
      case "${opt}" in
        -h|-\?|--help)
          _sgl_help ${FN}
          ;;
        -c|--cmd|--command)
          cmd="${_SGL_OPT_VALS[${i}]}"
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
          xcode=$(_sgl_err_code "${err}")
          if [[ ${xcode} -eq 0 ]]; then
            _sgl_err VAL "invalid \`${FN}' ERR \`${err}'"
          fi
          ;;
        *)
          _sgl_err SGL "invalid parsed \`${FN}' OPTION \`${opt}'"
          ;;
      esac
      i=$(( i + 1 ))
    done
  fi

  # parse CODE
  if [[ ${#_SGL_VALS[@]} -eq 0 ]]; then
    _sgl_err VAL "missing \`${FN}' CODE"
  elif [[ ${#_SGL_VALS[@]} -gt 1 ]]; then
    _sgl_err VAL "only 1 \`${FN}' CODE allowed"
  fi
  code="${_SGL_VALS[0]}"
  if [[ ! "${code}" =~ ^[0-9][0-9]?[0-9]?$ ]] || [[ ${code} -gt 255 ]]; then
    _sgl_err VAL "invalid \`${FN}' CODE \`${code}'"
  fi
  if [[ ${code} -eq 0 ]]; then
    return 0
  fi

  # build error message
  if [[ ${silent} -ne 1 ]]; then
    if [[ -n "${prg}" ]]; then
      if [[ -n "${msg}" ]]; then
        prg="$(_sgl_esc_val "${prg}")"
        cmd="$(_sgl_esc_val "${cmd}")"
        msg="$(printf '%s' "${msg}" | ${sed} -e "s/CMD/${cmd}/g" \
          -e "s/PRG/${prg}/g" -e "s/CODE/${code}/g")"
      else
        msg="\`${cmd}' in \`${prg}' exited with \`${code}'"
      fi
    elif [[ -n "${msg}" ]]; then
      cmd="$(_sgl_esc_val "${cmd}")"
      msg="$(printf '%s' "${msg}" | ${sed} -e "s/CMD/${cmd}/g" \
        -e "s/CODE/${code}/g")"
    else
      msg="\`${cmd}' exited with \`${code}'"
    fi
  fi

  # exit process
  if [[ ${xcode} -ne 0 ]]; then
    if [[ -n "${msg}" ]]; then
      _sgl_err ${err} "${msg}"
    fi
    exit ${xcode}
  fi

  # print error
  if [[ -n "${msg}" ]]; then
    _sgl_fail ${err} "${msg}"
  fi

  return 1
}
readonly -f sgl_chk_exit
