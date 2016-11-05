#!/bin/bash --posix
#
# Install `superglue' files, executables, and scripts located in `./src'.
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use ./install.sh [...OPTION]
# @opt -?|-h|--help    Print help info and exit.
# @opt -f|--force      If a destination exists overwrite it.
# @opt -q|--quiet      Do not print any messages to `stdout'.
# @opt -x|--uninstall  Remove `superglue' files and directories.
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

################################################################################
## SECTIONS
## - CLEAN BUILTINS
## - DEFINE COLORS
## - DEFINE ECHO
## - CHECK BASH VERSION
## - DEFINE HELPER REFS
## - DEFINE TAG PATTERNS
## - DEFINE GEN HELPERS
## - DEFINE TAG HELPERS
## - CHECK $0 VALUE
## - CHECK PERMISSIONS
## - DEFINE COMMANDS
## - CHECK COMMANDS
## - CHANGE DIRECTORY
## - DEFINE SRC PATHS
## - CHECK SRC PATHS
## - PARSE OPTIONS
## - PRINT HEADER
## - DEFINE DEST DIRS
## - MAKE DEST DIRS
## - DEFINE METHODS
## - INSTALL COMMANDS
## - INSTALL FUNCTIONS
## - INSTALL HELP FILES
## - END INSTALL
################################################################################

################################################################################
## CLEAN BUILTINS
################################################################################

############################################################
# @func sglue_unset_func
# @use sglue_unset_func BUILTIN
# @val BUILTIN  A bash shell builtin command.
# @return
#   0  PASS
############################################################
sglue_unset_func()
{
  if unset -f $1 2> /dev/null; then
    return 0
  else
    return 0
  fi
}

