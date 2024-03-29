# @dest $LIB/superglue/sgl_chk_dir
# @mode 0644
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
#
# @use sgl_source chk_dir
# @return
#   0  PASS
################################################################################

_sgl_source err err_code esc_val fail get_quiet get_silent help is_dir \
  parse_args version

############################################################
# @public
# @func sgl_chk_dir
# @use sgl_chk_dir [...OPTION] ...DIR
# @opt -h|-?|--help            Print help info and exit.
# @opt -m|--msg|--message=MSG  Override the default fail message.
# @opt -p|--prg|--program=PRG  Include the parent PRG in the fail message.
# @opt -Q|--silent             Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet              Disable `stdout' output.
# @opt -v|--version            Print version info and exit.
# @opt -x|--exit[=ERR]         Exit on check fail (default= `DPND').
# @opt -|--                    End the options.
# @val DIR  A valid directory path.
# @val ERR  Must be an error from the below options or any valid integer
#           in the range of `1' to `126'.
#   `ERR|MISC'  An unknown error (exit= `1').
#   `OPT'       An invalid option (exit= `2').
#   `VAL'       An invalid or missing value (exit= `3').
#   `AUTH'      A permissions error (exit= `4').
#   `DPND'      A dependency error (exit= `5').
#   `CHLD'      A child process exited unsuccessfully (exit= `6').
#   `SGL'       A `superglue' script error (exit= `7').
# @val MSG  Can be any string. The patterns, `DIR' and `PRG', are substituted
#           with the proper values. The default MSG is:
#             invalid [`PRG' ]directory path `DIR'
# @val PRG  Can be any string.
# @return
#   0  PASS  Each DIR is a valid directory path.
#   1  FAIL  A DIR is not a valid directory path.
############################################################
sgl_chk_dir()
{
  local -r FN='sgl_chk_dir'
  local -i i=0
  local -i code=0
  local -i quiet=$(_sgl_get_quiet PRT)
  local -i silent=$(_sgl_get_silent PRT)
  local dir
  local err=DPND
  local msg
  local prg
  local opt

  # parse each argument
  _sgl_parse_args ${FN} \
    '-h|-?|--help'       0 \
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

  # catch missing DIR
  if [[ ${#_SGL_VALS[@]} -eq 0 ]]; then
    _sgl_err VAL "missing a DIR for \`${FN}'"
  fi

  # build error message
  if [[ ${silent} -ne 1 ]]; then
    if [[ -n "${prg}" ]]; then
      if [[ -n "${msg}" ]]; then
        prg="$(_sgl_esc_val "${prg}")"
        msg="$(printf '%s' "${msg}" | ${sed} -e "s/PRG/${prg}/g")"
      else
        msg="invalid \`${prg}' directory path \`DIR'"
      fi
    elif [[ -z "${msg}" ]]; then
      msg="invalid directory path \`DIR'"
    fi
  fi

  # parse DIR
  for dir in "${_SGL_VALS[@]}"; do
    if _sgl_is_dir "${dir}"; then
      continue
    fi
    if [[ -n "${msg}" ]]; then
      dir="$(_sgl_esc_val "${dir}")"
      msg="$(printf '%s' "${msg}" | ${sed} -e "s/DIR/${dir}/g")"
      if [[ ${code} -eq 0 ]]; then
        _sgl_fail ${err} "${msg}"
      else
        _sgl_err ${err} "${msg}"
      fi
    elif [[ ${code} -ne 0 ]]; then
      exit ${code}
    fi
    return 1
  done
  return 0
}
readonly -f sgl_chk_dir
