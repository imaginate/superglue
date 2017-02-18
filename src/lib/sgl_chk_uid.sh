#!/bin/bash
#
# @dest $LIB/superglue/sgl_chk_uid
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl_source chk_uid
# @return
#   0  PASS
################################################################################

_sgl_source err err_code escape_val escape_vals fail get_quiet get_silent help \
  is_set parse_args version

############################################################
# @func sgl_chk_uid
# @use sgl_chk_uid [...OPTION] ...UID
# @opt -h|-?|--help            Print help info and exit.
# @opt -i|--invert             Invert the check to fail if a UID matches.
# @opt -m|--msg|--message=MSG  Override the default fail message.
# @opt -p|--prg|--program=PRG  Include the parent PRG in the fail message.
# @opt -Q|--silent             Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet              Disable `stdout' output.
# @opt -v|--version            Print version info and exit.
# @opt -x|--exit[=ERR]         Exit on check fail (default= `AUTH').
# @opt -|--                    End the options.
# @val ERR  Must be an error from the below options or any valid integer
#           in the range of `1' to `126'.
#   `ERR|MISC'  An unknown error (exit= `1').
#   `OPT'       An invalid option (exit= `2').
#   `VAL'       An invalid or missing value (exit= `3').
#   `AUTH'      A permissions error (exit= `4').
#   `DPND'      A dependency error (exit= `5').
#   `CHLD'      A child process exited unsuccessfully (exit= `6').
#   `SGL'       A `superglue' script error (exit= `7').
# @val MSG  Can be any string. The patterns, `UID', `EUID', and `PRG', are
#           substituted with the proper values. The default MSG is:
#             invalid user permissions[ for `PRG']
# @val PRG  Can be any string.
# @val UID  Must be an integer in the range of `0' to `60000'.
# @return
#   0  PASS  Current effective user id matches a UID.
#   1  FAIL  Current effective user id does not match a UID.
############################################################
sgl_chk_uid()
{
  local -r FN='sgl_chk_uid'
  local -i i
  local -i len
  local -i code=0
  local -i quiet=$(_sgl_get_quiet PRT)
  local -i silent=$(_sgl_get_silent PRT)
  local -i invert=0
  local -i pass
  local uid
  local err=AUTH
  local msg
  local prg
  local opt

  # parse each argument
  _sgl_parse_args ${silent} "${FN}" \
    '-h|-?|--help'       0 \
    '-i|--invert'        0 \
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
      -i|--invert)
        invert=1
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

  # catch invalid EUID
  if [[ ! "${EUID}" =~ ^[0-9]+$ ]] || [[ ${EUID} -gt 60000 ]]; then
    _sgl_err ${silent} CHLD "invalid \$EUID \`${EUID}'"
  fi

  # catch invalid UID
  len=${#_SGL_VALS[@]}
  if [[ ${len} -eq 0 ]]; then
    _sgl_err ${silent} VAL "missing a UID for \`${FN}'"
  fi
  for (( i=0; i<len; i++ )); do
    uid="${_SGL_VALS[${i}]}"
    if [[ ! "${uid}" =~ ^[0-9]+$ ]] || [[ ${uid} -gt 60000 ]]; then
      _sgl_err ${silent} VAL "invalid \`${FN}' UID \`${uid}'"
    fi
  done

  # check each UID
  uid=''
  pass=0
  for (( i=0; i<len; i++ )); do
    if [[ -n "${uid}" ]]; then
      uid="${uid}|${_SGL_VALS[${i}]}"
    else
      uid="${_SGL_VALS[${i}]}"
    fi
    if [[ ${_SGL_VALS[${i}]} -eq ${EUID} ]]; then
      pass=1
    fi
  done
  if [[ ${invert} -eq 1 ]]; then
    if [[ ${pass} -eq 0 ]]; then
      return 0
    fi
  elif [[ ${pass} -eq 1 ]]; then
    return 0
  fi

  # build error message
  if [[ ${silent} -ne 1 ]]; then
    if [[ -n "${prg}" ]]; then
      if [[ -n "${msg}" ]]; then
        prg="$(_sgl_escape_val "${prg}")"
        uid="$(_sgl_escape_val "${uid}")"
        msg="$(printf '%s' "${msg}" | ${sed} -e "s/PRG/${prg}/g" \
          -e "s/UID/${uid}/g" -e "s/EUID/${EUID}/g")"
      else
        msg="invalid user permissions for \`${prg}'"
      fi
    elif [[ -z "${msg}" ]]; then
      msg="invalid user permissions"
    fi
  fi

  # exit process
  if [[ ${code} -ne 0 ]]; then
    if [[ -n "${msg}" ]]; then
      _sgl_err ${silent} ${err} "${msg}"
    fi
    exit ${code}
  fi

  # print error
  if [[ -n "${msg}" ]]; then
    _sgl_fail ${err} "${msg}"
  fi

  return 1
}
readonly -f sgl_chk_uid
