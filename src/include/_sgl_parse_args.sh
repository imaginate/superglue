# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
################################################################################

############################################################
# Parses the arguments and saves the parsed options and
# values to the following 0 based indexed arrays:
#   $_SGL_OPTS      Each parsed option (e.g. `-s' or `--long').
#   $_SGL_OPT_BOOL  Whether each option has a value (`0' or `1').
#   $_SGL_OPT_VALS  The parsed option value.
#   $_SGL_VALS      The remaining (non-option) parsed values.
#
# @private
# @func _sgl_parse_args
# @use _sgl_parse_args PRG [OPT VAL] -- [...ARG]
# @val ARG  Each original passed argument.
# @val PRG  The name of the program calling `_sgl_parse_args'.
# @val OPT  Each OPT pattern must begin with a dash (e.g. `-<short>|--<long>').
#           Use a pipe to separate multiple OPT patterns.
# @val VAL  Defines whether an OPT has a value. Must be an integer from below.
#   0  no value
#   1  required value
#   2  optional value
# @return
#   0  PASS
############################################################
_sgl_parse_args()
{
  local -r FN='_sgl_parse_args'
  local -r P="${1}"
  local -i i=0
  local -i u=0
  local -i len
  local arg
  local opt
  local val
  local -A long
  local -A short

  if [[ -z "${P}" ]]; then
    _sgl_err SGL "missing PRG for \`${FN}'"
  fi
  shift

  # parse each OPT/VAL
  # build short and long hash maps
  while [[ ${#} -gt 0 ]]; do

    # end of OPT/VAL
    if [[ "${1}" == '--' ]]; then
      shift
      break
    fi

    # catch invalid OPT chars
    if [[ ! "${1}" =~ ^-[a-zA-Z0-9|?-]+$ ]]; then
      _sgl_err SGL "invalid \`${FN}' OPT \`${1}'"
    fi

    # parse VAL
    if [[ ! "${2}" =~ ^[0-2]$ ]]; then
      _sgl_err SGL "invalid \`${FN}' VAL \`${2}' for OPT \`${1}'"
    fi
    val="${2}"

    # parse OPT
    while IFS= read -r -d '|' opt; do
      if [[ "${opt}" =~ ^--[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$ ]]; then
        long[${opt}]=${val}
      elif [[ "${opt}" =~ ^-[a-zA-Z0-9?]$ ]]; then
        short[${opt}]=${val}
      else
        _sgl_err SGL "invalid \`${FN}' OPT \`${opt}'"
      fi
    done <<< "${1}|"

    # next OPT/VAL
    shift 2
  done

  _SGL_OPTS=()
  _SGL_OPT_BOOL=()
  _SGL_OPT_VALS=()

  # parse ARG options
  while [[ ${#} -gt 0 ]]; do

    # start ARG values
    [[ "${1}" =~ ^- ]] || break

    # end ARG options
    if [[ "${1}" =~ ^--?$ ]]; then
      shift
      break
    fi

    # parse long ARG option
    if [[ "${1}" =~ ^-- ]]; then

      # save current index
      i=${#_SGL_OPTS[@]}

      # parse long ARG option with `='
      if [[ "${1}" =~ = ]]; then
        opt="${1%%=*}"
        case "${long[${opt}]:-x}" in
          0)
            _sgl_err VAL "invalid \`${P}' \`${opt}' VALUE"
            ;;
          x)
            _sgl_err OPT "invalid \`${P}' OPTION \`${opt}'"
            ;;
        esac
        _SGL_OPTS[${i}]="${opt}"
        _SGL_OPT_BOOL[${i}]=1
        _SGL_OPT_VALS[${i}]="${1#*=}"

      # parse long ARG option without `='
      else
        _SGL_OPTS[${i}]="${1}"
        case "${long[${1}]:-x}" in
          0)
            _SGL_OPT_BOOL[${i}]=0
            _SGL_OPT_VALS[${i}]=''
            ;;
          1)
            if [[ ${#} -eq 1 ]] || [[ "${2}" =~ ^- ]]; then
              _sgl_err VAL "missing \`${P}' \`${1}' VALUE"
            fi
            _SGL_OPT_BOOL[${i}]=1
            _SGL_OPT_VALS[${i}]="${2}"
            shift
            ;;
          2)
            if [[ ${#} -eq 1 ]] || [[ "${2}" =~ ^- ]]; then
              _SGL_OPT_BOOL[${i}]=0
              _SGL_OPT_VALS[${i}]=''
            else
              _SGL_OPT_BOOL[${i}]=1
              _SGL_OPT_VALS[${i}]="${2}"
              shift
            fi
            ;;
          x)
            _sgl_err OPT "invalid \`${P}' OPTION \`${1}'"
            ;;
        esac
      fi

    # parse short ARG option
    else
      len="${#1}"
      for (( u=1; u<len; u++ )); do
        opt="-${1:${u}:1}"
        i=${#_SGL_OPTS[@]}
        _SGL_OPTS[${i}]="${opt}"
        case "${short[${opt}]:-x}" in
          0)
            _SGL_OPT_BOOL[${i}]=0
            _SGL_OPT_VALS[${i}]=''
            ;;
          1)
            _SGL_OPT_BOOL[${i}]=1
            if (( ++u < len )); then
              _SGL_OPT_VALS[${i}]="${1:${u}}"
              break # end for loop
            elif [[ ${#} -eq 1 ]] || [[ "${2}" =~ ^- ]]; then
              _sgl_err VAL "missing \`${P}' \`${opt}' VALUE"
            else
              _SGL_OPT_VALS[${i}]="${2}"
              shift
            fi
            ;;
          2)
            if (( ++u < len )); then
              _SGL_OPT_BOOL[${i}]=1
              _SGL_OPT_VALS[${i}]="${1:${u}}"
              break # end for loop
            elif [[ ${#} -eq 1 ]] || [[ "${2}" =~ ^- ]]; then
              _SGL_OPT_BOOL[${i}]=0
              _SGL_OPT_VALS[${i}]=''
            else
              _SGL_OPT_BOOL[${i}]=1
              _SGL_OPT_VALS[${i}]="${2}"
              shift
            fi
            ;;
          x)
            _sgl_err OPT "invalid \`${P}' OPTION \`${opt}'"
            ;;
        esac
      done
    fi
    shift
  done

  _SGL_VALS=()

  # parse ARG values
  while [[ ${#} -gt 0 ]]; do
    _SGL_VALS[${#_SGL_VALS[@]}]="${1}"
    shift
  done
}
readonly -f _sgl_parse_args
