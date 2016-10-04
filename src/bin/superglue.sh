#!/bin/bash --posix
#
# A bash superset that cleans the environment, defines helper references,
# sources helper functions, and sources a user-defined SCRIPT.
#
# @dest /bin/sgl
# @dest /bin/sglue
# @dest /bin/superglue
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl [...OPTION] FUNC [...FUNC_ARG]
# @use sgl [...OPTION] SCRIPT [...SCRIPT_ARG]
# @opt -a|--alias          Enable aliases without `sgl_' prefixes for each sourced FUNC.
# @opt -C|--no-color       Disable ANSI output coloring for terminals.
# @opt -c|--color          Enable ANSI output coloring for non-terminals.
# @opt -D|--silent-child   Disable `stderr' and `stdout' outputs for child processes.
# @opt -d|--quiet-child    Disable `stdout' output for child processes.
# @opt -h|--help[=FUNC]    Print help info and exit.
# @opt -P|--silent-parent  Disable `stderr' and `stdout' outputs for parent process.
# @opt -p|--quiet-parent   Disable `stdout' output for parent process.
# @opt -Q|--silent         Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet          Disable `stdout' output.
# @opt -S|--source-all     Source every FUNC.
# @opt -s|--source=FUNCS   Source each FUNC in FUNCS.
# @opt -V|--verbose        Appends line number and context to errors.
# @opt -v|--version        Print version info and exit.
# @opt -x|--xtrace         Enables bash `xtrace' option.
# @opt -|--                End the options.
# @val FUNC    Must be a valid `superglue' function. The `sgl_' prefix is optional.
# @val FUNCS   Must be a list of 1 or more FUNC using `,', `|', or ` ' to separate each.
# @val SCRIPT  Must be a valid file path to a `superglue' script.
# @exit
#   0  PASS  A successful exit.
#   1  MISC  An unknown error.
#   2  OPT   An invalid option.
#   3  VAL   An invalid or missing value.
#   4  AUTH  A permissions error.
#   5  DPND  A dependency error.
#   6  CHLD  A child process exited unsuccessfully.
#   7  SGL   A `superglue' script error.
################################################################################

readonly SGL_VERSION='0.1.0.alpha'

################################################################################
## DEFINE NULL REF
################################################################################

readonly NIL='/dev/null'

################################################################################
## CLEAN BUILTINS
################################################################################

unalias exit     2> ${NIL} || :
unalias local    2> ${NIL} || :
unalias shift    2> ${NIL} || :
unalias unset    2> ${NIL} || :
unalias printf   2> ${NIL} || :
unalias declare  2> ${NIL} || :
unset -f local   2> ${NIL} || :
unset -f printf  2> ${NIL} || :
unset -f declare 2> ${NIL} || :

################################################################################
## CHECK BASH VERSION
################################################################################

if [[ -z "${BASH_VERSINFO}" ]] || [[ ${BASH_VERSINFO[0]} -ne 4 ]]; then
  printf "%s\n" "DPND_ERR bash version 4 required" 1>&2
  exit 5
fi

################################################################################
## CHECK CORE LIB
################################################################################

readonly SGL_LIB='/lib/superglue'

if [[ ! -d ${SGL_LIB} ]]; then
  printf "%s\n" "DPND_ERR missing core lib - reinstall \`superglue'" 1>&2
  exit 5
fi

################################################################################
## LOAD SOURCE HELPER
################################################################################

if [[ ! -f "${SGL_LIB}/_sgl_err" ]] || [[ ! -f "${SGL_LIB}/_sgl_source" ]]; then
  printf "%s\n" "DPND_ERR missing core func - reinstall \`superglue'" 1>&2
  exit 5
fi
. "${SGL_LIB}/_sgl_err"
. "${SGL_LIB}/_sgl_source"

################################################################################
## CLEAN BUILTINS
################################################################################

_sgl_source clean_builtin unset_func unalias
_sgl_clean_builtin

################################################################################
## DEFINE COMMANDS
################################################################################

_sgl_source which chk_cmd

