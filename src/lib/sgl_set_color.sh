# @dest $LIB/superglue/sgl_set_color
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
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
#   `blue'
#   `cyan'
#   `green'
#   `purple'
#   `red'
#   `white'
#   `yellow'
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

  [[ ${SGL_SILENT_PARENT} -eq 1 ]] && silent=1
  [[ ${SGL_QUIET_PARENT}  -eq 1 ]] && quiet=1

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
        _sgl_help sgl_set_color
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
    esac
  done

  # parse and set each COLOR
  if [[ ${#_SGL_VALS[@]} -gt 0 ]]; then
    for color in "${_SGL_VALS[@]}"; do
      if [[ "${color}" =~ = ]]; then
        ansi="$(printf '%s' "${color#*=}" | ${sed} -e 's/^\[//' -e 's/m$//' \
          -e 's/^\('"$E"'\|\\e\|\\033\)//')"
        color="${color%%=*}"
      fi
      case "${color}" in
        uncolor|Uncolor|UNCOLOR) ;;
        black|Black|BLACK)       ;;
        blue|Blue|BLUE)          ;;
        cyan|Cyan|CYAN)          ;;
        green|Green|GREEN)       ;;
        purple|Purple|PURPLE)    ;;
        red|Red|RED)             ;;
        white|White|WHITE)       ;;
        yellow|Yellow|YELLOW)    ;;
        *)
          [[ ${silent} -eq 1 ]] && _sgl_err VAL
          _sgl_err VAL "invalid \`${FN}' COLOR \`${color}'"
          ;;
      esac
      if [[ -n "${ansi}" ]]; then
        if [[ ! "${ansi}" =~ ^[0-9]{1,3}(;[0-9]{1,3})*$ ]]; then
          [[ ${silent} -eq 1 ]] && _sgl_err VAL
          _sgl_err VAL "invalid \`${FN}' ANSI \`${ansi}'"
        fi
        ansi="${E}[${ansi}m"
      fi
      if [[ ${disable} -eq 1 ]]; then
        case "${color}" in
          uncolor|Uncolor|UNCOLOR) SGL_UNCOLOR='' ;;
          black|Black|BLACK)       SGL_BLACK=''   ;;
          blue|Blue|BLUE)          SGL_BLUE=''    ;;
          cyan|Cyan|CYAN)          SGL_CYAN=''    ;;
          green|Green|GREEN)       SGL_GREEN=''   ;;
          purple|Purple|PURPLE)    SGL_PURPLE=''  ;;
          red|Red|RED)             SGL_RED=''     ;;
          white|White|WHITE)       SGL_WHITE=''   ;;
          yellow|Yellow|YELLOW)    SGL_YELLOW=''  ;;
        esac
      elif [[ ${reset} -eq 1 ]] || [[ -z "${ansi}" ]]; then
        case "${color}" in
          uncolor|Uncolor|UNCOLOR) SGL_UNCOLOR="${_SGL_UNCOLOR}" ;;
          black|Black|BLACK)       SGL_BLACK="${_SGL_BLACK}"     ;;
          blue|Blue|BLUE)          SGL_BLUE="${_SGL_BLUE}"       ;;
          cyan|Cyan|CYAN)          SGL_CYAN="${_SGL_CYAN}"       ;;
          green|Green|GREEN)       SGL_GREEN="${_SGL_GREEN}"     ;;
          purple|Purple|PURPLE)    SGL_PURPLE="${_SGL_PURPLE}"   ;;
          red|Red|RED)             SGL_RED="${_SGL_RED}"         ;;
          white|White|WHITE)       SGL_WHITE="${_SGL_WHITE}"     ;;
          yellow|Yellow|YELLOW)    SGL_YELLOW="${_SGL_YELLOW}"   ;;
        esac
      else
        case "${color}" in
          uncolor|Uncolor|UNCOLOR) SGL_UNCOLOR="${ansi}" ;;
          black|Black|BLACK)       SGL_BLACK="${ansi}"   ;;
          blue|Blue|BLUE)          SGL_BLUE="${ansi}"    ;;
          cyan|Cyan|CYAN)          SGL_CYAN="${ansi}"    ;;
          green|Green|GREEN)       SGL_GREEN="${ansi}"   ;;
          purple|Purple|PURPLE)    SGL_PURPLE="${ansi}"  ;;
          red|Red|RED)             SGL_RED="${ansi}"     ;;
          white|White|WHITE)       SGL_WHITE="${ansi}"   ;;
          yellow|Yellow|YELLOW)    SGL_YELLOW="${ansi}"  ;;
        esac
      fi
    done

  # set all colors
  else
    if [[ ${disable} -eq 1 ]]; then
      SGL_UNCOLOR=''
      SGL_BLACK=''
      SGL_BLUE=''
      SGL_CYAN=''
      SGL_GREEN=''
      SGL_PURPLE=''
      SGL_RED=''
      SGL_WHITE=''
      SGL_YELLOW=''
    else
      SGL_UNCOLOR="${_SGL_UNCOLOR}"
      SGL_BLACK="${_SGL_BLACK}"
      SGL_BLUE="${_SGL_BLUE}"
      SGL_CYAN="${_SGL_CYAN}"
      SGL_GREEN="${_SGL_GREEN}"
      SGL_PURPLE="${_SGL_PURPLE}"
      SGL_RED="${_SGL_RED}"
      SGL_WHITE="${_SGL_WHITE}"
      SGL_YELLOW="${_SGL_YELLOW}"
    fi
  fi
}
readonly -f sgl_set_color
