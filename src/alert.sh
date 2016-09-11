#!/bin/sh
#
# Notify user of command completion via stdout and xterm.
#
# @dest /usr/bin/alert
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use alert [...OPTION]
# @opt -c|--cmd=STR      Use STR for last command instead of history search.
# @opt -m|--msg=MSG      Use MSG instead of `command finished'.
# @opt -n|--no-color     Disable TITLE color.
# @opt -t|--title=TITLE  Use TITLE instead of `ALERT'.
# @opt -x|--exit=CODE    Set CODE as the last command's exit code. Does not run `exit'.
# @val CODE   Must be an integer in the 0-254 range.
# @val DELIM  Must be a string. By default DELIM is ` '.
# @val MSG    Can be any string.
# @val STR    Can be any string.
# @val TITLE  Can be any string.
# @exit
#   0  success
#   1  user error
#   2  dependency error
#   3  internal error
#   4  script error
################################################################################

################################################################################
## DEFINE FUNCTION
################################################################################

alert()
{
  local cmd
  local msg='command finished'
  local color=1
  local title='ALERT'
  local code
  local trim

  # parse each OPTION
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -c|--cmd)
        if [[ $# -eq 1 ]] || [[ -z "$2" ]] || [[ "$2" =~ ^- ]]; then
          error -C -T -X -- "missing CMD for \`alert' function"
        fi
        cmd="$2"
        shift
        ;;
      --cmd=*)
        cmd="$(/bin/echo -E -n "$1" | /bin/sed -r -e 's/^[^=]+=//')"
        if [[ -z "${cmd}" ]]; then
          error -C -T -X -- "missing CMD for \`alert' function"
        fi
        ;;
      -m|--msg)
        if [[ $# -eq 1 ]] || [[ "$2" =~ ^- ]]; then
          error -C -T -X -- "missing MSG for \`alert' function"
        fi
        msg="$2"
        shift
        ;;
      --msg=*)
        msg="$(/bin/echo -E -n "$1" | /bin/sed -r -e 's/^[^=]+=//')"
        ;;
      -n|--no-color)
        color=0
        ;;
      -t|--title)
        if [[ $# -eq 1 ]] || [[ "$2" =~ ^- ]]; then
          error -C -T -X -- "missing TITLE for \`alert' function"
        fi
        title="$2"
        shift
        ;;
      --title=*)
        title="$(/bin/echo -E -n "$1" | /bin/sed -r -e 's/^[^=]+=//')"
        ;;
      -x|--exit)
        if [[ $# -eq 1 ]] || [[ -z "$2" ]] || [[ "$2" =~ ^- ]]; then
          error -C -T -X -- "missing CODE for \`alert' function"
        fi
        if [[ ! "$2" =~ ^(-[12]|[0-9]+)$ ]] || [[ $2 -gt 254 ]]; then
          error -C -T -X -- "invalid CODE, \`$2', for \`alert' function"
        fi
        code="$2"
        shift
        ;;
      --exit=*)
        code="$(/bin/echo -E -n "$1" | /bin/sed -r -e 's/^[^=]+=//')"
        if [[ ! "${code}" =~ ^(-[12]|[0-9]+)$ ]] || [[ ${code} -gt 254 ]]; then
          error -C -T -X -- "invalid CODE, \`${code}', for \`alert' function"
        fi
        ;;
      *)
        error -C -T -X -- "invalid OPTION, \`$1', for \`alert' function"
        ;;
    esac
    shift
  done

  # get CMD from history
  if [[ -z "${cmd}" ]]; then
    trim='s/^[ \t]*[0-9]+[ \t]*//'
    cmd="$(history | /usr/bin/tail -n2 | /bin/sed -r -e '2 d' -e "${trim}")"
  fi

  # color TITLE
  if [[ ${color} -eq 1 ]] && [[ -n "${title}" ]]; then
    if [[ -n "${code}" ]] && [[ ${code} -gt 0 ]]; then
      title="${RED}${title}${NC}"
    else
      title="${GREEN}${title}${NC}"
    fi
  fi

  # build CMD
  cmd="  CMD: \`${cmd}'$(/usr/bin/printf '\n')"

  # build CODE
  if [[ -n "${code}" ]]; then
    code="  EXIT: \`${code}'$(/usr/bin/printf '\n')"
  fi

  # build MSG
  if [[ -n "${title}" ]]; then
    if [[ -n "${msg}" ]]; then
      msg="${title} ${msg}"
    else
      msg="${title}"
    fi
  fi
  msg="${msg}$(/usr/bin/printf '\n')"
  msg="${msg}${cmd}"
  if [[ -n "${code}" ]]; then
    msg="${msg}${code}"
  fi

  # print MSG
  /usr/bin/xterm -hold +cm +uc -ulc -ulit -b 20 \
    -title 'alert' +fullscreen +maximized       \
    -geometry '120x30+120+60'                   \
    -bg '#2E3436' -fg '#FEFEFE'                 \
    -fa 'Source Code Pro Medium' -fs 12         \
    -e /bin/echo "${msg}"
}

################################################################################
## RUN FUNCTION
################################################################################

[ "$0" = '/usr/bin/alert' ] && alert "$@"