readonly bash='/bin/bash'
readonly cat="$(_sgl_which cat)"
readonly chmod="$(_sgl_which chmod)"
readonly chown="$(_sgl_which chown)"
readonly cp="$(_sgl_which cp)"
readonly find="$(_sgl_which find)"
readonly grep="$(_sgl_which grep)"
readonly make="$(_sgl_which make)"
readonly mkdir="$(_sgl_which mkdir)"
readonly mv="$(_sgl_which mv)"
readonly rm="$(_sgl_which rm)"
readonly sed="$(_sgl_which sed)"

_sgl_chk_cmd ${bash} ${cat} ${chmod} ${chown} ${cp} ${find} ${grep} ${make} \
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
## PARSE ARGS
################################################################################

_sgl_source parse_args
_sgl_parse_args "$0" \
  '-a|--alias'     0 \
  '-C|--no-color'  0 \
  '-c|--color'     0 \
  '-D|--silent-child' 0 \
  '-d|--quiet-child' 0 \
  '-h|--help'      2 \
  '-P|--silent-parent' 0 \
  '-p|--quiet-parent' 0 \
  '-Q|--silent'    0 \
  '-q|--quiet'     0 \
  '-S|--source-all' 0 \
  '-s|--source'    1 \
  '-V|--verbose'   0 \
  '-v|--version'   0 \
  '-x|--xtrace'    0 \
  -- "$@"

################################################################################
## LOAD SOURCE FUNCTION
################################################################################

if [[ -f "${SGL_LIB}/sgl_source" ]]; then
  . "${SGL_LIB}/sgl_source"
else
  _sgl_err DPND "missing core func - reinstall \`superglue'"
fi

################################################################################
## PARSE OPTS
################################################################################

_sgl_source version

SGL_ALIAS=0
SGL_SILENT_CHILD=0
SGL_QUIET_CHILD=0
SGL_SILENT_PARENT=0
SGL_QUIET_PARENT=0
SGL_SILENT=0
SGL_QUIET=0
SGL_VERBOSE=0

if [[ ${#_SGL_OPTS[@]} -eq 0 ]]; then
  _sgl_source help
  _sgl_help
fi

len=${#_SGL_OPTS[@]}
for ((i=0; i<len; i++)); do
  opt="${_SGL_OPTS[${i}]}"
  case "${opt}" in
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
    -h|--help)
      _sgl_source help
      if [[ ${_SGL_OPT_BOOL[${i}]} -eq 1 ]]; then
        _sgl_help "${_SGL_OPT_VALS[${i}]}"
      else
        _sgl_help
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
      sgl_source "${_SGL_OPT_VALS[${i}]}"
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
      _sgl_err SGL "invalid parsed \`superglue' OPTION \`${opt}'"
      ;;
  esac
done

################################################################################
## PARSE FUNC
################################################################################

[[ ${#_SGL_VALS[@]} -gt 0 ]] || _sgl_err VAL "missing \`superglue' FUNC|SCRIPT"

if [[ "${SGL_FUNC}" =~ ^[a-z_]+$ ]]; then

  SGL_FUNC="${_SGL_VALS[0]}"
  [[ "${SGL_FUNC}" =~ ^sgl_ ]] || SGL_FUNC="sgl_${SGL_FUNC}"

  if [[ -f "${SGL_LIB}/${SGL_FUNC}" ]]; then
    _SGL_VALS[0]="${SGL_FUNC}"
    sgl_source "${SGL_FUNC}"
    "${_SGL_VALS[@]}"
    exit
  fi
fi

################################################################################
## PARSE SCRIPT
################################################################################

readonly SGL_SCRIPT="${_SGL_VALS[0]}"

if [[ ! -f "${SGL_SCRIPT}" ]]; then
  _sgl_err VAL "invalid \`superglue' SCRIPT path \`${SGL_SCRIPT}'"
fi

declare -a SGL_ARGS
len=${#_SGL_VALS[@]}
for ((i=1; i<len; i++)); do
  SGL_ARGS[${#SGL_ARGS[@]}]="${_SGL_VALS[${i}]}"
done
readonly -a SGL_ARGS

. "${_SGL_VALS[@]}"
exit
