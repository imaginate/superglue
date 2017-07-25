# Helper References
# =================
#
# Global references used throughout the tests. All references defined on this
# page are listed by group in declared order below. Note that all global
# references require the prefix `SGLUE_'.
#
# Main
# ----
# - `SGLUE_NIL'
# - `SGLUE_TEST'
# - `SGLUE_TESTS'
#
# Colors
# ------
# - `SGLUE_UNCOLOR'
# - `SGLUE_RED'
# - `SGLUE_GREEN'
#
# Path
# ----
# - `SGLUE_DFLT_PATH'
# - `SGLUE_PATH'
#
# Commands
# --------
# - `SGLUE_GREP'
# - `SGLUE_MKDIR'
# - `SGLUE_LS'
# - `SGLUE_RM'
# - `SGLUE_SED'
#
# Dummy
# -----
# - `SGLUE_DUMMY'
# - `SGLUE_DUMTMP'
# - `SGLUE_DUMTMP1'
# - `SGLUE_DUMTMP2'
# - `SGLUE_DUMTMP3'
# - `SGLUE_DUMTMP4'
# - `SGLUE_DUMMY_DIRS'
#
# Titles
# ------
# - `SGLUE_HEADER'
# - `SGLUE_FOOTER'
#
# Lengths
# -------
# - `SGLUE_ROW_LENGTH'
# - `SGLUE_SECTION_WIDTH'
#
# Errors
# ------
# - `SGLUE_TEST_ERRORS'
# - `SGLUE_TESTS_FAILED'
#
# Superglue
# ---------
# - `SGLUE_BIN'
# - `SGLUE_LIB'
# - `SGLUE_HELP'
# - `SGLUE_CMDS'
# - `SGLUE_FUNCS'
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2017 Adam A Smith <adam@imaginate.life>
##############################################################################

##############################################################################
## MAIN
##############################################################################

declare -r -x SGLUE_NIL='/dev/null'
declare -r -x SGLUE_TEST="$(pwd -P)"
declare -r -x SGLUE_TESTS="${SGLUE_TEST%/}/tests"

##############################################################################
## COLORS
##############################################################################

declare -r -x SGLUE_UNCOLOR="$(printf '%b' '\033[0;0m')"
declare -r -x SGLUE_RED="$(printf '%b' '\033[0;91m')"
declare -r -x SGLUE_GREEN="$(printf '%b' '\033[0;32m')"

##############################################################################
## PATH
##############################################################################

declare -r SGLUE_DFLT_PATH='/bin:/usr/bin:/usr/local/bin'

declare -a _SGLUE_PATH=()

############################################################
# @func _sglue_mk_path
# @use _sglue_mk_path PATH
# @val PATH
#   The colon separated directory paths to search in for a
#   command.
# @return
#   0  PASS
############################################################
_sglue_mk_path()
{
  local -r PATH="${1}"
  local path

  while IFS= read -d ':' -r path; do
    if [[ -d "${path}" ]]; then
      _SGLUE_PATH+=( "${path}" )
    fi
  done <<< "${PATH%:}:"

  return 0
}

if [[ -n "${SGLUE_SET_PATH%:}" ]]; then
  _sglue_mk_path "${SGLUE_SET_PATH}"
elif [[ -n "${PATH%:}" ]]; then
  _sglue_mk_path "${PATH}"
else
  _sglue_mk_path "${SGLUE_DFLT_PATH}"
fi