############################################################
# @func sglue_unset_funcs
# @use sglue_unset_funcs ...BUILTIN
# @val BUILTIN  A bash shell builtin command.
# @return
#   0  PASS
############################################################
sglue_unset_funcs()
{
  while [ $# -gt 0 ]; do
    sglue_unset_func $1
    shift
  done
}

# See below for complete reference.
# - [Special Builtins](http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_14)
# - [Bourne Builtins](https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#Bourne-Shell-Builtins)
# - [Bash Builtins](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#Bash-Builtins)

# Note that bash is in [posix mode](https://www.gnu.org/software/bash/manual/html_node/Bash-POSIX-Mode.html#Bash-POSIX-Mode)
# which disallows function names to be the same as special builtins.

sglue_unset_func shopt
shopt -u expand_aliases
sglue_unset_funcs cd getopts hash pwd test umask
sglue_unset_funcs bind builtin caller command declare echo enable false help \
  let local logout printf read shopt source type typeset ulimit
unset -f sglue_unset_func
unset -f sglue_unset_funcs

################################################################################
## DEFINE COLORS
################################################################################

SGLUE_UNCOLOR=''
SGLUE_RED=''
SGLUE_GREEN=''

if [[ -t 1 ]]; then
  SGLUE_UNCOLOR="$(printf '%b' '\033[0;0m')"
  SGLUE_RED="$(printf '%b' '\033[0;91m')"
  SGLUE_GREEN="$(printf '%b' '\033[0;32m')"
fi

############################################################
# @func mkgreen
# @use mkgreen ...MSG
# @val MSG  Can be any valid string.
# @return
#   0  PASS
############################################################
mkgreen()
{
  printf '%s' "${SGLUE_GREEN}${*}${SGLUE_UNCOLOR}"
}

############################################################
# @func mkred
# @use mkred ...MSG
# @val MSG  Can be any valid string.
# @return
#   0  PASS
############################################################
mkred()
{
  printf '%s' "${SGLUE_RED}${*}${SGLUE_UNCOLOR}"
}

################################################################################
## DEFINE ECHO
################################################################################

############################################################
# @func echo
# @use echo ...MSG
# @val MSG  Can be any valid string.
# @return
#   0  PASS
############################################################
echo()
{
  printf "%s\n" "${*}"
}

################################################################################
## CHECK BASH VERSION
################################################################################

if [[ -z "${BASH_VERSINFO}" ]] || [[ ${BASH_VERSINFO[0]} -ne 4 ]]; then
  echo "$(mkred DEPEND-ERROR) bash version 4 required" 1>&2
  exit 5
fi

################################################################################
## DEFINE HELPER REFS
################################################################################

declare -ir SGLUE_ROW_LEN=36

if readonly NIL='/dev/null' 2> /dev/null; then : ; else : ; fi

################################################################################
## DEFINE TAG PATTERNS
################################################################################

readonly SGLUE_TAG_SGL='^[[:blank:]]*#[[:blank:]]*@superglue[[:blank:]]\+'
readonly SGLUE_TAG_VER='^[[:blank:]]*#[[:blank:]]*@version[[:blank:]]\+'
readonly SGLUE_TAG_DEST='^[[:blank:]]*#[[:blank:]]*@dest[[:blank:]]\+'
readonly SGLUE_TAG_INCL='^[[:blank:]]*#[[:blank:]]*@incl[[:blank:]]\+'
readonly SGLUE_TAG_MODE='^[[:blank:]]*#[[:blank:]]*@mode[[:blank:]]\+'

################################################################################
## DEFINE GEN HELPERS
################################################################################

############################################################
# Prints an error message and exits the process.
#
# @func sglue_err
# @use sglue_err ERR ...MSG
# @val ERR  Must be one of the below errors.
#   `ERR'   An unknown error (exit= `1').
#   `OPT'   An invalid option (exit= `2').
#   `VAL'   An invalid or missing value (exit= `3').
#   `AUTH'  A permissions error (exit= `4').
#   `DPND'  A dependency error (exit= `5').
#   `CHLD'  A child process exited unsuccessfully (exit= `6').
#   `SGL'   A `superglue' script error (exit= `7').
# @val MSG  Can be any valid string.
# @exit
#   1  ERR   An unknown error.
#   2  OPT   An invalid option.
#   3  VAL   An invalid or missing value.
#   4  AUTH  A permissions error.
#   5  DPND  A dependency error.
#   6  CHLD  A child process exited unsuccessfully.
#   7  SGL   A `superglue' script error.
############################################################
sglue_err()
{
  local -i code
  local title

  case "${1}" in
    ERR)
      title='ERROR'
      code=1
    ;;
    OPT)
      title='OPTION-ERROR'
      code=2
    ;;
    VAL)
      title='VALUE-ERROR'
      code=3
    ;;
    AUTH)
      title='AUTH-ERROR'
      code=4
    ;;
    DPND)
      title='DEPEND-ERROR'
      code=5
    ;;
    CHLD)
      title='CHILD-ERROR'
      code=6
    ;;
    SGL)
      title='SUPERGLUE-ERROR'
      code=7
    ;;
    *)
      sglue_err SGL "invalid \`sglue_err' ERR \`${1}'"
    ;;
  esac

  echo " $(mkred ${title}) ${*:2}" 1>&2
  sglue_footer
  exit ${code}
}

############################################################
# Prints the valid executable path for a command. If no valid
# path exists then the command name is printed. The command
# must exist in one of the following directories (in order
# of preference).
#   `/bin/CMD'
#   `/usr/bin/CMD'
#   `/usr/local/bin/CMD'
#
# @func sglue_which
# @use sglue_which CMD
# @val CMD  Must be an executable.
# @return
#   0  PASS
############################################################
sglue_which()
{
  local cmd="${1}"

  if [[ -x "/bin/${1}" ]]; then
    cmd="/bin/${1}"
  elif [[ -x "/usr/bin/${1}" ]]; then
    cmd="/usr/bin/${1}"
  elif [[ -x "/usr/local/bin/${1}" ]]; then
    cmd="/usr/local/bin/${1}"
  fi
  printf '%s' "${cmd}"
}

