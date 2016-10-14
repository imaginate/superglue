#!/bin/bash
#
# @dest /lib/superglue/sgl_set_color
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl_source set_color
# @return
#   0  PASS
################################################################################

############################################################
# @func sgl_set_color
# @use sgl_set_color [...OPTION] [...COLOR[=ANSI]]
# @opt -d|--disable  Disable each COLOR or all colors if no COLOR is defined.
# @opt -e|--enable   Enable each COLOR or all colors if no COLOR is defined.
# @opt -h|-?|--help  Print help info and exit.
# @opt -Q|--silent   Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet    Disable `stdout' output.
# @opt -r|--reset    Reset each COLOR or all colors if no COLOR is defined.
# @opt -v|--version  Print version info and exit.
# @opt -|--          End the options.
# @val ANSI   Must be an ANSI color code with or without evaluated escapes and
#             form (e.g. `36', `0;36m', `\e[0;36m', or `\033[0;36m').
# @val COLOR  Must be a color from the below options. If a COLOR is defined
#             without any OPTION or ANSI then the COLOR is reset.
#   `black'
#   `red'
#   `green'
#   `yellow'
#   `blue'
#   `purple'
#   `cyan'
#   `white'
# @return
#   0  PASS
############################################################
sgl_set_color()
{
  local -r FN='sgl_set_color'
  local -r E="$(printf '%b' '\033')"
  local -i i
  local -i len
  local -i reset=0
  local -i disable=0
  local -i quiet=${SGL_QUIET}
  local -i silent=${SGL_SILENT}
  local color
  local ansi
  local opt

  # parse each argument
  _sgl_parse_args "${FN}" \
    '-d|--disable' 0 \
    '-e|--enable'  0 \
    '-h|-?|--help' 0 \
    '-Q|--silent'  0 \
    '-q|--quiet'   0 \
    '-r|--reset'   0 \
    '-v|--version' 0 \
    -- "$@"

  # parse each OPTION
  len=${#_SGL_OPTS[@]}
  for ((i=0; i<len; i++)); do
    opt="${_SGL_OPTS[${i}]}"
    case "${opt}" in
      -d|--disable)
        disable=1
        reset=0
        ;;
      -e|--enable)
        disable=0
        reset=1
        ;;
      -h|-\?|--help)
        ${cat} <<'EOF'

  sgl_set_color [...OPTION] [...COLOR[=ANSI]]

  Options:
    -d|--disable  Disable a COLOR or all colors.
    -e|--enable   Enable a COLOR or all colors.
    -h|-?|--help  Print help info and exit.
    -Q|--silent   Disable `stderr' and `stdout' outputs.
    -q|--quiet    Disable `stdout' output.
    -r|--reset    Reset a COLOR or all colors.
    -v|--version  Print version info and exit.
    -|--          End the options.

  Values:
    ANSI   Must be an ANSI color code with or without evaluated escapes and
           form (e.g. `36', `0;36m', `\e[0;36m', or `\033[0;36m').
    COLOR  Must be a color from the below options. If a COLOR is defined
           without any OPTION or ANSI then the COLOR is reset.
      `black'
      `red'
      `green'
      `yellow'
      `blue'
      `purple'
      `cyan'
      `white'

EOF
        exit 0
        ;;
      -Q|--silent)
        silent=1
        ;;
      -q|--quiet)
        quiet=1
        ;;
      -r|--reset)
        disable=0
        reset=1
        ;;
      -v|--version)
        _sgl_version
        ;;
      *)
        _sgl_err SGL "invalid parsed \`${FN}' OPTION \`${opt}'"
        ;;
    esac
  done

  # parse and set each COLOR
  if [[ ${#_SGL_VALS[@]} -gt 0 ]]; then
    for color in "${_SGL_VALS[@]}"; do
      if [[ "${color}" =~ = ]]; then
        ansi="$(printf '%s' "${color}" | ${sed} -e 's/^[^=]*=//' \
          -e 's/^\('"$E"'\|\\e\|\\033\)//' -e 's/^\[//' -e 's/m$//')"
        color="$(printf '%s' "${color}" | ${sed} -e 's/=.*$//')"
      fi
      case "${color}" in
        uncolor) ;;
        black)   ;;
        red)     ;;
        green)   ;;
        yellow)  ;;
        blue)    ;;
        purple)  ;;
        cyan)    ;;
        white)   ;;
        *)
          _sgl_err VAL "invalid \`${FN}' COLOR \`${color}'"
          ;;
      esac
      if [[ -n "${ansi}" ]]; then
        if [[ ! "${ansi}" =~ ^[0-9]{1,3}(;[0-9]{1,3})*$ ]]; then
          _sgl_err VAL "invalid \`${FN}' ANSI \`${ansi}'"
        fi
        ansi="${E}[${ansi}m"
      fi
      if [[ ${disable} -eq 1 ]]; then
        case "${color}" in
          uncolor) SGL_UNCOLOR='' ;;
          black)   SGL_BLACK=''   ;;
          red)     SGL_RED=''     ;;
          green)   SGL_GREEN=''   ;;
          yellow)  SGL_YELLOW=''  ;;
          blue)    SGL_BLUE=''    ;;
          purple)  SGL_PURPLE=''  ;;
          cyan)    SGL_CYAN=''    ;;
          white)   SGL_WHITE=''   ;;
        esac
      elif [[ ${reset} -eq 1 ]] || [[ -z "${ansi}" ]]; then
        case "${color}" in
          uncolor) SGL_UNCOLOR="${_SGL_UNCOLOR}" ;;
          black)   SGL_BLACK="${_SGL_BLACK}"     ;;
          red)     SGL_RED="${_SGL_RED}"         ;;
          green)   SGL_GREEN="${_SGL_GREEN}"     ;;
          yellow)  SGL_YELLOW="${_SGL_YELLOW}"   ;;
          blue)    SGL_BLUE="${_SGL_BLUE}"       ;;
          purple)  SGL_PURPLE="${_SGL_PURPLE}"   ;;
          cyan)    SGL_CYAN="${_SGL_CYAN}"       ;;
          white)   SGL_WHITE="${_SGL_WHITE}"     ;;
        esac
      else
        case "${color}" in
          uncolor) SGL_UNCOLOR="${ansi}" ;;
          black)   SGL_BLACK="${ansi}"   ;;
          red)     SGL_RED="${ansi}"     ;;
          green)   SGL_GREEN="${ansi}"   ;;
          yellow)  SGL_YELLOW="${ansi}"  ;;
          blue)    SGL_BLUE="${ansi}"    ;;
          purple)  SGL_PURPLE="${ansi}"  ;;
          cyan)    SGL_CYAN="${ansi}"    ;;
          white)   SGL_WHITE="${ansi}"   ;;
        esac
      fi
    done

  # set all colors
  else
    if [[ ${disable} -eq 1 ]]; then
      SGL_UNCOLOR=''
      SGL_BLACK=''
      SGL_RED=''
      SGL_GREEN=''
      SGL_YELLOW=''
      SGL_BLUE=''
      SGL_PURPLE=''
      SGL_CYAN=''
      SGL_WHITE=''
    else
      SGL_UNCOLOR="${_SGL_UNCOLOR}"
      SGL_BLACK="${_SGL_BLACK}"
      SGL_RED="${_SGL_RED}"
      SGL_GREEN="${_SGL_GREEN}"
      SGL_YELLOW="${_SGL_YELLOW}"
      SGL_BLUE="${_SGL_BLUE}"
      SGL_PURPLE="${_SGL_PURPLE}"
      SGL_CYAN="${_SGL_CYAN}"
      SGL_WHITE="${_SGL_WHITE}"
    fi
  fi
}
readonly -f sgl_set_color