if [[ ${#_SGLUE_PATH[@]} -lt 1 ]]; then
  printf '%s' "${SGLUE_RED}INTERNAL TEST ERROR${SGLUE_UNCOLOR} " 1>&2
  if [[ -n "${SGLUE_SET_PATH%:}" ]]; then
    printf '%s\n%s\n' \
      "at least one path in \`PATH' for \`--path' must be a valid directory" \
      "    path-value: \`${SGLUE_SET_PATH}'" \
      1>&2
  elif [[ -n "${PATH%:}" ]]; then
    printf '%s\n%s\n' \
      "at least one path in shell \`\${PATH}' must be a valid directory" \
      "    path-value: \`${PATH}'" \
      1>&2
  else
    printf '%s\n%s\n' \
      "at least one path in default \`\${PATH}' must be a valid directory" \
      "    path-value: \`${SGLUE_DFLT_PATH}'" \
      1>&2
  fi
  exit 9
fi

declare -a -r -x SGLUE_PATH=( "${_SGLUE_PATH[@]}" )

unset _SGLUE_PATH
unset -f _sglue_mk_path

##############################################################################
## COMMANDS
##############################################################################

############################################################
# @func _sglue_chk_cmd
# @use _sglue_chk_cmd NAME
# @val NAME
#   Must be the name of an executable system command.
# @return
#   0  PASS
# @exit-on-error
#   9  INTERNAL_SUPERGLUE_TEST_ERROR
############################################################
_sglue_chk_cmd()
{
  local -r NAME="${1}"
  local path
  local dir

  for dir in "${SGLUE_PATH[@]}"; do
    path="${dir}/${NAME}"
    if [[ -f "${path}" ]] && [[ -x "${path}" ]]; then
      return 0
    fi
  done

  _sglue_cmd_err "${NAME}"
}

############################################################
# @func _sglue_chk_cmds
# @use _sglue_chk_cmds ...NAME
# @val NAME
#   Must be the name of an executable system command.
# @return
#   0  PASS
# @exit-on-error
#   9  INTERNAL_SUPERGLUE_TEST_ERROR
############################################################
_sglue_chk_cmds()
{
  local name

  for name in "${@}"; do
    _sglue_chk_cmd "${name}"
  done

  return 0
}

############################################################
# @func _sglue_cmd_err
# @use _sglue_cmd_err NAME
# @val NAME
#   Must be the name of the missing system command.
# @exit
#   9  INTERNAL_SUPERGLUE_TEST_ERROR
############################################################
_sglue_cmd_err()
{
  local -r TITLE="${SGLUE_RED}INTERNAL TEST ERROR${SGLUE_UNCOLOR}"
  local -r MSG="missing required system command \`${1}'"

  printf '%s\n' "${TITLE} ${MSG}" 1>&2
  printf '%s\n' "    searched-in:" 1>&2

  local dir

  for dir in "${SGLUE_PATH[@]}"; do
    printf '%s\n' "    - \`${dir}'" 1>&2
  done

  exit 9
}

############################################################
# @func _sglue_get_cmd
# @use _sglue_get_cmd NAME
# @val NAME
#   Must be the name of an executable system command.
# @return
#   0  PASS
############################################################
_sglue_get_cmd()
{
  local -r NAME="${1}"
  local path
  local dir

  for dir in "${SGLUE_PATH[@]}"; do
    path="${dir}/${NAME}"
    if [[ -f "${path}" ]] && [[ -x "${path}" ]]; then
      printf '%s' "${path}"
      return 0
    fi
  done
  return 0
}

_sglue_chk_cmds cat chmod cp grep mkdir ls rm sed

declare -r -x SGLUE_CAT="$(_sglue_get_cmd cat)"
declare -r -x SGLUE_CHMOD="$(_sglue_get_cmd chmod)"
declare -r -x SGLUE_CP="$(_sglue_get_cmd cp)"
declare -r -x SGLUE_GREP="$(_sglue_get_cmd grep)"
declare -r -x SGLUE_MKDIR="$(_sglue_get_cmd mkdir)"
declare -r -x SGLUE_LS="$(_sglue_get_cmd ls)"
declare -r -x SGLUE_RM="$(_sglue_get_cmd rm)"
declare -r -x SGLUE_SED="$(_sglue_get_cmd sed)"

unset -f _sglue_chk_cmd
unset -f _sglue_chk_cmds
unset -f _sglue_cmd_err
unset -f _sglue_get_cmd

##############################################################################
## DUMMY
##############################################################################

declare -r -x SGLUE_DUMMY="${SGLUE_TEST%/}/dummy.sgl.d"
declare -r -x SGLUE_DUMTMP="${SGLUE_DUMMY}/tmp"
declare -r -x SGLUE_DUMTMP1="${SGLUE_DUMMY}/tmp1"
declare -r -x SGLUE_DUMTMP2="${SGLUE_DUMMY}/tmp2"
declare -r -x SGLUE_DUMTMP3="${SGLUE_DUMMY}/tmp3"
declare -r -x SGLUE_DUMTMP4="${SGLUE_DUMTMP1}/tmp4"

declare -a -r -x SGLUE_DUMMY_DIRS=( \
  "${SGLUE_DUMMY}"   \
  "${SGLUE_DUMTMP}"  \
  "${SGLUE_DUMTMP1}" \
  "${SGLUE_DUMTMP2}" \
  "${SGLUE_DUMTMP3}" \
  "${SGLUE_DUMTMP4}" )

##############################################################################
## TITLES
##############################################################################

declare -r -x SGLUE_HEADER='START SUPERGLUE TESTS'
declare -r -x SGLUE_FOOTER='END SUPERGLUE TESTS'

##############################################################################
## LENGTHS
##############################################################################

declare -i -r -x SGLUE_ROW_LENGTH=36
declare -i -r -x SGLUE_SECTION_WIDTH=-14

##############################################################################
## ERRORS
##############################################################################

declare -a -x SGLUE_TEST_ERRORS=()
declare -i -x SGLUE_TESTS_FAILED=0

##############################################################################
## SUPERGLUE
##############################################################################

declare -r -x SGLUE_BIN='/bin'
declare -r -x SGLUE_LIB='/usr/lib/superglue'
declare -r -x SGLUE_HELP='/usr/share/superglue/help'

declare -a -r -x SGLUE_CMDS=( \
  sgl       \
  sglue     \
  superglue )

declare -a -r -x SGLUE_FUNCS=( \
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