############################################################
# Checks the validity of a path. If the path is invalid an
# error is printed and the process is exited.
#
# @func sglue_chk
# @use sglue_chk TYPE ...PATH
# @val PATH  Must be a valid file path (see TYPE options).
# @val TYPE  Must be one of the below options.
#   `CMD'   PATH must be a valid executable path.
#   `DIR'   PATH must be a valid directory path.
#   `FILE'  PATH must be a valid readable file path.
# @return
#   0  PASS
############################################################
sglue_chk()
{
  local -r FN='sglue_chk'
  local -r TYPE="${1}"
  local path

  shift
  case "${TYPE}" in
    CMD)
      for path in "$@"; do
        [[ -n "${path}" ]] || sglue_err SGL "invalid \`${FN}' PATH \`${path}'"
        [[ "${path}" =~ ^/ ]] || sglue_err DPND "could not find command \`${path}'"
        [[ -x "${path}" ]] || sglue_err DPND "invalid executable path \`${path}'"
      done
    ;;
    DIR)
      for path in "$@"; do
        [[ -n "${path}" ]] || sglue_err SGL "invalid \`${FN}' PATH \`${path}'"
        [[ -d "${path}" ]] || sglue_err DPND "invalid directory path \`${path}'"
      done
    ;;
    FILE)
      for path in "$@"; do
        [[ -n "${path}" ]] || sglue_err SGL "invalid \`${FN}' PATH \`${path}'"
        [[ -f "${path}" ]] || sglue_err DPND "invalid file path \`${path}'"
        [[ -r "${path}" ]] || sglue_err DPND "invalid readable path \`${path}'"
      done
    ;;
    *)
      sglue_err SGL "invalid \`${FN}' TYPE \`${TYPE}'"
    ;;
  esac
}

############################################################
# Prints a row of dashes.
#
# @func sglue_dashes
# @use sglue_dashes
# @return
#   0  PASS
############################################################
sglue_dashes()
{
  local dashes
  local -i i
  local -i len=${SGLUE_ROW_LEN}

  for ((i=0; i<len; i++)); do
    dashes="${dashes}-"
  done
  echo "${dashes}"
}

############################################################
# Prints this script's header.
#
# @func sglue_header
# @use sglue_header
# @return
#   0  PASS
############################################################
sglue_header()
{
  [[ ${SGLUE_QUIET} -eq 1 ]] && return 0

  sglue_dashes
  echo "## START SUPERGLUE ${SGLUE_TITLE}"
  sglue_dashes

  SGLUE_HEADER=1
}

############################################################
# Prints this script's footer.
#
# @func sglue_footer
# @use sglue_footer
# @return
#   0  PASS
############################################################
sglue_footer()
{
  [[ ${SGLUE_QUIET}  -eq 1 ]] && return 0
  [[ ${SGLUE_HEADER} -eq 1 ]] || return 0

  sglue_dashes
  echo "## END SUPERGLUE ${SGLUE_TITLE}"
  sglue_dashes
}

############################################################
# Print a note of the current step.
#
# @func sglue_step
# @use sglue_step ...DESCRIP
# @return
#   0  PASS
############################################################
sglue_step()
{
  local step="${*}"
  local action

  [[ ${SGLUE_QUIET} -eq 1 ]] && return 0

  if [[ ${SGLUE_ACTION} == 'mk' ]]; then
    action='Installing'
  else
    action='Uninstalling'
  fi

  echo " ${action} ${step}..."
}

############################################################
# Print the final result.
#
# @func sglue_result
# @use sglue_result
# @return
#   0  PASS
############################################################
sglue_result()
{
  local msg

  [[ ${SGLUE_QUIET} -eq 1 ]] && return 0

  if [[ ${SGLUE_ACTION} == 'mk' ]]; then
    msg='Installation Success'
  else
    msg='Removal Complete'
  fi

  sglue_dashes
  echo " $(mkgreen "${msg}")"
}

