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
# @opt -h|-?|--help            Print help info and exit.
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
  local -i a
  local -i i
  local -i u
  local -i len
  local -i slen
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
    '-h|-?|--help'       0 \
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
      -h|-\?|--help)
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
    -h|-?|--help            Print help info and exit.
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
  len=${#_SGL_VALS[@]}
  for ((i=0; i<len; i++)); do
    opt="${_SGL_VALS[${i}]}"

    # end OPT/VAL
    if [[ "${opt}" == '--' ]]; then
      i=$(( ++i ))
      break
    fi

    # catch invalid OPT chars
    if [[ ! "${opt}" =~ ^-[a-zA-Z0-9|-]+$ ]]; then
      _sgl_err VAL "invalid \`${FN}' OPT \`${opt}'"
    fi

    # parse VAL
    i=$(( ++i ))
    val="${_SGL_VALS[${i}]}"
    case "${val}" in
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
        _sgl_err VAL "invalid \`${FN}' \`${opt}' VAL \`${val}'"
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
${opt}|
EOF
  done

  # reset globals
  SGL_OPTS=()
  SGL_OPT_BOOL=()
  SGL_OPT_VALS=()

  # parse ARG options
  for ((i; i<len; i++)); do
    opt="${_SGL_VALS[${i}]}"

    # start ARG values
    [[ "${opt}" =~ ^- ]] || break

    # end ARG options
    if [[ "${opt}" =~ ^--?$ ]]; then
      i=$(( ++i ))
      break
    fi

    # parse long ARG option
    if [[ "${opt}" =~ ^-- ]]; then

      # save current index
      a=${#SGL_OPTS[@]}

      # parse long ARG option with `='
      if [[ "${opt}" =~ = ]]; then
        val="$(printf '%s' "${opt}" | ${sed} -e 's/^[^=]\+=//')"
        opt="$(printf '%s' "${opt}" | ${sed} -e 's/=.*$//')"
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
            i=$(( ++i ))
            val="${_SGL_VALS[${i}]}"
            if [[ ${i} -eq ${len} ]] || [[ "${val}" =~ ^- ]]; then
              _sgl_err VAL "missing ${prg}\`${opt}' VALUE"
            fi
            SGL_OPT_BOOL[${a}]=1
            SGL_OPT_VALS[${a}]="${val}"
            ;;
          2)
            i=$(( ++i ))
            val="${_SGL_VALS[${i}]}"
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
      fi

    # parse short ARG option
    else
      arg="${opt}"
      slen="${#arg}"
      for ((u=1; u<slen; u++)); do
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
            if ((++u < slen)); then
              SGL_OPT_VALS[${a}]="${arg:${u}}"
              break # end for loop
            fi
            i=$(( ++i ))
            val="${_SGL_VALS[${i}]}"
            if [[ ${i} -eq ${len} ]] || [[ "${val}" =~ ^- ]]; then
              _sgl_err VAL "missing ${prg}\`${opt}' VALUE"
            else
              SGL_OPT_VALS[${a}]="${val}"
            fi
            ;;
          2)
            if ((++u < slen)); then
              SGL_OPT_BOOL[${a}]=1
              SGL_OPT_VALS[${a}]="${arg:${u}}"
              break # end for loop
            fi
            i=$(( ++i ))
            val="${_SGL_VALS[${i}]}"
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

  # reset global
  SGL_VALS=()

  # parse ARG values
  for ((i; i<len; i++)); do
    SGL_VALS[${#SGL_VALS[@]}]="${_SGL_VALS[${i}]}"
  done
}
readonly -f sgl_parse_args
