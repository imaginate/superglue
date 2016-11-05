#!/bin/bash --posix
#
# @superglue
# @version 0.1.0-alpha.6
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
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl|sglue|superglue [...OPTION] FUNC [...FUNC_ARG]
# @use sgl|sglue|superglue [...OPTION] SCRIPT [...SCRIPT_ARG]
# @opt -a|--alias           Enable function names without `sgl_' prefixes for each sourced FUNC.
# @opt -C|--no-color        Disable ANSI output coloring for terminals.
# @opt -c|--color           Enable ANSI output coloring for non-terminals.
# @opt -D|--silent-child    Disable `stderr' and `stdout' outputs for child processes.
# @opt -d|--quiet-child     Disable `stdout' output for child processes.
# @opt -h|-?|--help[=FUNC]  Print help info and exit.
# @opt -P|--silent-parent   Disable `stderr' and `stdout' outputs for parent process.
# @opt -p|--quiet-parent    Disable `stdout' output for parent process.
# @opt -Q|--silent          Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet           Disable `stdout' output.
# @opt -S|--source-all      Source every FUNC.
# @opt -s|--source=FUNCS    Source each FUNC in FUNCS.
# @opt -V|--verbose         Appends line number and context to errors.
# @opt -v|--version         Print version info and exit.
# @opt -x|--xtrace          Enables bash `xtrace' option.
# @opt -|--                 End the options.
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

readonly SGL_VERSION='0.1.0-alpha.6'
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

# @incl ./incl/_sgl_chk_cmd.sh
# @incl ./incl/_sgl_clean_builtin.sh
# @incl ./incl/_sgl_err.sh
# @incl ./incl/_sgl_err_code.sh
# @incl ./incl/_sgl_fail.sh
# @incl ./incl/_sgl_get_color.sh
# @incl ./incl/_sgl_get_func.sh
# @incl ./incl/_sgl_help.sh
# @incl ./incl/_sgl_parse_args.sh
# @incl ./incl/_sgl_parse_init.sh
# @incl ./incl/_sgl_unalias.sh
# @incl ./incl/_sgl_unalias_each.sh
# @incl ./incl/_sgl_unset_func.sh
# @incl ./incl/_sgl_unset_funcs.sh
# @incl ./incl/_sgl_version.sh
# @incl ./incl/_sgl_which.sh

################################################################################
## CLEAN BUILTINS
################################################################################

_sgl_clean_builtin

################################################################################
## CHECK BASH VERSION
################################################################################

if [[ -z "${BASH_VERSINFO}" ]] || [[ ${BASH_VERSINFO[0]} -ne 4 ]]; then
  _sgl_err DPND "bash version 4 required"
fi

################################################################################
## CHECK CORE LIB DIRS
################################################################################

[[ -d ${SGL_LIB}  ]] || _sgl_err DPND "missing lib dir - reinstall \`${SGL}'"
[[ -d ${SGL_HELP} ]] || _sgl_err DPND "missing help dir - reinstall \`${SGL}'"

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
  -- "$@"

################################################################################
## LOAD SOURCE FUNCTION
################################################################################

if [[ -f "${SGL_LIB}/sgl_source" ]]; then
  . "${SGL_LIB}/sgl_source"
else
  _sgl_err DPND "missing core func \`sgl_source' - reinstall \`${SGL}'"
fi

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

len=${#__SGL_OPTS[@]}
for ((i=0; i<len; i++)); do
  opt="${__SGL_OPTS[${i}]}"
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
    -h|-\?|--help)
      if [[ ${__SGL_OPT_BOOL[${i}]} -eq 1 ]]; then
        func="$(_sgl_get_func "${__SGL_OPT_VALS[${i}]}")"
        [[ $? -eq 0 ]] || _sgl_err VAL "invalid \`${SGL}' FUNC \`${func}'"
        _sgl_help "${func}"
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
      val="${__SGL_OPT_VALS[${i}]}"
      val="$(printf '%s' "${val}" | ${sed} -e 's/[,\|]/ /g')"
      re='^[a-z_ \*]+$'
      [[ "${val}" =~ ${re} ]] || _sgl_err VAL "invalid \`${val}' FUNCS"
      if [[ "${val}" =~ \  ]]; then
        if [[ "${val}" =~ \* ]]; then
          arr=()
          while IFS= read -r -d ' ' func; do
            arr[${#arr[@]}]="${func}"
          done <<EOF
"${val} "
EOF
          sgl_source "${arr[@]}"
          unset -v arr
        else
          sgl_source ${val}
        fi
      else
        sgl_source "${val}"
      fi
      unset -v val
      unset -v re
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
      _sgl_err SGL "invalid parsed \`${SGL}' OPTION \`${opt}'"
      ;;
  esac
done
unset -v opt
unset -v len
unset -v i

################################################################################
## PARSE FUNC
################################################################################

[[ ${#__SGL_VALS[@]} -gt 0 ]] || _sgl_err VAL "missing \`${SGL}' FUNC|SCRIPT"

SGL_FUNC="$(_sgl_get_func "${__SGL_VALS[0]}")"
[[ $? -eq 0 ]] || SGL_FUNC=''
readonly SGL_FUNC

if [[ -n "${SGL_FUNC}" ]]; then
  __SGL_VALS[0]="${SGL_FUNC}"
  sgl_source ${SGL_FUNC}
  "${__SGL_VALS[@]}"
  exit $?
fi

################################################################################
## PARSE SCRIPT
################################################################################

readonly SGL_SCRIPT="${__SGL_VALS[0]}"

if [[ ! -f "${SGL_SCRIPT}" ]]; then
  _sgl_err VAL "invalid \`${SGL}' SCRIPT path \`${SGL_SCRIPT}'"
fi

declare -a SGL_ARGS
len=${#__SGL_VALS[@]}
for ((i=1; i<len; i++)); do
  SGL_ARGS[${#SGL_ARGS[@]}]="${__SGL_VALS[${i}]}"
done
readonly -a SGL_ARGS
unset -v len
unset -v i

. "${__SGL_VALS[@]}"
exit $?