################################################################################
## DEFINE TAG HELPERS
################################################################################

############################################################
# Trims the tag and blank space from a line.
#
# @func sglue_untag
# @use sglue_untag LINE
# @return
#   0  PASS
############################################################
sglue_untag()
{
  [[ -n "${1}" ]] || return 0

  printf '%s' "${1}" | ${sed} \
    -e 's/^[[:blank:]]*#[[:blank:]]*@[[:lower:]]\+[[:blank:]]\+//' \
    -e 's/[[:blank:]]\+$//'
}

############################################################
# @func sglue_has_sgl
# @use sglue_has_sgl SRC
# @val SRC  Must be a valid file path.
# @return
#   0  PASS
#   1  FAIL
############################################################
sglue_has_sgl()
{
  if ${grep} "${SGLUE_TAG_SGL}" "${1}" > ${NIL} 2>&1; then
    return 0
  else
    return 1
  fi
}

############################################################
# @func sglue_has_dest
# @use sglue_has_dest SRC
# @val SRC  Must be a valid file path.
# @return
#   0  PASS
#   1  FAIL
############################################################
sglue_has_dest()
{
  if ${grep} "${SGLUE_TAG_DEST}" "${1}" > ${NIL} 2>&1; then
    return 0
  else
    return 1
  fi
}

############################################################
# @func sglue_has_incl
# @use sglue_has_incl SRC
# @val SRC  Must be a valid file path.
# @return
#   0  PASS
#   1  FAIL
############################################################
sglue_has_incl()
{
  if ${grep} "${SGLUE_TAG_INCL}" "${1}" > ${NIL} 2>&1; then
    return 0
  else
    return 1
  fi
}

############################################################
# @func sglue_get_dest
# @use sglue_get_dest SRC
# @val SRC  Must be a valid file path.
# @return
#   0  PASS
############################################################
sglue_get_dest()
{
  local line

  while IFS= read -r line; do
    sglue_untag "${line}"
  done <<< "$(${grep} "${SGLUE_TAG_DEST}" "${1}" 2> ${NIL})"
}

############################################################
# @func sglue_get_mode
# @use sglue_get_mode SRC
# @val SRC  Must be a valid file path.
# @return
#   0  PASS
############################################################
sglue_get_mode()
{
  sglue_untag "$(${grep} -m 1 "${SGLUE_TAG_MODE}" "${1}" 2> ${NIL})"
  return 0
}

################################################################################
## CHECK $0 VALUE
################################################################################

if [[ ! "$0" =~ install\.sh$ ]]; then
  sglue_err CHLD "invalid shell script param \$0 \`$0'"
fi

################################################################################
## CHECK PERMISSIONS
################################################################################

if [[ ${EUID} -ne 0 ]]; then
  sudo=$(sglue_which sudo)
  [[ "${sudo}" =~ ^/ ]] || sglue_err AUTH 'invalid user permissions'
  ${sudo} "$0" "$@"
  exit $?
fi

################################################################################
## DEFINE COMMANDS
################################################################################

cat=$(sglue_which cat)
chmod=$(sglue_which chmod)
chown=$(sglue_which chown)
cp=$(sglue_which cp)
grep=$(sglue_which grep)
mkdir=$(sglue_which mkdir)
rm=$(sglue_which rm)
sed=$(sglue_which sed)

################################################################################
## CHECK COMMANDS
################################################################################

sglue_chk CMD ${cat} ${chmod} ${chown} ${cp} ${grep} ${mkdir} ${rm} ${sed}

################################################################################
## CHANGE DIRECTORY
################################################################################

[[ "$0" =~ ^(\./)?install\.sh$ ]] || cd "${0%/*}"

