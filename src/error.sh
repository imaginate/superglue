#!/bin/sh
#
# Print error message to stdout and optionally exit.
#
# @dest /usr/bin/error
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use error [...OPTION] [...MSG]
# @opt -c|--color[=COLOR]     Color MSG with COLOR (default= `red').
# @opt -C|--COLOR[=COLOR]     Color TITLE with COLOR (default= `red').
# @opt -d|--delim=DELIM       Deliminate each MSG with DELIM.
# @opt -D|--DELIM=DELIM       Deliminate TITLE and MSG with DELIM.
# @opt -r|-R|--return=CODE    Return with CODE.
# @opt -t|-T|--title[=TITLE]  Print title before MSG (default= `ERROR').
# @opt -x|-X|--exit[=CODE]    Exit with CODE (default= `1').
# @opt -?|-h|--help           Print help info and exit.
# @opt -|--                   End the options.
# @val CODE   Must be an integer in the 0-254 range.
# @val COLOR  Must be one of the below colors.
#   `black'   Uses $BLACK.
#   `red'     Uses $RED.
#   `green'   Uses $GREEN.
#   `yellow'  Uses $YELLOW.
#   `blue'    Uses $BLUE.
#   `purple'  Uses $PURPLE.
#   `cyan'    Uses $CYAN.
#   `white'   Uses $WHITE.
# @val DELIM  Must be a string. By default DELIM is ` '.
# @val MSG    Must be a string.
# @val TITLE  Must be a string.
# @return
#   0-254  User defined `--return' CODE (default= `0').
################################################################################

################################################################################
## DEFINE FUNCTION
################################################################################

