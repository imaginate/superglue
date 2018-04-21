# @dest $LIB/superglue/sgl_err
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
#
# @use sgl_source err
# @return
#   0  PASS
################################################################################

_sgl_source err get_color get_quiet get_silent get_verbose help is_color \
  is_true parse_args version

############################################################
# @public
# @func sgl_err
# @use sgl_err [...OPTION] ERR ...MSG
# @opt -b|--no-color             Disable colored TITLE or MSG outputs.
# @opt -C|--color-title[=COLOR]  Color TITLE with COLOR (default= `red').
# @opt -c|--color[-msg][=COLOR]  Color MSG with COLOR (default= `red').
# @opt -D|--delim-title=DELIM    Deliminate TITLE and MSG with DELIM.
# @opt -d|--delim[-msg]=DELIM    Deliminate each MSG with DELIM.
# @opt -E|--no-escape            Do not evaluate escapes in MSG (default).
# @opt -e|--escape               Do evaluate escapes in MSG.
# @opt -h|-?|--help              Print help info and exit.
# @opt -N|--newline              Do print a trailing newline (default).
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
#   `ERR'   An unknown error (exit= `1').
#   `MISC'  A general error (exit= `1').
#   `OPT'   An invalid option (exit= `2').
#   `VAL'   An invalid or missing value (exit= `3').
#   `AUTH'  A permissions error (exit= `4').
#   `DPND'  A dependency error (exit= `5').
#   `CHLD'  A child process exited unsuccessfully (exit= `6').
#   `SGL'   A `superglue' script error (exit= `7').
# @val MSG    Can be any string. If no MSG is provided or only
#             one MSG equal to `-' is provided then MSG must
#             be provided via `stdin'.
# @val TITLE  Can be any string.
# @exit
#   1  ERR   An unknown error.
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
  local -i i=0
  local -i len
  local -i ret=0
  local -i code=0
  local -i child=-1
  local -i escape=0
  local -i newline=1
  local -i override=0
  local -i quiet=$(_sgl_get_quiet)
  local -i silent=$(_sgl_get_silent)
  local -i verbose=$(_sgl_get_verbose)
  local -i fromstdin=0
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
  _sgl_parse_args ${FN} \
    '-b|--no-color'          0 \
    '-C|--color-title'       2 \
    '-c|--color|--color-msg' 2 \
    '-D|--delim-title'       1 \
    '-d|--delim|--delim-msg' 1 \
    '-E|--no-escape'         0 \
    '-e|--escape'            0 \
    '-h|-?|--help'           0 \
    '-N|--newline'           0 \
    '-n|--no-newline'        0 \
    '-P|--child'             0 \
    '-p|--parent'            0 \
    '-Q|--silent'            0 \
    '-q|--quiet'             0 \
    '-r|--return'            0 \
    '-T|--no-title'          0 \
    '-t|--title'             1 \
    '-V|--verbose'           0 \
    '-v|--version'           0 \
    -- "${@}"

  # parse each OPTION
  if [[ ${#_SGL_OPTS[@]} -gt 0 ]]; then
    for opt in "${_SGL_OPTS[@]}"; do
      case "${opt}" in
        -b|--no-color)
          tcolor=''
          mcolor=''
          ;;
        -C|--color-title)
          if [[ ${_SGL_OPT_BOOL[${i}]} -eq 1 ]]; then
            val="${_SGL_OPT_VALS[${i}]}"
            if ! _sgl_is_color "${val}"; then
              _sgl_err VAL "invalid \`${FN}' \`${opt}' COLOR \`${val}'"
            fi
            tcolor="$(_sgl_get_color "${val}")"
          else
            tcolor="$(_sgl_get_color red)"
          fi
          ;;
        -c|--color|--color-msg)
          if [[ ${_SGL_OPT_BOOL[${i}]} -eq 1 ]]; then
            val="${_SGL_OPT_VALS[${i}]}"
            if ! _sgl_is_color "${val}"; then
              _sgl_err VAL "invalid \`${FN}' \`${opt}' COLOR \`${val}'"
            fi
            mcolor="$(_sgl_get_color "${val}")"
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
          _sgl_help ${FN}
          ;;
        -N|--newline)
          newline=1
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
      i=$(( i + 1 ))
    done
  fi

  # save values length
  len=${#_SGL_VALS[@]}

  # save ERR ref
  if [[ ${len} -gt 0 ]]; then
    err="${_SGL_VALS[0]}"
  fi

  # update process level
  if [[ ${child} -eq -1 ]] && [[ "${err}" == 'CHLD' ]]; then
    child=1
  fi

  # update quiet and silent
  if [[ ${child} -eq 1 ]]; then
    if [[ ${quiet} -ne 1 ]]; then
      quiet=$(_sgl_get_quiet CHLD)
    fi
    if [[ ${silent} -ne 1 ]]; then
      silent=$(_sgl_get_silent CHLD)
    fi
  else
    if [[ ${quiet} -ne 1 ]]; then
      quiet=$(_sgl_get_quiet PRT)
    fi
    if [[ ${silent} -ne 1 ]]; then
      silent=$(_sgl_get_silent PRT)
    fi
  fi

  # parse ERR
  if [[ ${len} -eq 0 ]]; then
    _sgl_err VAL "missing \`${FN}' ERR"
  fi
  case "${err}" in
    ERR|MISC)
      if [[ ${override} -eq 0 ]]; then
        title='ERROR'
      fi
      code=1
      ;;
    OPT)
      if [[ ${override} -eq 0 ]]; then
        title='OPTION ERROR'
      fi
      code=2
      ;;
    VAL)
      if [[ ${override} -eq 0 ]]; then
        title='VALUE ERROR'
      fi
      code=3
      ;;
    AUTH)
      if [[ ${override} -eq 0 ]]; then
        title='AUTHORITY ERROR'
      fi
      code=4
      ;;
    DPND)
      if [[ ${override} -eq 0 ]]; then
        title='DEPENDENCY ERROR'
      fi
      code=5
      ;;
    CHLD)
      if [[ ${override} -eq 0 ]]; then
        title='CHILD ERROR'
      fi
      code=6
      ;;
    SGL)
      if [[ ${override} -eq 0 ]]; then
        title='SUPERGLUE ERROR'
      fi
      code=7
      ;;
    *)
      if [[ ! "${err}" =~ ^[1-9][0-9]{,2}$ ]] || [[ ${err} -gt 126 ]]; then
        _sgl_err VAL "invalid \`${FN}' ERR \`${err}'"
      fi
      if [[ ${override} -eq 0 ]]; then
        title='ERROR'
      fi
      code=${err}
      ;;
  esac

  # check if MSG is provided via `stdin'
  if [[ ${len} -eq 1 ]]; then
    fromstdin=1
  elif [[ ${len} -eq 2 ]] && [[ "${_SGL_VALS[1]}" == '-' ]]; then
    fromstdin=1
  fi

  # parse each MSG
  if [[ ${fromstdin} -eq 1 ]]; then
    if ! read -t 0 val; then
      _sgl_err VAL "missing \`${FN}' MSG"
    fi
    while IFS= read -r val; do
      if [[ -n "${msg}" ]]; then
        msg="${msg}${NEWLINE}${val}"
      else
        msg="${val}"
      fi
    done
  else
    for val in "${_SGL_VALS[@]:1}"; do
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
    if _sgl_is_true "${SGL_COLOR_ON}"; then
      title="${tcolor}${title}${SGL_UNCOLOR}"
    elif ! _sgl_is_true "${SGL_COLOR_OFF}" && [[ -t 1 ]]; then
      title="${tcolor}${title}${SGL_UNCOLOR}"
    fi
  fi

  # color MSG
  if [[ -n "${mcolor}" ]] && [[ -n "${msg}" ]]; then
    if _sgl_is_true "${SGL_COLOR_ON}"; then
      msg="${mcolor}${msg}${SGL_UNCOLOR}"
    elif ! _sgl_is_true "${SGL_COLOR_OFF}" && [[ -t 1 ]]; then
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
  if [[ ${newline} -eq 1 ]]; then
    format="${format}\n"
  fi

  # print the error MSG
  if [[ ${silent} -ne 1 ]]; then
    printf "${format}" "${msg}" 1>&2
    if [[ ${verbose} -eq 1 ]]; then
      local details="$(caller)"
      printf "%s\n" "- LINE ${details%% *}" 1>&2
      printf "%s\n" "- FILE ${details##* }" 1>&2
    fi
  fi

  if [[ ${ret} -eq 1 ]]; then
    return ${code}
  fi
  exit ${code}
}
readonly -f sgl_err