################################################################################
## DEFINE SRC PATHS
################################################################################

readonly SGLUE_REPO_D="$(pwd -P)"
readonly SGLUE_SRC_D="${SGLUE_REPO_D}/src"
readonly SGLUE_HELP_D="${SGLUE_SRC_D}/help"

################################################################################
## CHECK SRC PATHS
################################################################################

sglue_chk DIR "${SGLUE_REPO_D}" "${SGLUE_SRC_D}" "${SGLUE_HELP_D}"

################################################################################
## PARSE OPTIONS
################################################################################

SGLUE_ACTION='mk'
SGLUE_TITLE='INSTALL'

declare -i SGLUE_HEADER=0
declare -i SGLUE_QUIET=0
declare -i SGLUE_FORCE=0

while ((${#} > 0)); do
  case "${1}" in
    -\?|-h|--help)
      echo "$(${cat} "${SGLUE_REPO_D}/install.help")"
      exit 0
    ;;
    -f|--force)
      SGLUE_FORCE=1
    ;;
    -q|--quiet)
      SGLUE_QUIET=1
    ;;
    -x|--uninstall)
      SGLUE_ACTION='rm'
      SGLUE_TITLE='UNINSTALL'
    ;;
    *)
      sglue_err OPT "invalid \`install.sh' OPTION \`${1}'"
    ;;
  esac
  shift
done

################################################################################
## PRINT HEADER
################################################################################

sglue_header

################################################################################
## DEFINE DEST DIRS
################################################################################

readonly SGLUE_LIB_DEST='/lib/superglue'
readonly SGLUE_HELP_DEST='/usr/share/superglue/help'

################################################################################
## DEFINE MAKE METHODS
################################################################################

############################################################
# @func sglue_mk
# @use sglue_mk SRC
# @val SRC  Can be any type file path.
# @return
#   0  PASS
############################################################
sglue_mk()
{
  local src="${1}"
  local mode
  local path

  if [[ -d "${src}" ]]; then
    for path in "${src}"/*.sh; do
      sglue_mk "${path}"
    done
  elif [[ -f "${src}" ]] && sglue_has_dest "${src}"; then
    sglue_step "${src##*/src/}"
    mode="$(sglue_get_mode "${src}")"
    while IFS= read -r path; do
      sglue_mk_dest "${src}" "${path}" "${mode}"
    done <<< "$(sglue_get_dest "${src}")"
  fi
  return 0
}

############################################################
# @func sglue_mk_dest
# @use sglue_mk_dest SRC DEST MODE
# @val DEST  Must be a valid file path.
# @val MODE  Must be a valid file mode.
# @val SRC   Must be a valid file path.
# @return
#   0  PASS
############################################################
sglue_mk_dest()
{
  local src="${1}"
  local dest="${2}"
  local mode="${3}"

  [[ -n "${mode}" ]] || mode='0644'

  if [[ ! "${dest}" =~ ^/[^/]+/.*[^/]$ ]] || [[ ! -d "${dest%/*}" ]]; then
    sglue_err VAL "invalid DEST \`${dest}' in SRC \`${src}'"
  fi
  if [[ ! -f "${dest}" ]]; then
    if [[ -d "${dest}" ]]; then
      sglue_err VAL "a dir exists for DEST \`${dest}' in SRC \`${src}'"
    fi
    if [[ -a "${dest}" ]]; then
      sglue_err VAL "a non-file exists for DEST \`${dest}' in SRC \`${src}'"
    fi
  elif [[ ${SGLUE_FORCE} -ne 1 ]]; then
    sglue_err VAL "DEST \`${dest}' already exists (use \`--force' to overwrite)"
  fi

  ${cp} -T "${src}" "${dest}"
  sglue_mk_incl "${src}" "${dest}"
  ${chown} root:root "${dest}"
  ${chmod} ${mode} "${dest}"
}