error()
{
  local color='red'
  local COLOR='red'
  local rcode=0
  local xcode=1
  local delim=' '
  local DELIM=' '
  local title='ERROR'
  local msg
  local c=0
  local C=0
  local t=0
  local x=0

  if [[ $# -lt 1 ]] || [[ "$1" =~ ^-(\?|h|-help)$ ]]; then
    /bin/cat <<'EOF'

  error [...OPTION] [...MSG]

  Options:
    -c|--color[=COLOR]     Color MSG with COLOR (default= `red').
    -C|--COLOR[=COLOR]     Color TITLE with COLOR (default= `red').
    -d|--delim=DELIM       Deliminate each MSG with DELIM.
    -D|--DELIM=DELIM       Deliminate TITLE and MSG with DELIM.
    -r|-R|--return=CODE    Return with CODE.
    -t|-T|--title[=TITLE]  Print title before MSG (default= `ERROR').
    -x|-X|--exit[=CODE]    Exit with CODE (default= `1').
    -?|-h|--help           Print help info and exit.
    -|--                   End the options.

  Values:
    CODE   Must be an integer in the 0-254 range.
    COLOR  Must be one of the below colors.
      `black'   Uses $BLACK.
      `red'     Uses $RED.
      `green'   Uses $GREEN.
      `yellow'  Uses $YELLOW.
      `blue'    Uses $BLUE.
      `purple'  Uses $PURPLE.
      `cyan'    Uses $CYAN.
      `white'   Uses $WHITE.
    DELIM  Must be a string. By default DELIM is ` '.
    MSG    Must be a string.
    TITLE  Must be a string.

  Returns:
    0-254  User defined `--return' CODE (default= `0').

EOF
    exit 0
  fi

  # parse each OPTION
  while [[ $# -gt 0 ]] && [[ "$1" =~ ^- ]]; do
    case "$1" in
      -c|--color)
        if [[ $# -gt 1 ]] && [[ -n "$2" ]] && [[ ! "$2" =~ ^- ]]; then
          color="$2"
          shift
        fi
        c=1
        ;;
      --color=*)
        color="$(/bin/echo -E -n "$1" | /bin/sed -r -e 's/^[^=]+=//')"
        c=1
        ;;
      -C|--COLOR)
        if [[ $# -gt 1 ]] && [[ -n "$2" ]] && [[ ! "$2" =~ ^- ]]; then
          COLOR="$2"
          shift
        fi
        C=1
        ;;
      --COLOR=*)
        COLOR="$(/bin/echo -E -n "$1" | /bin/sed -r -e 's/^[^=]+=//')"
        C=1
        ;;
      -d|--delim)
        if [[ $# -eq 1 ]]; then
          /bin/echo "ERROR missing DELIM for \`error' function" 1>&2
          exit 1
        fi
        delim="$2"
        shift
        ;;
      --delim=*)
        delim="$(/bin/echo -E -n "$1" | /bin/sed -r -e 's/^[^=]+=//')"
        ;;
      -D|--DELIM)
        if [[ $# -eq 1 ]]; then
          /bin/echo "ERROR missing DELIM for \`error' function" 1>&2
          exit 1
        fi
        DELIM="$2"
        shift
        ;;
      --DELIM=*)
        DELIM="$(/bin/echo -E -n "$1" | /bin/sed -r -e 's/^[^=]+=//')"
        ;;
      -r|-R|--return)
        if [[ $# -eq 1 ]] || [[ -z "$2" ]] || [[ "$2" =~ ^- ]]; then
          /bin/echo "ERROR missing \`$1' CODE for \`error' function" 1>&2
          exit 1
        fi
        rcode="$2"
        shift
        ;;
      --return=*)
        rcode="$(/bin/echo -E -n "$1" | /bin/sed -r -e 's/^[^=]+=//')"
        ;;
      -t|-T|--title)
        if [[ $# -gt 1 ]] && [[ -n "$2" ]] && [[ ! "$2" =~ ^- ]]; then
          title="$2"
          shift
        fi
        t=1
        ;;
      --title=*)
        title="$(/bin/echo -E -n "$1" | /bin/sed -r -e 's/^[^=]+=//')"
        t=1
        ;;
      -x|-X|--exit)
        if [[ $# -gt 1 ]] && [[ -n "$2" ]] && [[ ! "$2" =~ ^- ]]; then
          xcode="$2"
          shift
        fi
        x=1
        ;;
      --exit=*)
        xcode="$(/bin/echo -E -n "$1" | /bin/sed -r -e 's/^[^=]+=//')"
        x=1
        ;;
      -|--)
        shift
        break
        ;;
      *)
        /bin/echo "ERROR invalid OPTION, \`$1', for \`error' function" 1>&2
        exit 1
        ;;
    esac
    shift
  done

  # check `--color' COLOR
  if [[ ${c} -eq 1 ]]; then
    case "${color}" in
      black)
        color="${BLACK}"
        ;;
      red)
        color="${RED}"
        ;;
      green)
        color="${GREEN}"
        ;;
      yellow)
        color="${YELLOW}"
        ;;
      blue)
        color="${BLUE}"
        ;;
      purple)
        color="${PURPLE}"
        ;;
      cyan)
        color="${CYAN}"
        ;;
      white)
        color="${WHITE}"
        ;;
      *)
        /bin/echo "ERROR invalid \`--color' COLOR, \`${color}', for \`error' function" 1>&2
        exit 1
        ;;
    esac
  fi

  # check `--COLOR' COLOR
  if [[ ${C} -eq 1 ]]; then
    case "${COLOR}" in
      black)
        COLOR="${BLACK}"
        ;;
      red)
        COLOR="${RED}"
        ;;
      green)
        COLOR="${GREEN}"
        ;;
      yellow)
        COLOR="${YELLOW}"
        ;;
      blue)
        COLOR="${BLUE}"
        ;;
      purple)
        COLOR="${PURPLE}"
        ;;
      cyan)
        COLOR="${CYAN}"
        ;;
      white)
        COLOR="${WHITE}"
        ;;
      *)
        /bin/echo "ERROR invalid \`--COLOR' COLOR, \`${COLOR}', for \`error' function" 1>&2
        exit 1
        ;;
    esac
  fi

  # check `--return' CODE
  if [[ ! "${rcode}" =~ ^[0-9]+$ ]] || [[ ${rcode} -gt 254 ]]; then
    /bin/echo "ERROR invalid \`--return' CODE, \`${rcode}', for \`error' function" 1>&2
    exit 1
  fi

  # check `--exit' CODE
  if [[ ${x} -eq 1 ]]; then
    if [[ ! "${xcode}" =~ ^[0-9]+$ ]] || [[ ${xcode} -gt 254 ]]; then
      /bin/echo "ERROR invalid \`--exit' CODE, \`${xcode}', for \`error' function" 1>&2
      exit 1
    fi
  fi

  # parse each MSG
  while [[ $# -gt 0 ]]; do
    if [[ -n "$1" ]]; then
      if [[ -n "${msg}" ]]; then
        msg="${msg}${delim}$1"
      else
        msg="$1"
      fi
    fi
    shift
  done

  # color MSG
  if [[ ${c} -eq 1 ]] && [[ -n "${msg}" ]]; then
    msg="${color}${msg}${NC}"
  fi

  # color TITLE
  if [[ ${C} -eq 1 ]] && [[ ${t} -eq 1 ]] && [[ -n "${title}" ]]; then
    title="${COLOR}${title}${NC}"
  fi

  # append TITLE
  if [[ ${t} -eq 1 ]] && [[ -n "${title}" ]]; then
    if [[ -n "${msg}" ]]; then
      msg="${title}${DELIM}${msg}"
    else
      msg="${title}"
    fi
  fi

  # print MSG
  if [[ -n "${msg}" ]]; then
    /bin/echo "${msg}" 1>&2
  fi

  # exit
  if [[ ${x} -eq 1 ]]; then
    exit ${xcode}
  fi

  return ${rcode}
}

################################################################################
## RUN FUNCTION
################################################################################

[ "$0" = '/usr/bin/error' ] && error "$@"
