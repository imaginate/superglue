#!/bin/bash
#
# @dest /lib/superglue/sgl_parse_args
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl_source parse_args
# @return
#   0  PASS
################################################################################

############################################################
# This function parses each ARG and saves the resulting option/values
# to the following zero-based indexed arrays:
#   SGL_OPTS      Each parsed option (e.g. `-s' or `--long').
#   SGL_OPT_BOOL  Whether each option has a value (`0' or `1').
#   SGL_OPT_VALS  The parsed option value.
#   SGL_VALS      The remaining (non-option) parsed values.
# Note that the OPT `-|--' is automatically assumed.
#
# @func sgl_parse_args
# @use sgl_parse_args [...OPTION] [...OPT VAL] -- [...ARG]
# @opt -h|--help               Print help info and exit.
# @opt -p|--prg|--program=PRG  Include the PRG in the error messages.
# @opt -Q|--silent             Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet              Disable `stdout' output.
# @opt -v|--version            Print version info and exit.
# @opt -|--                    End the options.
# @val ARG  Each original passed argument (i.e. `"$@"').
# @val OPT  Each OPT pattern must begin with a dash (e.g. `-<short>|--<long>').
#           Use a pipe to separate multiple OPT patterns.
# @val PRG  Can be any string.
# @val VAL  Defines whether an OPT has a value. Must be an option from below.
#   0|N|NO     The OPT has no value.
#   1|Y|YES    The OPT requires a value.
#   2|M|MAYBE  The OPT can have a value.
# @return
#   0  PASS
############################################################
sgl_parse_args()
{
  local -r FN='sgl_parse_args'
  local -i i
  local -i u
  local -i len
  local -i quiet=${SGL_QUIET}
  local -i silent=${SGL_SILENT}
  local arg
  local opt
  local prg
  local val
  local -A long
  local -A short

  # parse each argument
  _sgl_parse_args "${FN}"  \
    '-h|--help'          0 \
    '-p|--prg|--program' 1 \
    '-Q|--silent'        0 \
    '-q|--quiet'         0 \
    '-v|--version'       0 \
    -- "$@"

  # parse each OPTION
  len=${#_SGL_OPTS[@]}
  for ((i=0; i<len; i++)); do
    opt="${_SGL_OPTS[${i}]}"
    case "${opt}" in
      -h|--help)
        ${cat} <<'EOF'

  sgl_parse_args [...OPTION] [...OPT VAL] -- [...ARG]

  This function parses each ARG and saves the resulting option/values
  to the following zero-based indexed arrays:
    SGL_OPTS      Each parsed option (e.g. `-s' or `--long').
    SGL_OPT_BOOL  Whether each option has a value (`0' or `1').
    SGL_OPT_VALS  The parsed option value.
    SGL_VALS      The remaining (non-option) parsed values.
  Note that the OPT `-|--' is automatically assumed.

  Options:
    -h|--help               Print help info and exit.
    -p|--prg|--program=PRG  Include the PRG in the error messages.
    -Q|--silent             Disable `stderr' and `stdout' outputs.
    -q|--quiet              Disable `stdout' output.
    -v|--version            Print version info and exit.
    -|--                    End the options.

  Values:
    ARG  Each original passed argument (i.e. `"$@"').
    OPT  Each OPT pattern must begin with a dash (e.g. `-<short>|--<long>').
         Use a pipe to separate multiple OPT patterns.
    PRG  Can be any string.
    VAL  Defines whether an OPT has a value. Must be an option from below.
      0|N|NO     The OPT has no value.
      1|Y|YES    The OPT requires a value.
      2|M|MAYBE  The OPT can have a value.

EOF
        exit 0
        ;;
      -p|--prg|--program)
        prg="\`${_SGL_OPT_VALS[${i}]}' "
        ;;
      -Q|--silent)
        silent=1
        ;;
      -q|--quiet)
        quiet=1
        ;;
      -v|--version)
        _sgl_version
        ;;
      *)
        _sgl_err SGL "invalid parsed \`${FN}' OPTION \`${opt}'"
        ;;
    esac
  done

  # parse each OPT/VAL
  # build short and long hash maps
  while [[ $# -gt 0 ]]; do

    # end of OPT/VAL
    if [[ "$1" == '--' ]]; then
      shift
      break
    fi

    # catch invalid OPT chars
    [[ "$1" =~ ^-[a-zA-Z0-9|-]+$ ]] || _sgl_err VAL "invalid \`${FN}' OPT \`$1'"

    # parse VAL
    case "$2" in
      0|n|no|N|NO)
        val=0
        ;;
      1|y|yes|Y|YES)
        val=1
        ;;
      2|m|maybe|M|MAYBE)
        val=2
        ;;
      *)
        _sgl_err VAL "invalid \`${FN}' \`$1' VAL \`$2'"
        ;;
    esac

    # parse OPT
    while IFS= read -r -d '|' opt; do
      if [[ "${opt}" =~ ^--[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$ ]]; then
        long[${opt}]=${val}
      elif [[ "${opt}" =~ ^-[a-zA-Z0-9]$ ]]; then
        short[${opt}]=${val}
      else
        _sgl_err VAL "invalid \`${FN}' OPT \`${opt}'"
      fi
    done <<EOF
"$1|"
EOF
    # next OPT/VAL
    shift 2
  done

  # reset globals
  SGL_OPTS=()
  SGL_OPT_BOOL=()
  SGL_OPT_VALS=()

  # parse ARG options
  while [[ $# -gt 0 ]]; do

    # start ARG values
    [[ "$1" =~ ^- ]] || break

    # end ARG options
    if [[ "$1" =~ ^--?$ ]]; then
      shift
      break
    fi

    # parse long ARG option
    if [[ "$1" =~ ^-- ]]; then

      # save current index
      i=${#SGL_OPTS[@]}

      # parse long ARG option with `='
      if [[ "$1" =~ = ]]; then
        opt="$(printf '%s' "$1" | ${sed} -e 's/=.*$//')"
        case "${long[${opt}]:-x}" in
          0)
            _sgl_err VAL "invalid ${prg}\`${opt}' VALUE"
            ;;
          x)
            _sgl_err OPT "invalid ${prg}OPTION \`${opt}'"
            ;;
        esac
        SGL_OPTS[${i}]="${opt}"
        SGL_OPT_BOOL[${i}]=1
        SGL_OPT_VALS[${i}]="$(printf '%s' "$1" | ${sed} -e 's/^[^=]\+=//')"

      # parse long ARG option without `='
      else
        SGL_OPTS[${i}]="$1"
        case "${long[${1}]:-x}" in
          0)
            SGL_OPT_BOOL[${i}]=0
            SGL_OPT_VALS[${i}]=''
            ;;
          1)
            if [[ $# -eq 1 ]] || [[ "$2" =~ ^- ]]; then
              _sgl_err VAL "missing ${prg}\`$1' VALUE"
            fi
            SGL_OPT_BOOL[${i}]=1
            SGL_OPT_VALS[${i}]="$2"
            shift
            ;;
          2)
            if [[ $# -eq 1 ]] || [[ "$2" =~ ^- ]]; then
              SGL_OPT_BOOL[${i}]=0
              SGL_OPT_VALS[${i}]=''
            else
              SGL_OPT_BOOL[${i}]=1
              SGL_OPT_VALS[${i}]="$2"
              shift
            fi
            ;;
          x)
            _sgl_err OPT "invalid ${prg}OPTION \`${opt}'"
            ;;
        esac
      fi

    # parse short ARG option
    else
      len="${#1}"
      for ((u=1; u<len; u++)); do
        opt="-${1:${u}:1}"
        i=${#SGL_OPTS[@]}
        SGL_OPTS[${i}]="${opt}"
        case "${short[${opt}]:-x}" in
          0)
            SGL_OPT_BOOL[${i}]=0
            SGL_OPT_VALS[${i}]=''
            ;;
          1)
            SGL_OPT_BOOL[${i}]=1
            if ((++u < len)); then
              SGL_OPT_VALS[${i}]="${1:${u}}"
              break # end for loop
            elif [[ $# -eq 1 ]] || [[ "$2" =~ ^- ]]; then
              _sgl_err VAL "missing ${prg}\`${opt}' VALUE"
            else
              SGL_OPT_VALS[${i}]="$2"
              shift
            fi
            ;;
          2)
            if ((++u < len)); then
              SGL_OPT_BOOL[${i}]=1
              SGL_OPT_VALS[${i}]="${1:${u}}"
              break # end for loop
            elif [[ $# -eq 1 ]] || [[ "$2" =~ ^- ]]; then
              SGL_OPT_BOOL[${i}]=0
              SGL_OPT_VALS[${i}]=''
            else
              SGL_OPT_BOOL[${i}]=1
              SGL_OPT_VALS[${i}]="$2"
              shift
            fi
            ;;
          x)
            _sgl_err OPT "invalid ${prg}OPTION \`${opt}'"
            ;;
        esac
      done
    fi
    shift
  done

  # reset global
  SGL_VALS=()

  # parse ARG values
  while [[ $# -gt 0 ]]; do
    SGL_VALS[${#SGL_VALS[@]}]="$1"
    shift
  done
}
readonly -f sgl_parse_args