############################################################
# @func sglue_mk_incl
# @use sglue_mk_incl SRC DEST
# @val DEST  Must be a valid file path.
# @val SRC   Must be a valid file path.
# @return
#   0  PASS
############################################################
sglue_mk_incl()
{
  local src="${1}"
  local dest="${2}"
  local path
  local line
  local content
  local subline

  sglue_has_incl "${dest}" || return 0

  while IFS= read -r line; do
    path="$(sglue_untag "${line}")"
    [[ "${path}" =~ ^/ ]] || path="${src%/*}/${path}"
    if [[ ! -f "${path}" ]]; then
      sglue_err VAL "invalid INCL path \`${path}' in SRC \`${src}'"
    fi
    line="$(printf '%s' "${line}" | ${sed} -e 's/[]\/$*.^|[]/\\&/g')"
    content=''
    while IFS= read -r subline; do
      content="${content}${subline}\\n"
    done <<< "$(${sed} -e '1,6 d' -e 's/[\/&]/\\&/g' "${path}")"
    ${sed} -i -e "s/${line}/${content}/" "${dest}"
  done <<< "$(${grep} "${SGLUE_TAG_INCL}" "${dest}" 2> ${NIL})"
}

################################################################################
## DEFINE REMOVE METHODS
################################################################################

############################################################
# @func sglue_rm
# @use sglue_rm SRC
# @val SRC  Can be any type file path.
# @return
#   0  PASS
############################################################
sglue_rm()
{
  local src="${1}"
  local path

  if [[ -d "${src}" ]]; then
    for path in "${src}"/*.sh; do
      sglue_rm "${path}"
    done
  elif [[ -f "${src}" ]] && sglue_has_dest "${src}"; then
    sglue_step "${src##*/src/}"
    while IFS= read -r path; do
      sglue_rm_dest "${src}" "${path}"
    done <<< "$(sglue_get_dest "${src}")"
  fi
  return 0
}

############################################################
# @func sglue_rm_dest
# @use sglue_rm_dest SRC DEST
# @val DEST  Must be a valid file path.
# @val SRC   Must be a valid file path.
# @return
#   0  PASS
############################################################
sglue_rm_dest()
{
  local src="${1}"
  local dest="${2}"

  if [[ ! "${dest}" =~ ^/[^/]+/.*[^/]$ ]]; then
    sglue_err VAL "invalid DEST \`${dest}' in SRC \`${src}'"
  fi

  [[ -f "${dest}" ]] && ${rm} "${dest}"
}

################################################################################
## RUN INSTALL
################################################################################

if [[ "${SGLUE_ACTION}" == 'mk' ]]; then

  sglue_step directories
  [[ -d "${SGLUE_LIB_DEST}"  ]] || ${mkdir} -m 0755 -p "${SGLUE_LIB_DEST}"
  [[ -d "${SGLUE_HELP_DEST}" ]] || ${mkdir} -m 0755 -p "${SGLUE_HELP_DEST}"

  sglue_mk "${SGLUE_SRC_D}"

  sglue_step help files
  ${rm} -rf "${SGLUE_HELP_DEST}"
  ${cp} -rt "${SGLUE_HELP_DEST%/*}" "${SGLUE_HELP_D}"

elif [[ "${SGLUE_ACTION}" == 'rm' ]]; then

  sglue_rm "${SGLUE_SRC_D}"

  sglue_step help files
  [[ -d "${SGLUE_HELP_DEST}" ]] && ${rm} -rf "${SGLUE_HELP_DEST}"

  sglue_step directories
  [[ -d "${SGLUE_LIB_DEST}"     ]] && ${rm} -rf "${SGLUE_LIB_DEST}"
  [[ -d "${SGLUE_HELP_DEST%/*}" ]] && ${rm} -rf "${SGLUE_HELP_DEST%/*}"

fi

################################################################################
## END INSTALL
################################################################################

sglue_result
sglue_footer
exit 0
