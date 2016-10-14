#!/bin/bash
#
# @dest /lib/superglue/sgl_print
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl_source print
# @return
#   0  PASS
################################################################################

############################################################
# @func sgl_print
# @use sgl_print [...OPTION] ...MSG
# @opt -C|--color-title=COLOR  Color TITLE with COLOR.
# @opt -c|--color[-msg]=COLOR  Color MSG with COLOR.
# @opt -D|--delim-title=DELIM  Deliminate TITLE and MSG with DELIM.
# @opt -d|--delim[-msg]=DELIM  Deliminate each MSG with DELIM.
# @opt -e|--escape             Evaluate escapes.
# @opt -h|-?|--help            Print help info and exit.
# @opt -n|--no-newline         Do not print a trailing newline.
# @opt -Q|--silent             Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet              Disable `stdout' output.
# @opt -t|--title=TITLE        Print TITLE before MSG.
# @opt -v|--version            Print version info and exit.
# @opt -|--                    End the options.
# @val COLOR  Must be a color from the below options.
#   `black'
#   `red'
#   `green'
#   `yellow'
#   `blue'
#   `purple'
#   `cyan'
#   `white'
# @val DELIM  Can be any string. By default DELIM is ` '.
# @val MSG    Can be any string.
# @val TITLE  Can be any string.
# @return
#   0  PASS
############################################################
sgl_print()
{
  local -r FN='sgl_print'
  local -i i
  local -i len
  local -i escape=0
  local -i newline=1
  local -i quiet=${SGL_QUIET}
  local -i silent=${SGL_SILENT}
  local tcolor
  local mcolor
  local tdelim
  local mdelim
  local title
  local msg
  local opt
  local val

  # parse each argument
  _sgl_parse_args "${FN}" \
    '-C|--color-title'  1 \
    '-c|--color|--color-msg' 1 \
    '-D|--delim-title'  1 \
    '-d|--delim|--delim-msg' 1 \
    '-e|--escape'       0 \
    '-h|-?|--help'      0 \
    '-n|--no-newline'   0 \
    '-Q|--silent'       0 \
    '-q|--quiet'        0 \
    '-t|--title'        1 \
    '-v|--version'      0 \
    -- "$@"

  # parse each OPTION
  len=${#_SGL_OPTS[@]}
  for ((i=0; i<len; i++)); do
    opt="${_SGL_OPTS[${i}]}"
    case "${opt}" in
      -C|--color-title)
        tcolor="$(_sgl_get_color "${_SGL_OPT_VALS[${i}]}")"
        if [[ $? -ne 0 ]]; then
          _sgl_err VAL "invalid \`${FN}' COLOR \`${_SGL_OPT_VALS[${i}]}'"
        fi
        ;;
      -c|--color|--color-msg)
        mcolor="$(_sgl_get_color "${_SGL_OPT_VALS[${i}]}")"
        if [[ $? -ne 0 ]]; then
          _sgl_err VAL "invalid \`${FN}' COLOR \`${_SGL_OPT_VALS[${i}]}'"
        fi
        ;;
      -D|--delim-title)
        tdelim="${_SGL_OPT_VALS[${i}]}"
        ;;
      -d|--delim|--delim-msg)
        mdelim="${_SGL_OPT_VALS[${i}]}"
        ;;
      -e|--escape)
        escape=1
        ;;
      -h|-\?|--help)
        ${cat} <<'EOF'

  sgl_print [...OPTION] ...MSG

  Options:
    -C|--color-title=COLOR  Color TITLE with COLOR.
    -c|--color[-msg]=COLOR  Color MSG with COLOR.
    -D|--delim-title=DELIM  Deliminate TITLE and MSG with DELIM.
    -d|--delim[-msg]=DELIM  Deliminate each MSG with DELIM.
    -e|--escape             Evaluate escapes.
    -h|-?|--help            Print help info and exit.
    -n|--no-newline         Do not print a trailing newline.
    -Q|--silent             Disable `stderr' and `stdout' outputs.
    -q|--quiet              Disable `stdout' output.
    -t|--title=TITLE        Print TITLE before MSG.
    -v|--version            Print version info and exit.
    -|--                    End the options.

  Values:
    COLOR  Must be a color from the below options.
      `black'
      `red'
      `green'
      `yellow'
      `blue'
      `purple'
      `cyan'
      `white'
    DELIM  Can be any string. By default DELIM is ` '.
    MSG    Can be any string.
    TITLE  Can be any string.

EOF
        exit 0
        ;;
      -n|--no-newline)
        newline=0
        ;;
      -Q|--silent)
        silent=1
        ;;
      -q|--quiet)
        quiet=1
        ;;
      -t|--title)
        title="${_SGL_OPT_VALS[${i}]}"
        ;;
      -v|--version)
        _sgl_version
        ;;
      *)
        _sgl_err SGL "invalid parsed \`${FN}' OPTION \`${opt}'"
        ;;
    esac
  done

  # parse MSG
  [[ ${#_SGL_VALS[@]} -gt 0 ]] || _sgl_err VAL "missing \`${FN}' MSG"
  for val in "${_SGL_VALS[@]}"; do
    if [[ -n "${val}" ]]; then
      if [[ -n "${msg}" ]]; then
        msg="${msg}${mdelim}${val}"
      else
        msg="${val}"
      fi
    fi
  done

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

  # print MSG
  if [[ ${quiet}  -ne 1 ]] && [[ ${SGL_QUIET_PARENT}  -ne 1 ]]  && \
     [[ ${silent} -ne 1 ]] && [[ ${SGL_SILENT_PARENT} -ne 1 ]]; then
    if [[ ${escape} -eq 1 ]]; then
      if [[ ${newline} -eq 1 ]]; then
        printf "%b\n" "${msg}"
      else
        printf '%b' "${msg}"
      fi
    else
      if [[ ${newline} -eq 1 ]]; then
        printf "%s\n" "${msg}"
      else
        printf '%s' "${msg}"
      fi
    fi
  fi
}
readonly -f sgl_print
