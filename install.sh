#!/bin/bash --posix
#
# Install `superglue' files, executables, and scripts located in `./src'.
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2017 Adam A Smith <adam@imaginate.life>
#
# @use ./install.sh [...OPTION]
#
# @opt -?|-h|--help    Print help info and exit.
# @opt -b|--bin=DIR    Override the default binary directory of `/bin'.
# @opt -f|--force      If a destination exists overwrite it.
# @opt -l|--lib=DIR    Override the default library directory of `/usr/lib'.
# @opt -q|--quiet      Do not print any messages to `stdout'.
# @opt -s|--share=DIR  Override the default share directory of `/usr/share'.
# @opt -x|--uninstall  Remove `superglue' files and directories.
#
# @val DIR
#   Must be a valid absolute directory path.
#
# @exit
#   0  PASS  A successful exit.
#   1  ERR   An unknown error.
#   2  OPT   An invalid option.
#   3  VAL   An invalid or missing value.
#   4  AUTH  A permissions error.
#   5  DPND  A dependency error.
#   6  CHLD  A child process exited unsuccessfully.
#   7  SGL   A `superglue' script error.
##############################################################################

##############################################################################
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
##############################################################################

##############################################################################
## CLEAN BUILTINS
##############################################################################

############################################################
# @func sglue_unset_func
# @use sglue_unset_func BUILTIN
# @val BUILTIN  A bash shell builtin command.
# @return
#   0  PASS
############################################################
sglue_unset_func()
{
  if unset -f "${1}" 2> /dev/null; then
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
  while [[ ${#} -gt 0 ]]; do
    sglue_unset_func "${1}"
    shift
  done
  return 0
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

##############################################################################
## DEFINE COLORS
##############################################################################

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

##############################################################################
## DEFINE PRINT HELPERS
##############################################################################

############################################################
# @func out
# @use out [...MSG]
# @val MSG  Can be any valid string.
# @return
#   0  PASS
############################################################
out()
{
  printf '%s' "${*}"
}

############################################################
# @func out2
# @use out2 [...MSG]
# @val MSG  Can be any valid string.
# @return
#   0  PASS
############################################################
out2()
{
  printf '%s' "${*}" 1>&2
}

############################################################
# @func echo
# @use echo [...MSG]
# @val MSG  Can be any valid string.
# @return
#   0  PASS
############################################################
echo()
{
  printf '%s\n' "${*}"
}

############################################################
# @func echo2
# @use echo2 [...MSG]
# @val MSG  Can be any valid string.
# @return
#   0  PASS
############################################################
echo2()
{
  printf '%s\n' "${*}" 1>&2
}

##############################################################################
## CHECK BASH VERSION
##############################################################################

if [[ -z "${BASH_VERSINFO}" ]] || [[ "${BASH_VERSINFO[0]}" != '4' ]]; then
  echo2 "$(mkred DEPEND-ERROR) bash version 4 required"
  exit 5
fi

##############################################################################
## DEFINE HELPER REFS
##############################################################################

declare -i -r SGLUE_ROW_LEN=36
if [[ "${NIL}" != '/dev/null' ]]; then
  declare -r NIL='/dev/null'
fi

##############################################################################
## DEFINE TAG PATTERNS
##############################################################################

readonly SGLUE_TAG_SGL='^[[:blank:]]*#[[:blank:]]*@superglue[[:blank:]]\+'
readonly SGLUE_TAG_VER='^[[:blank:]]*#[[:blank:]]*@version[[:blank:]]\+'
readonly SGLUE_TAG_DEST='^[[:blank:]]*#[[:blank:]]*@dest[[:blank:]]\+'
readonly SGLUE_TAG_INCL='^[[:blank:]]*#[[:blank:]]*@include[[:blank:]]\+'
readonly SGLUE_TAG_MODE='^[[:blank:]]*#[[:blank:]]*@mode[[:blank:]]\+'

##############################################################################
## DEFINE GEN HELPERS
##############################################################################

############################################################
# Prints an error message and exits the process.
#
# @func sglue_err
# @use sglue_err ERR [...MSG]
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
  shift

  title="$(mkred "${title}")"
  echo2 " ${title} ${*}"
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
  local path

  for path in "/bin/${1}" "/usr/bin/${1}" "/usr/local/bin/${1}"; do
    if [[ -x "${path}" ]]; then
      out "${path}"
      return 0
    fi
  done
  out "${1}"
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

  shift
  case "${TYPE}" in
    CMD)
      sglue_chk_cmd "${@}"
      ;;
    DIR)
      sglue_chk_dir "${@}"
      ;;
    FILE)
      sglue_chk_file "${@}"
      ;;
    *)
      sglue_err SGL "invalid \`${FN}' TYPE \`${TYPE}'"
      ;;
  esac
}

