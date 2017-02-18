#!/bin/bash
#
# @dest $LIB/superglue/sgl_color
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl_source color
# @return
#   0  PASS
################################################################################

_sgl_source err get_color get_quiet get_silent help is_set parse_args version

############################################################
# Easily print a colored message to `stdout'.
#
# @func sgl_color
# @use sgl_color [...OPTION] COLOR ...MSG
# @opt -d|--delim=DELIM  Use DELIM to deliminate each MSG.
# @opt -h|-?|--help      Print help info and exit.
# @opt -l|--loud         Do not disable `stdout' output.
# @opt -N|--newline      Do print a trailing newline.
# @opt -n|--no-newline   Do not print a trailing newline (default).
# @opt -Q|--silent       Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet        Disable `stdout' output.
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
# @val MSG    Can be any string. If no MSG is provided or only
#             one MSG equal to `-' is provided then MSG must
#             be provided via `stdin'.
# @return
#   0  PASS
# @exit-on-error
#   1  ERR   An unknown error.
#   2  OPT   An invalid option.
#   3  VAL   An invalid or missing value.
#   4  AUTH  A permissions error.
#   5  DPND  A dependency error.
#   6  CHLD  A child process exited unsuccessfully.
#   7  SGL   A `superglue' script error.
############################################################
sgl_color()
{
  local -r FN='sgl_color'
  local -i i
  local -i len
  local -i loud=0
  local -i quiet=$(_sgl_get_quiet PRT)
  local -i silent=$(_sgl_get_silent PRT)
  local -i newline=0
  local -i fromstdin=0
  local color
  local delim=' '
  local msg
  local opt
  local line

  # parse each argument
  _sgl_parse_args ${silent} "${FN}" \
    '-d|--delim'      1 \
    '-h|-?|--help'    0 \
    '-l|--loud'       0 \
    '-N|--newline'    0 \
    '-n|--no-newline' 0 \
    '-Q|--silent'     0 \
    '-q|--quiet'      0 \
    '-v|--version'    0 \
    -- "${@}"

  # parse each OPTION
  len=${#_SGL_OPTS[@]}
  for (( i=0; i<len; i++ )); do
    opt="${_SGL_OPTS[${i}]}"
    case "${opt}" in
      -d|--delim)
        delim="${_SGL_OPT_VALS[${i}]}"
        ;;
      -h|-\?|--help)
        _sgl_help ${FN}
        ;;
      -l|--loud)
        loud=1
        ;;
      -N|--newline)
        newline=1
        ;;
      -n|--no-newline)
        newline=0
        ;;
      -Q|--silent)
        silent=1
        loud=0
        ;;
      -q|--quiet)
        quiet=1
        loud=0
        ;;
      -v|--version)
        _sgl_version
        ;;
      *)
        _sgl_err ${silent} SGL "invalid parsed \`${FN}' OPTION \`${opt}'"
        ;;
    esac
  done

  # save values length
  len=${#_SGL_VALS[@]}

  # parse COLOR
  if [[ ${len} -eq 0 ]]; then
    _sgl_err ${silent} VAL "missing \`${FN}' COLOR"
  fi
  color="$(_sgl_get_color "${_SGL_VALS[0]}")"
  if [[ ${?} -ne 0 ]]; then
    _sgl_err ${silent} VAL "invalid \`${FN}' COLOR \`${_SGL_VALS[0]}'"
  fi

  # parse MSG
  if [[ ${len} -eq 1 ]]; then
    fromstdin=1
  elif [[ ${len} -eq 2 ]] && [[ "${_SGL_VALS[1]}" == '-' ]]; then
    fromstdin=1
  fi
  if [[ ${fromstdin} -eq 1 ]]; then
    if ! read -t 0 line; then
      _sgl_err ${silent} VAL "missing \`${FN}' MSG"
    fi
    while IFS= read -r line; do
      if [[ -n "${msg}" ]]; then
        msg="${msg}${NEWLINE}${line}"
      else
        msg="${line}"
      fi
    done
  else
    for line in "${_SGL_VALS[@]:1}"; do
      if [[ -n "${line}" ]]; then
        if [[ -n "${msg}" ]]; then
          msg="${msg}${delim}${line}"
        else
          msg="${line}"
        fi
      fi
    done
  fi
  if [[ ${newline} -eq 1 ]]; then
    msg="${msg}${NEWLINE}"
  fi

  # color MSG
  if [[ -n "${color}" ]]; then
    if [[ "${SGL_COLOR_ON}" == '1' ]]; then
      msg="${color}${msg}${SGL_UNCOLOR}"
    elif [[ "${SGL_COLOR_OFF}" != '1' ]] && [[ -t 1 ]]; then
      msg="${color}${msg}${SGL_UNCOLOR}"
    fi
  fi

  if [[ ${loud} -eq 1 ]] || [[ ${quiet} -eq 0 ]]; then
    printf '%s' "${msg}"
  fi

  return 0
}
readonly -f sgl_color

if ! _sgl_is_set _sgl_get_color; then
  # @include ../include/_sgl_get_color.sh
fi
