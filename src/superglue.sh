#!/bin/bash --posix
#
# @superglue
# @version 0.1.0-alpha.11
#
# A bash superset that cleans the environment, defines helper references,
# sources helper functions, and sources a user-defined SCRIPT.
#
# @dest $BIN/superglue
# @dest $BIN/sglue
# @dest $BIN/sgl
# @mode 0755
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl|sglue|superglue [...OPTION] FUNC [...FUNC_ARG]
# @use sgl|sglue|superglue [...OPTION] SCRIPT [...SCRIPT_ARG]
# @opt -a|--alias           Enable function names without `sgl_' prefixes
#                           for each sourced FUNC.
# @opt -C|--no-color        Disable ANSI output coloring for terminals.
# @opt -c|--color           Enable ANSI output coloring for non-terminals.
# @opt -D|--silent-child    Disable `stderr' and `stdout' for child processes.
# @opt -d|--quiet-child     Disable `stdout' output for child processes.
# @opt -h|-?|--help[=FUNC]  Print help info and exit.
# @opt -P|--silent-parent   Disable `stderr' and `stdout' for parent process.
# @opt -p|--quiet-parent    Disable `stdout' output for parent process.
# @opt -Q|--silent          Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet           Disable `stdout' output.
# @opt -S|--source-all      Source every FUNC.
# @opt -s|--source=FUNCS    Source each FUNC in FUNCS.
# @opt -V|--verbose         Appends line number and context to errors.
# @opt -v|--version         Print version info and exit.
# @opt -x|--xtrace          Enables bash `xtrace' option.
# @opt -|--                 End the options.
# @val FUNC    Must be a valid `superglue' function. The `sgl_' prefix
#              is optional.
# @val FUNCS   Must be a list of 1 or more FUNC using `,', `|', or ` '
#              to separate each.
# @val SCRIPT  Must be a valid file path to a `superglue' script.
# @exit
#   0  PASS  A successful exit.
#   1  ERR   An unknown error.
#   2  OPT   An invalid option.
#   3  VAL   An invalid or missing value.
#   4  AUTH  A permissions error.
#   5  DPND  A dependency error.
#   6  CHLD  A child process exited unsuccessfully.
#   7  SGL   A `superglue' script error.
################################################################################

readonly SGL_VERSION='0.1.0-alpha.11'
readonly SGL='superglue'

################################################################################
## DEFINE LIB DIRS
################################################################################

readonly SGL_LIB='/usr/lib/superglue'
readonly SGL_HELP='/usr/share/superglue/help'

################################################################################
## DEFINE NULL REF
################################################################################

readonly NIL='/dev/null'

################################################################################
## DEFINE PRIVATE FUNCS
################################################################################

# @include ./include/_sgl_chk_cmd.sh
# @include ./include/_sgl_chk_core.sh
# @include ./include/_sgl_clean_builtin.sh
# @include ./include/_sgl_err.sh
# @include ./include/_sgl_fail.sh
# @include ./include/_sgl_get_quiet.sh
# @include ./include/_sgl_get_silent.sh
# @include ./include/_sgl_help.sh
# @include ./include/_sgl_is_cmd.sh
# @include ./include/_sgl_is_dir.sh
# @include ./include/_sgl_is_file.sh
# @include ./include/_sgl_is_func.sh
# @include ./include/_sgl_is_name.sh
# @include ./include/_sgl_is_path.sh
# @include ./include/_sgl_is_read.sh
# @include ./include/_sgl_is_set.sh
# @include ./include/_sgl_match_func.sh
# @include ./include/_sgl_parse_args.sh
# @include ./include/_sgl_parse_init.sh
# @include ./include/_sgl_prefix.sh
# @include ./include/_sgl_unalias.sh
# @include ./include/_sgl_unalias_each.sh
# @include ./include/_sgl_unset_func.sh
# @include ./include/_sgl_unset_funcs.sh
# @include ./include/_sgl_version.sh
# @include ./include/_sgl_which.sh

################################################################################
## CLEAN BUILTINS
################################################################################

_sgl_clean_builtin

################################################################################
## CHECK BASH VERSION
################################################################################

if [[ -z "${BASH_VERSINFO}" ]] || [[ "${BASH_VERSINFO[0]}" != '4' ]]; then
  _sgl_err 0 DPND "bash version 4 required"
fi

################################################################################
## DEFINE SGL FUNCS
################################################################################

