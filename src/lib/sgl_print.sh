# @dest $LIB/superglue/sgl_print
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl_source print
# @return
#   0  PASS
################################################################################

_sgl_source err get_color get_quiet get_silent help is_color is_file is_true \
  parse_args version

############################################################
# Flexibly print a message to `stdout' or a destination of choice.
#
# @func sgl_print
# @use sgl_print [...OPTION] ...MSG
# @opt -b|--no-color           Disable colored TITLE or MSG outputs.
# @opt -C|--color-title=COLOR  Color TITLE with COLOR.
# @opt -c|--color[-msg]=COLOR  Color MSG with COLOR.
# @opt -D|--delim-title=DELIM  Deliminate TITLE and MSG with DELIM.
# @opt -d|--delim[-msg]=DELIM  Deliminate each MSG with DELIM.
# @opt -E|--no-escape          Do not evaluate escapes in MSG (default).
# @opt -e|--escape             Do evaluate escapes in MSG.
# @opt -h|-?|--help            Print help info and exit.
# @opt -l|--loud               Do not disable `stdout' output.
# @opt -N|--newline            Do print a trailing newline (default).
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
# @val MSG    Can be any string. If no MSG is provided or only
#             one MSG equal to `-' is provided then MSG must
#             be provided via `stdin'.
# @val TITLE  Can be any string.
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
sgl_print()
{
  local -r FN='sgl_print'
  local -i i=0
  local -i loud=0
  local -i child=0
  local -i escape=0
  local -i newline=1
  local -i fromstdin=0
  local -i quiet=$(_sgl_get_quiet)
  local -i silent=$(_sgl_get_silent)
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
  _sgl_parse_args ${FN} \
    '-b|--no-color'          0 \
    '-C|--color-title'       1 \
    '-c|--color|--color-msg' 1 \
    '-D|--delim-title'       1 \
    '-d|--delim|--delim-msg' 1 \
    '-E|--no-escape'         0 \
    '-e|--escape'            0 \
    '-h|-?|--help'           0 \
    '-l|--loud'              0 \
    '-N|--newline'           0 \
    '-n|--no-newline'        0 \
    '-o|--out'               1 \
    '-P|--child'             0 \
    '-p|--parent'            0 \
    '-Q|--silent'            0 \
    '-q|--quiet'             0 \
    '-T|--no-title'          0 \
    '-t|--title'             1 \
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
          tcolor="${_SGL_OPT_VALS[${i}]}"
          if ! _sgl_is_color "${tcolor}"; then
            _sgl_err VAL "invalid \`${FN}' COLOR \`${tcolor}'"
          fi
          tcolor="$(_sgl_get_color "${tcolor}")"
          ;;
        -c|--color|--color-msg)
          mcolor="${_SGL_OPT_VALS[${i}]}"
          if ! _sgl_is_color "${mcolor}"; then
            _sgl_err VAL "invalid \`${FN}' COLOR \`${mcolor}'"
          fi
          mcolor="$(_sgl_get_color "${mcolor}")"
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
        -l|--loud)
          loud=1
          ;;
        -N|--newline)
          newline=1
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
              if ! _sgl_is_file "${val}"; then
                _sgl_err VAL "invalid \`${FN}' DEST \`${val}'"
              fi
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
          loud=0
          ;;
        -q|--quiet)
          quiet=1
          loud=0
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
      i=$(( i + 1 ))
    done
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

  # check if MSG is provided via `stdin'
  case ${#_SGL_VALS[@]} in
    0)
      fromstdin=1
      ;;
    1)
      if [[ "${_SGL_VALS[0]}" == '-' ]]; then
        fromstdin=1
      fi
      ;;
  esac

  # parse MSG
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

  # return if output is silenced
  if [[ ${loud} -ne 1 ]]; then
    if [[ ${silent} -eq 1 ]]; then
      return 0
    elif [[ ${quiet} -eq 1 ]] && [[ "${out}" != '2' ]]; then
      return 0
    fi
  fi

  # print MSG
  case "${out}" in
    1)
      printf "${format}" "${msg}"
      ;;
    2)
      printf "${format}" "${msg}" 1>&2
      ;;
    *)
      printf "${format}" "${msg}" >> "${out}"
      ;;
  esac
  return 0
}
readonly -f sgl_print
