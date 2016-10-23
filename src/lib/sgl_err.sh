#!/bin/bash
#
# @dest /lib/superglue/sgl_err
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl_source err
# @return
#   0  PASS
################################################################################

############################################################
# @func sgl_err
# @use sgl_err [...OPTION] ERR ...MSG
# @opt -d|--delim=DELIM  Deliminate each MSG with DELIM.
# @opt -e|--escape       Interpret escapes.
# @opt -h|-?|--help      Print help info and exit.
# @opt -Q|--silent       Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet        Disable `stdout' output.
# @opt -r|--return       Return instead of exiting.
# @opt -v|--version      Print version info and exit.
# @opt -|--              End the options.
# @val DELIM  Can be any string. The default is ` '.
# @val ERR    Must be an error from the below options or any valid integer
#             in the range of `1' to `126'.
#   `MISC'  An unknown error (exit= `1').
#   `OPT'   An invalid option (exit= `2').
#   `VAL'   An invalid or missing value (exit= `3').
#   `AUTH'  A permissions error (exit= `4').
#   `DPND'  A dependency error (exit= `5').
#   `CHLD'  A child process exited unsuccessfully (exit= `6').
#   `SGL'   A `superglue' script error (exit= `7').
# @val MSG    Can be any string.
# @exit
#   1  MISC  An unknown error.
#   2  OPT   An invalid option.
#   3  VAL   An invalid or missing value.
#   4  AUTH  A permissions error.
#   5  DPND  A dependency error.
#   6  CHLD  A child process exited unsuccessfully.
#   7  SGL   A `superglue' script error.
############################################################
sgl_err()
{
  local -r FN='sgl_err'
  local -i i
  local -i len
  local -i ret=0
  local -i code=0
  local -i quiet=${SGL_QUIET}
  local -i silent=${SGL_SILENT}
  local -i escape=0
  local delim=' '
  local err
  local msg
  local opt
  local part
  local title

  # parse each argument
  _sgl_parse_args "${FN}" \
    '-d|--delim'   1 \
    '-e|--escape'  0 \
    '-h|-?|--help' 0 \
    '-Q|--silent'  0 \
    '-q|--quiet'   0 \
    '-r|--return'  0 \
    '-v|--version' 0 \
    -- "$@"

  # parse each OPTION
  len=${#_SGL_OPTS[@]}
  for ((i=0; i<len; i++)); do
    opt="${_SGL_OPTS[${i}]}"
    case "${opt}" in
      -d|--delim)
        delim="${_SGL_OPT_VALS[${i}]}"
        ;;
      -e|--escape)
        escape=1
        ;;
      -h|-\?|--help)
        _sgl_help sgl_err
        ;;
      -Q|--silent)
        silent=1
        ;;
      -q|--quiet)
        quiet=1
        ;;
      -r|--return)
        ret=1
        ;;
      -v|--version)
        _sgl_version
        ;;
      *)
        _sgl_err SGL "invalid parsed \`${FN}' OPTION \`${opt}'"
        ;;
    esac
  done

  # catch missing ERR and MSG
  len=${#_SGL_VALS[@]}
  [[ ${len} -gt 0 ]] || _sgl_err VAL "missing \`${FN}' ERR"
  [[ ${len} -gt 1 ]] || _sgl_err VAL "missing \`${FN}' MSG"

  # parse ERR
  err="${_SGL_VALS[0]}"
  case "${err}" in
    MISC)
      title='ERR'
      code=1
      ;;
    OPT)
      title='OPT_ERR'
      code=2
      ;;
    VAL)
      title='VAL_ERR'
      code=3
      ;;
    AUTH)
      title='AUTH_ERR'
      code=4
      ;;
    DPND)
      title='DPND_ERR'
      code=5
      ;;
    CHLD)
      title='CHLD_ERR'
      code=6
      ;;
    SGL)
      title='SGL_ERR'
      code=7
      ;;
    *)
      if [[ ! "${err}" =~ ^[1-9][0-9]?[0-9]?$ ]] || [[ ${err} -gt 126 ]]; then
        _sgl_err VAL "invalid \`${FN}' ERR \`${err}'"
      fi
      title='ERR'
      code=${err}
      ;;
  esac

  # color the title
  if [[ ${SGL_COLOR_ON} -eq 1 ]]; then
    [[ -n "${SGL_RED}"     ]] && title="${SGL_RED}${title}"
    [[ -n "${SGL_UNCOLOR}" ]] && title="${title}${SGL_UNCOLOR}"
  elif [[ ${SGL_COLOR_OFF} -ne 1 ]] && [[ -t 1 ]]; then
    [[ -n "${SGL_RED}"     ]] && title="${SGL_RED}${title}"
    [[ -n "${SGL_UNCOLOR}" ]] && title="${title}${SGL_UNCOLOR}"
  fi

  # parse each MSG
  for ((i=1; i<len; i++)); do
    part="${_SGL_VALS[${i}]}"
    if [[ -n "${part}" ]]; then
      if [[ -n "${msg}" ]]; then
        msg="${msg}${delim}${part}"
      else
        msg="${part}"
      fi
    fi
  done

  # print the error MSG
  if [[ ${silent} -ne 1 ]] && [[ ${SGL_SILENT_PARENT} -ne 1 ]]; then
    if [[ ${escape} -eq 1 ]]; then
      printf "%s %b\n" "${title}" "${msg}" 1>&2
    else
      printf "%s %s\n" "${title}" "${msg}" 1>&2
    fi
  fi
  if [[ ${SGL_VERBOSE} -eq 1 ]]; then
    local line="- LINE $(caller | ${sed} -e 's/ .\+$//')"
    local file="- FILE $(caller | ${sed} -e 's/^[0-9]\+ //')"
    printf "%s\n%s\n" "${line}" "${file}"
  fi

  [[ ${ret} -eq 1 ]] && return ${code}
  exit ${code}
}
readonly -f sgl_err
