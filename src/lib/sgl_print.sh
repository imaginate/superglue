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
# Flexibly print a message to `stdout' or a destination of choice.
#
# @func sgl_print
# @use sgl_print [...OPTION] ...MSG
# @opt -C|--color-title=COLOR  Color TITLE with COLOR.
# @opt -c|--color[-msg]=COLOR  Color MSG with COLOR.
# @opt -D|--delim-title=DELIM  Deliminate TITLE and MSG with DELIM.
# @opt -d|--delim[-msg]=DELIM  Deliminate each MSG with DELIM.
# @opt -E|--no-escape          Do not evaluate escapes in MSG.
# @opt -e|--escape             Do evaluate escapes in MSG.
# @opt -h|-?|--help            Print help info and exit.
# @opt -N|--no-color           Disable colored TITLE or MSG outputs.
# @opt -n|--no-newline         Do not print a trailing newline.
# @opt -o|--out=DEST           Print this message to DEST.
# @opt -P|--child              Mark this output as one for a child process.
# @opt -p|--parent             Mark this output as one for a parent process.
# @opt -Q|--silent             Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet              Disable `stdout' output.
# @opt -T|--no-title           Disable any TITLE to be printed.
# @opt -t|--title=TITLE        Print TITLE before MSG.
# @opt -v|--version            Print version info and exit.
# @opt -|--                    End the options.
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
# @val DELIM  Can be any string. By default DELIM is ` '.
# @val DEST   Must be `1|stdout', `2|stderr', or a valid file path.
# @val MSG    Can be any string. May be provided via a piped `stdin'.
# @val TITLE  Can be any string.
# @return
#   0  PASS
############################################################
sgl_print()
{
  local -r FN='sgl_print'
  local -i i
  local -i len
  local -i child=0
  local -i escape=0
  local -i newline=1
  local -i quiet=${SGL_QUIET}
  local -i silent=${SGL_SILENT}
  local tcolor
  local mcolor
  local tdelim=' '
  local mdelim=' '
  local format
  local title
  local msg
  local out=1
  local opt
  local val

  # parse each argument
  _sgl_parse_args "${FN}" \
    '-C|--color-title'  1 \
    '-c|--color|--color-msg' 1 \
    '-D|--delim-title'  1 \
    '-d|--delim|--delim-msg' 1 \
    '-E|--no-escape'    0 \
    '-e|--escape'       0 \
    '-h|-?|--help'      0 \
    '-N|--no-color'     0 \
    '-n|--no-newline'   0 \
    '-o|--out'          1 \
    '-P|--child'        0 \
    '-p|--parent'       0 \
    '-Q|--silent'       0 \
    '-q|--quiet'        0 \
    '-T|--no-title'     0 \
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
      -E|--no-escape)
        escape=0
        ;;
      -e|--escape)
        escape=1
        ;;
      -h|-\?|--help)
        _sgl_help sgl_print
        ;;
      -N|--no-color)
        tcolor=''
        mcolor=''
        ;;
      -n|--no-newline)
        newline=0
        ;;
      -o|--out)
        val="${_SGL_OPT_VALS[${i}]}"
        case "${val}" in
          1|stdout)
            out=1
            ;;
          2|stderr)
            out=2
            ;;
          *)
            [[ -f "${val}" ]] || _sgl_err VAL "invalid \`${FN}' DEST \`${val}'"
            out="${val}"
            ;;
        esac
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
      -T|--no-title)
        title=''
        ;;
      -t|--title)
        title="${_SGL_OPT_VALS[${i}]}"
        ;;
      -v|--version)
        _sgl_version
        ;;
    esac
  done

  # update quiet and silent
  if [[ ${child} -eq 1 ]]; then
    [[ ${SGL_SILENT_CHILD} -eq 1 ]] && silent=1
    [[ ${SGL_QUIET_CHILD}  -eq 1 ]] && quiet=1
  else
    [[ ${SGL_SILENT_PARENT} -eq 1 ]] && silent=1
    [[ ${SGL_QUIET_PARENT}  -eq 1 ]] && quiet=1
  fi

  # parse MSG
  if [[ ${#_SGL_VALS[@]} -eq 0 ]]; then
    if [[ -p /dev/stdin ]]; then
      msg="$(${cat} /dev/stdin)"
    elif [[ -p /dev/fd/0 ]]; then
      msg="$(${cat} /dev/fd/0)"
    else
      [[ ${silent} -eq 1 ]] && _sgl_err VAL
      _sgl_err VAL "missing \`${FN}' MSG"
    fi
  else
    for val in "${_SGL_VALS[@]}"; do
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

  # print MSG
  case "${out}" in
    1)
      if [[ ${quiet}  -ne 1 ]] && [[ ${silent} -ne 1 ]]; then
        printf "${format}" "${msg}"
      fi
      ;;
    2)
      [[ ${silent} -ne 1 ]] && printf "${format}" "${msg}" 1>&2
      ;;
    *)
      printf "${format}" "${msg}" >> "${out}"
      ;;
  esac
}
readonly -f sgl_print
