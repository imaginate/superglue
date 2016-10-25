#!/bin/bash
#
# @dest /lib/superglue/sgl_color
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl_source color
# @return
#   0  PASS
################################################################################

############################################################
# Note that SGL_QUIET & SGL_SILENT do not disable printing
# the colored MSG to `stdout'.
#
# @func sgl_color
# @use sgl_color [...OPTION] COLOR ...MSG
# @opt -d|--delim=DELIM  Use DELIM to deliminate each MSG.
# @opt -h|-?|--help      Print help info and exit.
# @opt -v|--version      Print version info and exit.
# @opt -|--              End the options.
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
# @val MSG    Can be any string. May be provided via a piped `stdin'.
# @return
#   0  PASS
############################################################
sgl_color()
{
  local -r FN='sgl_color'
  local -i i
  local -i len
  local color
  local delim=' '
  local msg
  local opt

  # parse each argument
  _sgl_parse_args "${FN}" \
    '-d|--delim'   1 \
    '-h|-?|--help' 0 \
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
      -h|-\?|--help)
        _sgl_help sgl_color
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

  # parse COLOR
  [[ ${len} -gt 0 ]] || _sgl_err VAL "missing \`${FN}' COLOR"
  color="$(_sgl_get_color "${_SGL_VALS[0]}")"
  [[ $? -eq 0 ]] || _sgl_err VAL "invalid \`${FN}' COLOR \`${_SGL_VALS[0]}'"

  # parse MSG
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
      if [[ -n "${_SGL_VALS[${i}]}" ]]; then
        if [[ -n "${msg}" ]]; then
          msg="${msg}${delim}${_SGL_VALS[${i}]}"
        else
          msg="${_SGL_VALS[${i}]}"
        fi
      fi
    done
  fi

  # color MSG
  if [[ -n "${color}" ]]; then
    if [[ ${SGL_COLOR_ON} -eq 1 ]]; then
      msg="${color}${msg}${SGL_UNCOLOR}"
    elif [[ ${SGL_COLOR_OFF} -ne 1 ]] && [[ -t 1 ]]; then
      msg="${color}${msg}${SGL_UNCOLOR}"
    fi
  fi

  printf '%s' "${msg}"
}
readonly -f sgl_color