declare -ar SGL_FUNCS=( \
  sgl_chk_cmd    \
  sgl_chk_dir    \
  sgl_chk_exit   \
  sgl_chk_file   \
  sgl_chk_uid    \
  sgl_color      \
  sgl_cp         \
  sgl_err        \
  sgl_mk_dest    \
  sgl_parse_args \
  sgl_print      \
  sgl_rm_dest    \
  sgl_set_color  \
  sgl_source     )

################################################################################
## CHECK CORE PATHS
################################################################################

_sgl_chk_core "${SGL_LIB}" "${SGL_FUNCS[@]}"
_sgl_chk_core "${SGL_HELP}" 'superglue' "${SGL_FUNCS[@]}"

################################################################################
## DEFINE COMMANDS
################################################################################

readonly bash='/bin/bash'
readonly cat="$(_sgl_which cat)"
readonly chgrp="$(_sgl_which chgrp)"
readonly chmod="$(_sgl_which chmod)"
readonly chown="$(_sgl_which chown)"
readonly cp="$(_sgl_which cp)"
readonly grep="$(_sgl_which grep)"
readonly ln="$(_sgl_which ln)"
readonly mkdir="$(_sgl_which mkdir)"
readonly mv="$(_sgl_which mv)"
readonly rm="$(_sgl_which rm)"
readonly sed="$(_sgl_which sed)"

################################################################################
## CHECK COMMANDS
################################################################################

_sgl_chk_cmd ${bash} ${cat} ${chgrp} ${chmod} ${chown} ${cp} ${grep} ${ln} \
  ${mkdir} ${mv} ${rm} ${sed}

################################################################################
## DEFINE COLORS
################################################################################

readonly _SGL_UNCOLOR="$(printf '%b' '\033[0;0m')"
readonly _SGL_BLACK="$(printf '%b' '\033[0;30m')"
readonly _SGL_RED="$(printf '%b' '\033[0;91m')"
readonly _SGL_GREEN="$(printf '%b' '\033[0;32m')"
readonly _SGL_YELLOW="$(printf '%b' '\033[0;33m')"
readonly _SGL_BLUE="$(printf '%b' '\033[0;94m')"
readonly _SGL_PURPLE="$(printf '%b' '\033[0;35m')"
readonly _SGL_CYAN="$(printf '%b' '\033[0;36m')"
readonly _SGL_WHITE="$(printf '%b' '\033[0;97m')"

SGL_UNCOLOR="${_SGL_UNCOLOR}"
SGL_BLACK="${_SGL_BLACK}"
SGL_RED="${_SGL_RED}"
SGL_GREEN="${_SGL_GREEN}"
SGL_YELLOW="${_SGL_YELLOW}"
SGL_BLUE="${_SGL_BLUE}"
SGL_PURPLE="${_SGL_PURPLE}"
SGL_CYAN="${_SGL_CYAN}"
SGL_WHITE="${_SGL_WHITE}"

SGL_COLOR_OFF=0
SGL_COLOR_ON=0

################################################################################
## DEFINE NEWLINE REF
################################################################################

readonly NEWLINE="$(printf '\n')"

################################################################################
## PARSE ARGS
################################################################################

_sgl_parse_init          \
  '-a|--alias'         0 \
  '-C|--no-color'      0 \
  '-c|--color'         0 \
  '-D|--silent-child'  0 \
  '-d|--quiet-child'   0 \
  '-h|-?|--help'       2 \
  '-P|--silent-parent' 0 \
  '-p|--quiet-parent'  0 \
  '-Q|--silent'        0 \
  '-q|--quiet'         0 \
  '-S|--source-all'    0 \
  '-s|--source'        1 \
  '-V|--verbose'       0 \
  '-v|--version'       0 \
  '-x|--xtrace'        0 \
  -- "${@}"

################################################################################
## LOAD SOURCE FUNCTION
################################################################################

. "${SGL_LIB}/sgl_source"

################################################################################
## PARSE OPTS
################################################################################

SGL_ALIAS=0
SGL_SILENT_CHILD=0
SGL_QUIET_CHILD=0
SGL_SILENT_PARENT=0
SGL_QUIET_PARENT=0
SGL_SILENT=0
SGL_QUIET=0
SGL_VERBOSE=0

