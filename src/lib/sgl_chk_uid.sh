#!/bin/bash
#
# @dest /lib/superglue/sgl_chk_uid
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl_source chk_uid
# @return
#   0  PASS
################################################################################

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
# @val ERR  Must be an error from the below options or any valid integer in the
#           range of `1' to `126'.
#   `MISC'  An unknown error (exit= `1').
#   `OPT'   An invalid option (exit= `2').
#   `VAL'   An invalid or missing value (exit= `3').
#   `AUTH'  A permissions error (exit= `4').
#   `DPND'  A dependency error (exit= `5').
#   `CHLD'  A child process exited unsuccessfully (exit= `6').
#   `SGL'   A `superglue' script error (exit= `7').
# @val MSG  Can be any string. The patterns, `UID' and `PRG', are substituted
#           with the proper values. The default MSG is:
#             `invalid user permissions[ for `PRG']'
# @val PRG  Can be any string.
# @val UID  Must be an integer in the range of `0' to `60000'.
# @return
#   0  PASS  Current effective user matches a UID.
#   1  FAIL  Current effective user does not match a UID.
############################################################
sgl_chk_uid()
{
  local -r FN='sgl_chk_uid'
  local -i i
  local -i len
  local -i code=0
  local -i quiet=${SGL_QUIET}
  local -i silent=${SGL_SILENT}
  local -i invert=0
  local -i pass
  local uid
  local err=AUTH
  local msg
  local prg
  local opt

  # parse each argument
  _sgl_parse_args "${FN}"  \
    '-h|-?|--help'       0 \
    '-i|--invert'        0 \
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
        _sgl_help sgl_chk_uid
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
        [[ ${_SGL_OPT_BOOL[${i}]} -eq 1 ]] && err="${_SGL_OPT_VALS[${i}]}"
        code=$(_sgl_err_code "${err}")
        [[ ${code} -eq 0 ]] && _sgl_err VAL "invalid \`${FN}' ERR \`${err}'"
        ;;
      *)
        _sgl_err SGL "invalid parsed \`${FN}' OPTION \`${opt}'"
        ;;
    esac
  done

  # catch invalid EUID
  if [[ ! "${EUID}" =~ ^[0-9]+$ ]] || [[ ${EUID} -gt 60000 ]]; then
    _sgl_err CHLD "invalid \$EUID \`${EUID}'"
  fi

  # catch invalid UID
  len=${#_SGL_VALS[@]}
  [[ ${len} -gt 0 ]] || _sgl_err VAL "missing \`${FN}' UID"
  for ((i=0; i<len; i++)); do
    uid="${_SGL_VALS[${i}]}"
    if [[ ! "${uid}" =~ ^[0-9]+$ ]] || [[ ${uid} -gt 60000 ]]; then
      _sgl_err VAL "invalid \`${FN}' UID \`${uid}'"
    fi
  done

  # check each UID
  if [[ ${invert} -eq 1 ]]; then
    pass=1
    for ((i=0; i<len; i++)); do
      [[ ${_SGL_VALS[${i}]} -ne ${EUID} ]] && continue
      pass=0
      uid=${_SGL_VALS[${i}]}
      break
    done
  else
    uid=''
    pass=0
    for ((i=0; i<len; i++)); do
      [[ ${_SGL_VALS[${i}]} -ne ${EUID} ]] && continue
      if [[ -n "${uid}" ]]; then
        uid="${uid}|${_SGL_VALS[${i}]}"
      else
        uid="${_SGL_VALS[${i}]}"
      fi
      pass=1
      break
    done
  fi
  [[ ${pass} -eq 1 ]] && return 0

  # build error message
  if [[ ${silent} -ne 1 ]] && [[ ${SGL_SILENT_PARENT} -ne 1 ]]; then
    if [[ -n "${prg}" ]]; then
      if [[ -n "${msg}" ]]; then
        msg="$(printf '%s' "${msg}" | ${sed} -e "s|PRG|${prg}|g" \
          -e "s/UID/${uid}/g")"
      else
        msg="invalid user permissions for \`${prg}'"
      fi
    elif [[ -z "${msg}" ]]; then
      msg="invalid user permissions"
    fi
  fi

  # exit process
  if [[ ${code} -ne 0 ]]; then
    [[ -n "${msg}" ]] && _sgl_err ${err} "${msg}"
    exit ${code}
  fi

  # print error
  [[ -n "${msg}" ]] && _sgl_fail MISC "${msg}"

  return 1
}
readonly -f sgl_chk_uid
