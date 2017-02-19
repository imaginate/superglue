# @dest $LIB/superglue/sgl_parse_args
# @mode 0644
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl_source parse_args
# @return
#   0  PASS
################################################################################

_sgl_source err get_quiet get_silent help version

############################################################
# This function parses each argument in global indexed array, `SGL_ARGS',
# and saves the resulting options and values to the following global
# zero-based indexed arrays:
#   `SGL_OPTS'      Each parsed option (e.g. `-s' or `--long').
#   `SGL_OPT_BOOL'  Whether each option has a value (`0' or `1').
#   `SGL_OPT_VALS'  The parsed option value.
#   `SGL_VALS'      The remaining (non-option) parsed values.
#
# @public
# @func sgl_parse_args
# @use sgl_parse_args [...OPTION]
# @opt -a|--args|--arguments [...ARG]
#   Override the args to parse (default uses `"${SGL_ARGS[@]}"'). Must be the
#   last OPTION used. Do not use `=' between this OPTION and any ARG.
# @opt -o|--opts|--options [...OPTS[=VAL]] [-|--]
#   Define each acceptable OPT and VAL (default= `0'). If this OPTION is not
#   the last one used, it must use `-' or `--' to indicate the end of OPTS.
#   Do not use `=' between this OPTION and any OPTS. Note that the OPTS
#   `"-|--" NO' is automatically assumed.
# @opt -p|--prg|--program=PRG
#   Define a program name to include in any error messages.
# @opt -Q|--silent   Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet    Disable `stdout' output.
# @opt -v|--version  Print version info and exit.
# @opt -?|-h|--help  Print help info and exit.
# @val ARG   Each original argument. Can be any string.
# @val OPT   A short (e.g. `-o') or long (e.g. `--opt') option pattern.
# @val OPTS  One or more OPT. Use `|' to separate each OPT (e.g. `-o|--opt').
# @val PRG   A program name. Can be any string.
# @val VAL   Indicates whether each OPT accepts a value. Must be a choice from below.
#   `0|N|NO'     The OPT has no value.
#   `1|Y|YES'    The OPT requires a value.
#   `2|M|MAYBE'  The OPT can have a value.
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
sgl_parse_args()
{
  local -r FN='sgl_parse_args'
  local -i a
  local -i i
  local -i u
  local -i len
  local -i ulen
  local -i quiet=$(_sgl_get_quiet PRT)
  local -i silent=$(_sgl_get_silent PRT)
  local -i override=0
  local arg
  local opt
  local prg
  local val
  local -a args
  local -A long
  local -A short

  # parse each OPTION
  while [[ ${#} -gt 0 ]]; do
    if [[ ! "${1}" =~ ^- ]]; then
      _sgl_err VAL "invalid \`${FN}' VALUE \`${1}'"
    fi
    # parse long option
    if [[ "${1}" =~ ^-- ]]; then
      case "${1}" in
        --args|--arguments)
          override=1
          shift
          args=()
          while [[ ${#} -gt 0 ]]; do
            args[${#args[@]}]="${1}"
            shift
          done
          break
          ;;
        --opts|--options)
          shift
          # parse each OPTS and VAL
          while [[ ${#} -gt 0 ]]; do
            # end OPTS
            if [[ "${1}" =~ ^--?$ ]]; then
              shift
              break
            fi
            # save OPTS and VAL refs
            # increment args index
            if [[ "${1}" =~ = ]]; then
              opt="${1%%=*}"
              val="${1#*=}"
              shift
            else
              opt="${1}"
              if [[ ${#} -gt 1 ]] && [[ ! "${2}" =~ ^- ]]; then
                val="${2}"
                shift
              else
                val=0
              fi
              shift
            fi
            # catch invalid chars in OPTS
            if [[ ! "${opt}" =~ ^-[a-zA-Z0-9|?-]+$ ]]; then
              _sgl_err VAL "invalid characters in \`${FN}' OPTS \`${opt}'"
            fi
            # parse VAL
            case "${val}" in
              0|n|no|N|No|NO)
                val=0
                ;;
              1|y|yes|Y|Yes|YES)
                val=1
                ;;
              2|m|maybe|M|Maybe|MAYBE)
                val=2
                ;;
              *)
                _sgl_err VAL "invalid \`${FN}' VAL \`${val}' for OPTS \`${opt}'"
                ;;
            esac
            # parse each OPT in OPTS
            # build short and long hash maps
            while IFS= read -r -d '|' opt; do
              if [[ "${opt}" =~ ^--[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$ ]]; then
                long[${opt}]=${val}
              elif [[ "${opt}" =~ ^-[a-zA-Z0-9?]$ ]]; then
                short[${opt}]=${val}
              else
                _sgl_err VAL "invalid \`${FN}' OPT \`${opt}'"
              fi
            done <<< "${opt}|"
          done
          ;;
        --prg|--program)
          if [[ ${#} -eq 1 ]] || [[ "${2}" =~ ^- ]]; then
            _sgl_err VAL "missing \`${FN}' PRG"
          fi
          prg="${2}"
          shift 2
          ;;
        --prg=*|--program=*)
          prg="${1#*=}"
          shift
          ;;
        --silent)
          silent=1
          shift
          ;;
        --quiet)
          quiet=1
          shift
          ;;
        --version)
          _sgl_version
          ;;
        --help)
          _sgl_help ${FN}
          ;;
        *)
          _sgl_err OPT "invalid \`${FN}' OPTION \`${1}'"
          ;;
      esac
    # parse short options
    else
      i=0
      len="${#1}"
      while :; do
        i=$(( i + 1 ))
        if [[ ${i} -gte ${len} ]]; do
          break
        fi
        arg="-${1:${i}:1}"
        case "${arg}" in
          -a)
            i=$(( i + 1 ))
            if [[ ${i} -ne ${len} ]]; then
              _sgl_err OPT "\`-a' must be the last \`${FN}' OPTION"
            fi
            override=1
            shift
            args=()
            while [[ ${#} -gt 0 ]]; do
              args[${#args[@]}]="${1}"
              shift
            done
            break 2
            ;;
          -o)
            if [[ $(( i + 1 )) -eq ${len} ]]; then
              shift
              # parse each OPTS and VAL
              while [[ ${#} -gt 0 ]]; do
                # end OPTS
                [[ "${1}" =~ ^--?$ ]] && break
                # save OPTS and VAL refs
                # increment args index
                if [[ "${1}" =~ = ]]; then
                  opt="${1%%=*}"
                  val="${1#*=}"
                  shift
                else
                  opt="${1}"
                  if [[ ${#} -gt 1 ]] && [[ ! "${2}" =~ ^- ]]; then
                    val="${2}"
                    shift
                  else
                    val=0
                  fi
                  shift
                fi
                # catch invalid chars in OPTS
                if [[ ! "${opt}" =~ ^-[a-zA-Z0-9|?-]+$ ]]; then
                  _sgl_err VAL "invalid characters in \`${FN}' OPTS \`${opt}'"
                fi
                # parse VAL
                case "${val}" in
                  0|n|no|N|No|NO)
                    val=0
                    ;;
                  1|y|yes|Y|Yes|YES)
                    val=1
                    ;;
                  2|m|maybe|M|Maybe|MAYBE)
                    val=2
                    ;;
                  *)
                    _sgl_err VAL "invalid \`${FN}' VAL \`${val}' for OPTS \`${opt}'"
                    ;;
                esac
                # parse each OPT in OPTS
                # build short and long hash maps
                while IFS= read -r -d '|' opt; do
                  if [[ "${opt}" =~ ^--[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$ ]]; then
                    long[${opt}]=${val}
                  elif [[ "${opt}" =~ ^-[a-zA-Z0-9?]$ ]]; then
                    short[${opt}]=${val}
                  else
                    _sgl_err VAL "invalid \`${FN}' OPT \`${opt}'"
                  fi
                done <<< "${opt}|"
              done
            fi
            ;;
          -p)
            i=$(( i + 1 ))
            if [[ ${i} -lt ${len} ]]; then
              prg="${1:${i}}"
              break
            elif [[ ${#} -eq 1 ]] || [[ "${2}" =~ ^- ]]; then
              _sgl_err VAL "missing \`${FN}' \`-p' PRG"
            else
              prg="${2}"
              shift
            fi
            ;;
          -Q)
            silent=1
            ;;
          -q)
            quiet=1
            ;;
          -v)
            _sgl_version
            ;;
          -\?|-h)
            _sgl_help ${FN}
            ;;
          *)
            _sgl_err OPT "invalid \`${FN}' OPTION \`${arg}'"
            ;;
        esac
      done
      shift
    fi
  done

  # format PRG
  if [[ -n "${prg}" ]]; then
    prg="\`${prg}' "
  fi

  # set args to SGL_ARGS
  if [[ ${override} -eq 0 ]]; then
    args=()
    if [[ ${#SGL_ARGS[@]} -gt 0 ]]; then
      for arg in "${SGL_ARGS[@]}"; do
        args[${#args[@]}]="${arg}"
      done
    fi
  fi

  # reset globals
  SGL_OPTS=()
  SGL_OPT_BOOL=()
  SGL_OPT_VALS=()
  SGL_VALS=()

  # parse each ARG option
  i=-1
  len=${#args[@]}
  while :; do
    i=$(( i + 1 ))
    if [[ ${i} -gte ${len} ]]; then
      break
    fi
    opt="${args[${i}]}"
    # start ARG values
    if [[ ! "${opt}" =~ ^- ]]; then
      break
    fi
    # end ARG options
    if [[ "${opt}" =~ ^--?$ ]]; then
      i=$(( i + 1 ))
      break
    fi
    # parse long ARG option
    if [[ "${opt}" =~ ^-- ]]; then
      # save current index
      a=${#SGL_OPTS[@]}
      # parse long ARG option with `='
      if [[ "${opt}" =~ = ]]; then
        val="${opt#*=}"
        opt="${opt%%=*}"
        case "${long[${opt}]:-x}" in
          0)
            _sgl_err VAL "invalid ${prg}\`${opt}' VALUE"
            ;;
          x)
            _sgl_err OPT "invalid ${prg}OPTION \`${opt}'"
            ;;
        esac
        SGL_OPTS[${a}]="${opt}"
        SGL_OPT_BOOL[${a}]=1
        SGL_OPT_VALS[${a}]="${val}"
      # parse long ARG option without `='
      else
        SGL_OPTS[${a}]="${opt}"
        case "${long[${opt}]:-x}" in
          0)
            SGL_OPT_BOOL[${a}]=0
            SGL_OPT_VALS[${a}]=''
            ;;
          1)
            i=$(( i + 1 ))
            val="${args[${i}]}"
            if [[ ${i} -eq ${len} ]] || [[ "${val}" =~ ^- ]]; then
              _sgl_err VAL "missing ${prg}\`${opt}' VALUE"
            fi
            SGL_OPT_BOOL[${a}]=1
            SGL_OPT_VALS[${a}]="${val}"
            ;;
          2)
            i=$(( i + 1 ))
            val="${args[${i}]}"
            if [[ ${i} -eq ${len} ]] || [[ "${val}" =~ ^- ]]; then
              i=$(( i - 1 ))
              SGL_OPT_BOOL[${a}]=0
              SGL_OPT_VALS[${a}]=''
            else
              SGL_OPT_BOOL[${a}]=1
              SGL_OPT_VALS[${a}]="${val}"
            fi
            ;;
          x)
            _sgl_err OPT "invalid ${prg}OPTION \`${opt}'"
            ;;
        esac
      fi
    # parse short ARG option
    else
      u=0
      arg="${opt}"
      ulen="${#arg}"
      while :; do
        u=$(( u + 1 ))
        if [[ ${u} -gte ${ulen} ]]; then
          break
        fi
        opt="-${arg:${u}:1}"
        a=${#SGL_OPTS[@]}
        SGL_OPTS[${a}]="${opt}"
        case "${short[${opt}]:-x}" in
          0)
            SGL_OPT_BOOL[${a}]=0
            SGL_OPT_VALS[${a}]=''
            ;;
          1)
            SGL_OPT_BOOL[${a}]=1
            u=$(( u + 1 ))
            if [[ ${u} -lt ${ulen} ]]; then
              SGL_OPT_VALS[${a}]="${arg:${u}}"
              break
            fi
            i=$(( i + 1 ))
            val="${args[${i}]}"
            if [[ ${i} -eq ${len} ]] || [[ "${val}" =~ ^- ]]; then
              _sgl_err VAL "missing ${prg}\`${opt}' VALUE"
            else
              SGL_OPT_VALS[${a}]="${val}"
            fi
            ;;
          2)
            u=$(( u + 1 ))
            if [[ ${u} -lt ${ulen} ]]; then
              SGL_OPT_BOOL[${a}]=1
              SGL_OPT_VALS[${a}]="${arg:${u}}"
              break
            fi
            i=$(( i + 1 ))
            val="${args[${i}]}"
            if [[ ${i} -eq ${len} ]] || [[ "${val}" =~ ^- ]]; then
              i=$(( --i ))
              SGL_OPT_BOOL[${a}]=0
              SGL_OPT_VALS[${a}]=''
            else
              SGL_OPT_BOOL[${a}]=1
              SGL_OPT_VALS[${a}]="${val}"
            fi
            ;;
          x)
            _sgl_err OPT "invalid ${prg}OPTION \`${opt}'"
            ;;
        esac
      done
    fi
  done

  # parse each ARG value
  while [[ ${i} -lt ${len} ]]; do
    SGL_VALS[${#SGL_VALS[@]}]="${args[${i}]}"
    i=$(( i + 1 ))
  done

  return 0
}
readonly -f sgl_parse_args