if [[ ${#__SGL_OPTS[@]} -gt 0 ]]; then
  declare -i __I=0
  declare __OPT
  declare __VAL
  for __OPT in "${__SGL_OPTS[@]}"; do
    case "${__OPT}" in
      -a|--alias)
        SGL_ALIAS=1
        ;;
      -C|--no-color)
        SGL_COLOR_OFF=1
        SGL_COLOR_ON=0
        ;;
      -c|--color)
        SGL_COLOR_OFF=0
        SGL_COLOR_ON=1
        ;;
      -D|--silent-child)
        SGL_SILENT_CHILD=1
        ;;
      -d|--quiet-child)
        SGL_QUIET_CHILD=1
        ;;
      -h|-\?|--help)
        if [[ ${__SGL_OPT_BOOL[${__I}]} -eq 1 ]]; then
          __VAL="$(_sgl_prefix "${__SGL_OPT_VALS[${__I}]}")"
          if ! _sgl_is_func "${__VAL}"; then
            _sgl_err $(_sgl_get_silent PRT) VAL \
              "invalid \`${SGL}' FUNC \`${__VAL}'"
          fi
          _sgl_help "${__VAL}"
        else
          _sgl_help superglue
        fi
        ;;
      -P|--silent-parent)
        SGL_SILENT_PARENT=1
        ;;
      -p|--quiet-parent)
        SGL_QUIET_PARENT=1
        ;;
      -Q|--silent)
        SGL_SILENT=1
        ;;
      -q|--quiet)
        SGL_QUIET=1
        ;;
      -S|--source-all)
        sgl_source '*'
        ;;
      -s|--source)
        declare __RE='^[a-z*]+[a-z_ ,|*]*$'
        __VAL="${__SGL_OPT_VALS[${__I}]}"
        if [[ ! "${__VAL}" =~ ${__RE} ]]; then
          _sgl_err $(_sgl_get_silent PRT) VAL \
            "invalid \`${SGL}' FUNCS \`${__VAL}'"
        fi
        unset -v __RE
        declare -a __FUNCS=()
        declare __FUNC
        __VAL="$(printf '%s' "${__VAL}" | ${sed} -e 's/[,|]/ /g')"
        __VAL="${__VAL% }"
        while IFS= read -r -d ' ' __FUNC; do
          __FUNC="$(_sgl_prefix "${__FUNC}")"
          if ! _sgl_match_func "${__FUNC}"; do
            _sgl_err $(_sgl_get_silent PRT) VAL \
              "invalid \`${SGL}' FUNC \`${__FUNC}' in FUNCS \`${__VAL}'"
          fi
          __FUNCS[${#__FUNCS[@]}]="${__FUNC}"
        done <<< "${__VAL} "
        sgl_source "${__FUNCS[@]}"
        unset -v __FUNC
        unset -v __FUNCS
        ;;
      -V|--verbose)
        SGL_VERBOSE=1
        ;;
      -v|--version)
        _sgl_version
        ;;
      -x|--xtrace)
        set -x
        ;;
      *)
        _sgl_err $(_sgl_get_silent PRT) SGL \
          "invalid parsed \`${SGL}' OPTION \`${__OPT}'"
        ;;
    esac
    : $(( ++__I ))
  done
  unset -v __I
  unset -v __OPT
  unset -v __VAL
fi

################################################################################
## PARSE ARGS
################################################################################

if [[ ${#__SGL_VALS[@]} -eq 0 ]]; then
  _sgl_err $(_sgl_get_silent PRT) VAL "missing \`${SGL}' FUNC|SCRIPT"
fi

declare -a SGL_ARGS=()

if [[ ${#__SGL_VALS[@]} -gt 1 ]]; then
  declare __ARG
  for __ARG in "${__SGL_VALS[@]:1}"; do
    SGL_ARGS[${#SGL_ARGS[@]}]="${__ARG}"
  done
  unset -v __ARG
fi

readonly -a SGL_ARGS

################################################################################
## PARSE FUNC
################################################################################

SGL_FUNC="$(_sgl_prefix "${__SGL_VALS[0]}")"
if ! _sgl_is_func "${SGL_FUNC}"; then
  SGL_FUNC=''
fi
readonly SGL_FUNC

if [[ -n "${SGL_FUNC}" ]]; then
  sgl_source ${SGL_FUNC}
  ${SGL_FUNC} "${SGL_ARGS[@]}"
  exit ${?}
fi

################################################################################
## PARSE SCRIPT
################################################################################

readonly SGL_SCRIPT="${__SGL_VALS[0]}"

if ! _sgl_is_read "${SGL_SCRIPT}"; then
  _sgl_err $(_sgl_get_silent PRT) VAL \
    "invalid \`${SGL}' file path SCRIPT \`${SGL_SCRIPT}'"
fi

. "${SGL_SCRIPT}" "${SGL_ARGS[@]}"
exit ${?}