############################################################
# @func sglue_chk_cmd
# @use sglue_chk_cmd ...PATH
# @val PATH  Must be a valid executable path.
# @return
#   0  PASS
############################################################
sglue_chk_cmd()
{
  local path

  if [[ ${#} -eq 0 ]]; then
    return 0
  fi

  for path in "${@}"; do
    if [[ -z "${path}" ]]; then
      sglue_err SGL "invalid \`${FN}' PATH \`${path}'"
    fi
    if [[ "${path:0:1}" != '/' ]]; then
      sglue_err DPND "could not find command \`${path}'"
    fi
    if [[ ! -x "${path}" ]]; then
      sglue_err DPND "invalid executable path \`${path}'"
    fi
  done
  return 0
}

############################################################
# @func sglue_chk_dir
# @use sglue_chk_dir ...PATH
# @val PATH  Must be a valid directory path.
# @return
#   0  PASS
############################################################
sglue_chk_dir()
{
  local path

  if [[ ${#} -eq 0 ]]; then 
    return 0
  fi

  for path in "${@}"; do
    if [[ -z "${path}" ]]; then
      sglue_err SGL "invalid \`${FN}' PATH \`${path}'"
    fi
    if [[ ! -d "${path}" ]]; then
      sglue_err DPND "invalid directory path \`${path}'"
    fi
  done
  return 0
}

############################################################
# @func sglue_chk_file
# @use sglue_chk_file ...PATH
# @val PATH  Must be a valid file path.
# @return
#   0  PASS
############################################################
sglue_chk_file()
{
  local path

  if [[ ${#} -eq 0 ]]; then 
    return 0
  fi

  for path in "${@}"; do
    if [[ -z "${path}" ]]; then
      sglue_err SGL "invalid \`${FN}' PATH \`${path}'"
    fi
    if [[ ! -f "${path}" ]]; then
      sglue_err DPND "invalid file path \`${path}'"
    fi
    if [[ ! -r "${path}" ]]; then
      sglue_err DPND "invalid readable path \`${path}'"
    fi
  done
  return 0
}

############################################################
# @func sglue_chk_exit
# @use sglue_chk_exit CODE CMD ...ARG
# @val ARG   Must be a valid argument passed to CMD.
# @val CMD   Must be a valid executable command.
# @val CODE  Must be the exit code from the CMD.
# @return
#   0  PASS
############################################################
sglue_chk_exit()
{
  local -r CODE="${1}"
  local cmd
  local arg

  if [[ "${CODE}" == '0' ]]; then
    return 0
  fi
  shift

  if [[ ${#} -gt 0 ]]; then
    for arg in "${@}"; do
      if [[ -z "${arg}" ]]; then
        arg='""'
      elif [[ "${arg}" =~ [[:space:]] ]]; then
        arg="\"${arg}\""
      fi
      if [[ -n "${cmd}" ]]; then
        cmd="${cmd} ${arg}"
      else
        cmd="${arg}"
      fi
    done
  fi
  sglue_err CHLD "\`${cmd}' exited with CODE \`${CODE}'"
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
  local -i i=0

  while [[ ${i} -lt ${SGLUE_ROW_LEN} ]]; do
    out '-'
    i=$(( i + 1 ))
  done
  echo
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
  if [[ ${SGLUE_QUIET} -eq 1 ]]; then
    return 0
  fi

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
  if [[ ${SGLUE_QUIET}  -eq 1 ]]; then
    return 0
  fi
  if [[ ${SGLUE_HEADER} -ne 1 ]]; then
    return 0
  fi

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
  if [[ ${SGLUE_QUIET} -eq 1 ]]; then
    return 0
  fi

  out ' '
  if [[ ${SGLUE_ACTION} == 'mk' ]]; then
    out 'Installing'
  else
    out 'Uninstalling'
  fi
  echo " ${*}..."
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
  if [[ ${SGLUE_QUIET} -eq 1 ]]; then
    return 0
  fi

  sglue_dashes
  out ' '
  if [[ ${SGLUE_ACTION} == 'mk' ]]; then
    mkgreen 'Installation Success'
  else
    mkgreen 'Removal Complete'
  fi
  echo
}

##############################################################################
## DEFINE TAG HELPERS
##############################################################################

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
  if [[ -z "${1}" ]]; then
    return 0
  fi

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
  if ${grep} -e "${SGLUE_TAG_SGL}" -- "${1}" > /dev/null 2>&1; then
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
  if ${grep} -e "${SGLUE_TAG_DEST}" -- "${1}" > /dev/null 2>&1; then
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
  if ${grep} -e "${SGLUE_TAG_INCL}" -- "${1}" > /dev/null 2>&1; then
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
  local src="${1}"
  local dest
  local line

  while IFS= read -r line; do
    dest="$(sglue_untag "${line}")"
    if [[ "${dest:0:1}" == '$' ]]; then
      case "${dest%%/*}" in
        \$BIN)
          dest="${SGLUE_BIN}/${dest#*/}"
          ;;
        \$LIB)
          dest="${SGLUE_LIB}/${dest#*/}"
          ;;
        \$SHARE)
          dest="${SGLUE_SHARE}/${dest#*/}"
          ;;
      esac
    fi
    echo "${dest}"
  done <<< "$(${grep} -e "${SGLUE_TAG_DEST}" -- "${src}")"
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
  sglue_untag "$(${grep} -m 1 -e "${SGLUE_TAG_MODE}" -- "${1}")"
  return 0
}

##############################################################################
## CHECK $0 VALUE
##############################################################################

if [[ ! "${0}" =~ install\.sh$ ]]; then
  sglue_err CHLD "invalid shell script param \$0 \`${0}'"
fi

##############################################################################
## CHECK PERMISSIONS
##############################################################################

if [[ ${EUID} -ne 0 ]]; then
  sudo="$(sglue_which sudo)"
  if [[ "${sudo:0:1}" != '/' ]]; then
    sglue_err AUTH 'invalid user permissions'
  fi
  ${sudo} "${0}" "${@}"
  exit ${?}
fi

##############################################################################
## DEFINE COMMANDS
##############################################################################

cat="$(sglue_which cat)"
chmod="$(sglue_which chmod)"
chown="$(sglue_which chown)"
cp="$(sglue_which cp)"
grep="$(sglue_which grep)"
ls="$(sglue_which ls)"
mkdir="$(sglue_which mkdir)"
mv="$(sglue_which mv)"
rm="$(sglue_which rm)"
sed="$(sglue_which sed)"

##############################################################################
## CHECK COMMANDS
##############################################################################

sglue_chk CMD ${cat} ${chmod} ${chown} ${cp} ${grep} ${ls} ${mkdir} ${mv} \
  ${rm} ${sed}

##############################################################################
## CHANGE DIRECTORY
##############################################################################

if [[ ! "${0}" =~ ^(\./)?install\.sh$ ]]; then
  cd "${0%/*}"
fi

##############################################################################
## DEFINE SRC PATHS
##############################################################################

readonly SGLUE_REPO_D="$(pwd -P)"
readonly SGLUE_SRC_D="${SGLUE_REPO_D}/src"
readonly SGLUE_HELP_D="${SGLUE_SRC_D}/help"

##############################################################################
## CHECK SRC PATHS
##############################################################################

sglue_chk DIR "${SGLUE_REPO_D}" "${SGLUE_SRC_D}" "${SGLUE_HELP_D}"

##############################################################################
## PARSE OPTIONS
##############################################################################

SGLUE_BIN='/bin'
SGLUE_LIB='/usr/lib'
SGLUE_SHARE='/usr/share'

SGLUE_ACTION='mk'
SGLUE_TITLE='INSTALL'

declare -i SGLUE_HEADER=0
declare -i SGLUE_QUIET=0
declare -i SGLUE_FORCE=0

while [[ ${#} -gt 0 ]]; do
  case "${1}" in
    -\?|-h|--help)
      ${sed} -e '/^[[:blank:]]*#/ d' -- "${SGLUE_REPO_D}/.install.help"
      exit 0
      ;;
    -b|--bin)
      if [[ ${#} -eq 1 ]] || [[ "${2}" =~ ^- ]]; then
        sglue_err VAL "missing bin DIR"
      fi
      if [[ ! "${2}" =~ ^/ ]]  || [[ ! -d "${2}" ]]; then
        sglue_err VAL "invalid bin DIR \`${2}'"
      fi
      SGLUE_BIN="${2}"
      ;;
    --bin=*)
      if [[ ! "${1#*=}" =~ ^/ ]]  || [[ ! -d "${1#*=}" ]]; then
        sglue_err VAL "invalid bin DIR \`${1#*=}'"
      fi
      SGLUE_BIN="${1#*=}"
      ;;
    -f|--force)
      SGLUE_FORCE=1
      ;;
    -l|--lib)
      if [[ ${#} -eq 1 ]] || [[ "${2}" =~ ^- ]]; then
        sglue_err VAL "missing lib DIR"
      fi
      if [[ ! "${2}" =~ ^/ ]]  || [[ ! -d "${2}" ]]; then
        sglue_err VAL "invalid lib DIR \`${2}'"
      fi
      SGLUE_LIB="${2}"
      ;;
    --lib=*)
      if [[ ! "${1#*=}" =~ ^/ ]]  || [[ ! -d "${1#*=}" ]]; then
        sglue_err VAL "invalid lib DIR \`${1#*=}'"
      fi
      SGLUE_LIB="${1#*=}"
      ;;
    -q|--quiet)
      SGLUE_QUIET=1
      ;;
    -s|--share)
      if [[ ${#} -eq 1 ]] || [[ "${2}" =~ ^- ]]; then
        sglue_err VAL "missing share DIR"
      fi
      if [[ ! "${2}" =~ ^/ ]]  || [[ ! -d "${2}" ]]; then
        sglue_err VAL "invalid share DIR \`${2}'"
      fi
      SGLUE_SHARE="${2}"
      ;;
    --share=*)
      if [[ ! "${1#*=}" =~ ^/ ]]  || [[ ! -d "${1#*=}" ]]; then
        sglue_err VAL "invalid share DIR \`${1#*=}'"
      fi
      SGLUE_SHARE="${1#*=}"
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

##############################################################################
## PRINT HEADER
##############################################################################

sglue_header

##############################################################################
## DEFINE DEST DIRS
##############################################################################

readonly SGLUE_LIB_DEST="${SGLUE_LIB}/superglue"
readonly SGLUE_HELP_DEST="${SGLUE_SHARE}/superglue/help"

##############################################################################
## DEFINE MAKE METHODS
##############################################################################

############################################################
# @func sglue_mk
# @use sglue_mk SRC
# @val SRC  Can be any type file path.
# @return
#   0  PASS
############################################################
sglue_mk()
{
  local src="${1%/}"
  local mode
  local path

  if [[ -z "${src}" ]] || [[ ! -a "${src}" ]] || [[ -h "${src}" ]]; then
    return 0
  fi

  if [[ -d "${src}" ]]; then
    while IFS= read -r path; do
      sglue_mk "${src}/${path##*/}"
    done <<< "$(${ls} -b -1 -- "${src}")"
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

  if [[ -z "${mode}" ]]; then
    mode='0644'
  fi

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
  elif sglue_has_sgl "${src}" && ! sglue_has_sgl "${dest}"; then
    if [[ ! -f "${dest}.bak" ]]; then
      ${mv} -T -- "${dest}" "${dest}.bak"
      sglue_chk_exit ${?} ${mv} -T -- "${dest}" "${dest}.bak"
    fi
  fi

  ${cp} -T -- "${src}" "${dest}"
  sglue_chk_exit ${?} ${cp} -T -- "${src}" "${dest}"

  sglue_mk_incl "${src}" "${dest}"

  ${chown} -- 'root:root' "${dest}"
  sglue_chk_exit ${?} ${chown} -- 'root:root' "${dest}"

  ${chmod} -- "${mode}" "${dest}"
  sglue_chk_exit ${?} ${chmod} -- "${mode}" "${dest}"
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

  if ! sglue_has_incl "${dest}"; then
    return 0
  fi

  while IFS= read -r line; do
    path="$(sglue_untag "${line}")"
    if [[ "${path:0:1}" != '/' ]]; then
      path="${src%/*}/${path}"
    fi
    if [[ ! -f "${path}" ]]; then
      sglue_err VAL "invalid INCL path \`${path}' in SRC \`${src}'"
    fi
    line="$(printf '%s' "${line}" | ${sed} -e 's/[]\/$*.^|[]/\\&/g')"
    content=''
    while IFS= read -r subline; do
      content="${content}${subline}\\n"
    done <<< "$(${sed} -e '1,4 d' -e 's/[\/&]/\\&/g' -- "${path}")"
    ${sed} -i -e "s/${line}/${content}/" -- "${dest}"
  done <<< "$(${grep} -e "${SGLUE_TAG_INCL}" -- "${dest}")"
}

##############################################################################
## DEFINE REMOVE METHODS
##############################################################################

############################################################
# @func sglue_rm
# @use sglue_rm SRC
# @val SRC  Can be any type file path.
# @return
#   0  PASS
############################################################
sglue_rm()
{
  local src="${1%/}"
  local path

  if [[ -z "${src}" ]] || [[ ! -a "${src}" ]] || [[ -h "${src}" ]]; then
    return 0
  fi

  if [[ -d "${src}" ]]; then
    while IFS= read -r path; do
      sglue_rm "${src}/${path##*/}"
    done <<< "$(${ls} -b -1 -- "${src}")"
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

  if sglue_has_sgl "${src}"; then
    if [[ -f "${dest}" ]]; then
      if sglue_has_sgl "${dest}"; then
        ${rm} -- "${dest}"
        sglue_chk_exit ${?} ${rm} -- "${dest}"
        if [[ -f "${dest}.bak" ]]; then
          ${mv} -T -- "${dest}.bak" "${dest}"
          sglue_chk_exit ${?} ${mv} -T -- "${dest}.bak" "${dest}"
        fi
      fi
    elif [[ -f "${dest}.bak" ]]; then
      ${mv} -T -- "${dest}.bak" "${dest}"
      sglue_chk_exit ${?} ${mv} -T -- "${dest}.bak" "${dest}"
    fi
  elif [[ -f "${dest}" ]]; then
    ${rm} -- "${dest}"
    sglue_chk_exit ${?} ${rm} -- "${dest}"
  fi
}

##############################################################################
## RUN INSTALL
##############################################################################

if [[ "${SGLUE_ACTION}" == 'mk' ]]; then

  sglue_step directories
  if [[ ! -d "${SGLUE_LIB_DEST}" ]]; then
    ${mkdir} -m 0755 -p -- "${SGLUE_LIB_DEST}"
  fi
  if [[ ! -d "${SGLUE_HELP_DEST}" ]]; then
    ${mkdir} -m 0755 -p -- "${SGLUE_HELP_DEST}"
  fi

  sglue_mk "${SGLUE_SRC_D}"

  sglue_step help files
  ${rm} -r -f -- "${SGLUE_HELP_DEST}"
  ${cp} -r -t "${SGLUE_HELP_DEST%/*}" -- "${SGLUE_HELP_D}"

elif [[ "${SGLUE_ACTION}" == 'rm' ]]; then

  sglue_rm "${SGLUE_SRC_D}"

  sglue_step help files
  if [[ -d "${SGLUE_HELP_DEST}" ]]; then
    ${rm} -r -f -- "${SGLUE_HELP_DEST}"
  fi

  sglue_step directories
  if [[ -d "${SGLUE_LIB_DEST}" ]]; then
    ${rm} -r -f -- "${SGLUE_LIB_DEST}"
  fi
  if [[ -d "${SGLUE_HELP_DEST%/*}" ]]; then
    ${rm} -r -f -- "${SGLUE_HELP_DEST%/*}"
  fi

fi

##############################################################################
## END INSTALL
##############################################################################

sglue_result
sglue_footer
exit 0
