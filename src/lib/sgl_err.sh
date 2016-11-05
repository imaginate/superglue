#!/bin/bash
#
# @dest /lib/superglue/sgl_err
# @mode 0644
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
# @opt -C|--color-title[=COLOR]  Color TITLE with COLOR (default= `red').
# @opt -c|--color[-msg][=COLOR]  Color MSG with COLOR (default= `red').
# @opt -D|--delim-title=DELIM    Deliminate TITLE and MSG with DELIM.
# @opt -d|--delim[-msg]=DELIM    Deliminate each MSG with DELIM.
# @opt -E|--no-escape            Do not evaluate escapes in MSG.
# @opt -e|--escape               Do evaluate escapes in MSG.
# @opt -h|-?|--help              Print help info and exit.
# @opt -N|--no-color             Disable colored TITLE or MSG outputs.
# @opt -n|--no-newline           Do not print a trailing newline.
# @opt -P|--child                Mark this error as one for a child process.
# @opt -p|--parent               Mark this error as one for a parent process.
# @opt -Q|--silent               Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet                Disable `stdout' output.
# @opt -r|--return               Return instead of exiting.
# @opt -T|--no-title             Disable any TITLE to be printed.
# @opt -t|--title=TITLE          Override the default TITLE to be printed.
# @opt -V|--verbose              Append the line number and context to output.
# @opt -v|--version              Print version info and exit.
# @opt -|--                      End the options.
# @val COLOR  Must be a color from the below options.
#   `black'
#   `blue'
#   `cyan'
#   `green'
#   `none'
#   `purple'
#   `red'
#   `white'
#   `yellow'
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
# @val MSG    Can be any string. May be provided via a piped `stdin'.
# @val TITLE  Can be any string.
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
  local -i child=-1
  local -i escape=0
  local -i newline=1
  local -i override=0
  local -i quiet=${SGL_QUIET}
  local -i silent=${SGL_SILENT}
  local -i verbose=${SGL_VERBOSE}
  local tcolor="$(_sgl_get_color red)"
  local mcolor
  local tdelim=' '
  local mdelim=' '
  local format
  local title
  local err
  local msg
  local opt
  local val

  # parse each argument
  _sgl_parse_args "${FN}" \
    '-C|--color-title'  2 \
    '-c|--color|--color-msg' 2 \
    '-D|--delim-title'  1 \
    '-d|--delim|--delim-msg' 1 \
    '-E|--no-escape'    0 \
    '-e|--escape'       0 \
    '-h|-?|--help'      0 \
    '-N|--no-color'     0 \
    '-n|--no-newline'   0 \
    '-P|--child'        0 \
    '-p|--parent'       0 \
    '-Q|--silent'       0 \
    '-q|--quiet'        0 \
    '-r|--return'       0 \
    '-T|--no-title'     0 \
    '-t|--title'        1 \
    '-V|--verbose'      0 \
    '-v|--version'      0 \
    -- "$@"

  # parse each OPTION
  len=${#_SGL_OPTS[@]}
  for ((i=0; i<len; i++)); do
    opt="${_SGL_OPTS[${i}]}"
    case "${opt}" in
      -C|--color-title)
        if [[ ${_SGL_OPT_BOOL[${i}]} -eq 1 ]]; then
          val="${_SGL_OPT_VALS[${i}]}"
          tcolor="$(_sgl_get_color "${val}")"
          if [[ $? -ne 0 ]]; then
            _sgl_err VAL "invalid \`${FN}' \`${opt}' COLOR \`${val}'"
          fi
        else
          tcolor="$(_sgl_get_color red)"
        fi
        ;;
      -c|--color|--color-msg)
        if [[ ${_SGL_OPT_BOOL[${i}]} -eq 1 ]]; then
          val="${_SGL_OPT_VALS[${i}]}"
          mcolor="$(_sgl_get_color "${val}")"
          if [[ $? -ne 0 ]]; then
            _sgl_err VAL "invalid \`${FN}' \`${opt}' COLOR \`${val}'"
          fi
        else
          mcolor="$(_sgl_get_color red)"
        fi
        ;;
      -D|--delim-title)
        tdelim="${_SGL_OPT_VALS[${i}]}"
        ;;
      -d|--delim|--delim-msg)
        mdelim="${_SGL_OPT_VALS[${i}]}"
        ;;
      -E|--no-escape)
        escape=0
        ;;
      -e|--escape)
        escape=1
        ;;
      -h|-\?|--help)
        _sgl_help sgl_err
        ;;
      -N|--no-color)
        tcolor=''
        mcolor=''
        ;;
      -n|--no-newline)
        newline=0
        ;;
      -P|--child)
        child=1
        ;;
      -p|--parent)
        child=0
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
      -T|--no-title)
        title=''
        override=1
        ;;
      -t|--title)
        title="${_SGL_OPT_VALS[${i}]}"
        override=1
        ;;
      -V|--verbose)
        verbose=1
        ;;
      -v|--version)
        _sgl_version
        ;;
      *)
        _sgl_err SGL "invalid parsed \`${FN}' OPTION \`${opt}'"
        ;;
    esac
  done

  # save values length
  len=${#_SGL_VALS[@]}

  # save ERR ref
  [[ ${len} -gt 0 ]] && err="${_SGL_VALS[0]}"

  # update process level
  if [[ ${child} -eq -1 ]] && [[ "${err}" == 'CHLD' ]]; then
    child=1
  fi

  # update quiet and silent
  if [[ ${child} -eq 1 ]]; then
    [[ ${SGL_SILENT_CHILD} -eq 1 ]] && silent=1
    [[ ${SGL_QUIET_CHILD}  -eq 1 ]] && quiet=1
  else
    [[ ${SGL_SILENT_PARENT} -eq 1 ]] && silent=1
    [[ ${SGL_QUIET_PARENT}  -eq 1 ]] && quiet=1
  fi

  # parse ERR
  if [[ ${len} -eq 0 ]]; then
    [[ ${silent} -eq 1 ]] && _sgl_err VAL
    _sgl_err VAL "missing \`${FN}' ERR"
  fi
  case "${err}" in
    MISC)
      [[ ${override} -eq 0 ]] && title='ERROR'
      code=1
      ;;
    OPT)
      [[ ${override} -eq 0 ]] && title='OPTION ERROR'
      code=2
      ;;
    VAL)
      [[ ${override} -eq 0 ]] && title='VALUE ERROR'
      code=3
      ;;
    AUTH)
      [[ ${override} -eq 0 ]] && title='AUTHORITY ERROR'
      code=4
      ;;
    DPND)
      [[ ${override} -eq 0 ]] && title='DEPENDENCY ERROR'
      code=5
      ;;
    CHLD)
      [[ ${override} -eq 0 ]] && title='CHILD ERROR'
      code=6
      ;;
    SGL)
      [[ ${override} -eq 0 ]] && title='SUPERGLUE ERROR'
      code=7
      ;;
    *)
      if [[ ! "${err}" =~ ^[1-9][0-9]?[0-9]?$ ]] || [[ ${err} -gt 126 ]]; then
        [[ ${silent} -eq 1 ]] && _sgl_err VAL
        _sgl_err VAL "invalid \`${FN}' ERR \`${err}'"
      fi
      [[ ${override} -eq 0 ]] && title='ERROR'
      code=${err}
      ;;
  esac

  # parse each MSG
  if [[ ${len} -eq 1 ]]; then
    if [[ -p /dev/stdin ]]; then
      msg="$(${cat} /dev/stdin)"
    elif [[ -p /dev/fd/0 ]]; then
      msg="$(${cat} /dev/fd/0)"
    else
      [[ ${silent} -eq 1 ]] && _sgl_err VAL
      _sgl_err VAL "missing \`${FN}' MSG"
    fi
  else
    for ((i=1; i<len; i++)); do
      val="${_SGL_VALS[${i}]}"
      if [[ -n "${val}" ]]; then
        if [[ -n "${msg}" ]]; then
          msg="${msg}${mdelim}${val}"
        else
          msg="${val}"
        fi
      fi
    done
  fi

  # color TITLE
  if [[ -n "${tcolor}" ]] && [[ -n "${title}" ]]; then
    if [[ ${SGL_COLOR_ON} -eq 1 ]]; then
      title="${tcolor}${title}${SGL_UNCOLOR}"
    elif [[ ${SGL_COLOR_OFF} -ne 1 ]] && [[ -t 1 ]]; then
      title="${tcolor}${title}${SGL_UNCOLOR}"
    fi
  fi

  # color MSG
  if [[ -n "${mcolor}" ]] && [[ -n "${msg}" ]]; then
    if [[ ${SGL_COLOR_ON} -eq 1 ]]; then
      msg="${mcolor}${msg}${SGL_UNCOLOR}"
    elif [[ ${SGL_COLOR_OFF} -ne 1 ]] && [[ -t 1 ]]; then
      msg="${mcolor}${msg}${SGL_UNCOLOR}"
    fi
  fi

  # append TITLE
  if [[ -n "${title}" ]]; then
    if [[ -n "${msg}" ]]; then
      msg="${title}${tdelim}${msg}"
    else
      msg="${title}"
    fi
  fi

  # set the MSG format
  if [[ ${escape} -eq 1 ]]; then
    format='%b'
  else
    format='%s'
  fi
  [[ ${newline} -eq 1 ]] && format="${format}\n"

  # print the error MSG
  if [[ ${silent} -ne 1 ]]; then
    printf "${format}" "${msg}" 1>&2
    if [[ ${verbose} -eq 1 ]]; then
      local details="$(caller)"
      printf "%s\n" "- LINE ${details%% *}" 1>&2
      printf "%s\n" "- FILE ${details##* }" 1>&2
    fi
  fi

  [[ ${ret} -eq 1 ]] && return ${code}
  exit ${code}
}
readonly -f sgl_err
