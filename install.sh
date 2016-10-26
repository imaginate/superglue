#!/bin/bash --posix
#
# Install `superglue' scripts `./src/**/*'.
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use ./install.sh [OPTION]
# @opt -c|--clean  Remove `superglue' files and directories.
# @opt -f|--force  If destination exists overwrite it.
# @opt -h|--help   Print help info and exit.
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

readonly SGLUE_ROW_LEN=26

################################################################################
## SECTIONS
## - CLEAN BUILTINS
## - DEFINE COLORS
## - CHECK BASH VERSION
## - DEFINE HELPERS
## - CHECK $0 VALUE
## - CHECK PERMISSIONS
## - DEFINE COMMANDS
## - CHECK COMMANDS
## - CHANGE DIRECTORY
## - DEFINE SRC PATHS
## - CHECK SRC PATHS
## - DEFINE DEST PATHS
## - PARSE OPTIONS
## - PRINT HEADER
## - MAKE DEST PATHS
## - DEFINE METHODS
## - INSTALL COMMANDS
## - INSTALL FUNCTIONS
## - INSTALL HELP FILES
## - END INSTALL
################################################################################

SGLUE_TITLE='INSTALL'
SGLUE_HEADER=0

[[ "${NIL}" == '/dev/null' ]] || NIL='/dev/null'
if readonly NIL 2> /dev/null; then : ; else : ; fi

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
  if unset -f $1 2> ${NIL}; then
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

################################################################################
## CHECK BASH VERSION
################################################################################

if [[ -z "${BASH_VERSINFO}" ]] || [[ ${BASH_VERSINFO[0]} -ne 4 ]]; then
  printf "%s %s\n" "${SGLUE_RED}DEPENDENCY ERROR${SGLUE_UNCOLOR}" \
    'bash version 4 required' 1>&2
  exit 5
fi

################################################################################
## DEFINE HELPERS
################################################################################

############################################################
# Prints an error message and exits the process.
#
# @func sglue_err
# @use sglue_err ERR MSG
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
  local -r FN='sglue_err'
  local title
  local -i code

  case "$1" in
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
      sglue_err SGL "invalid \`${FN}' ERR \`$1'"
      ;;
  esac
  printf "%s %s\n" "${SGLUE_RED}${title}${SGLUE_UNCOLOR}" "$2" 1>&2
  [[ ${SGLUE_HEADER} -eq 1 ]] && sglue_footer
  exit ${code}
}
readonly -f sglue_err

############################################################
# Prints a success message.
#
# @func sglue_pass
# @use sglue_pass MSG
# @val MSG  Can be any valid string.
# @return
#   0  PASS
############################################################
sglue_pass()
{
  printf "%s %s\n" "${SGLUE_GREEN}PASS${SGLUE_UNCOLOR}" "$1"
}
readonly -f sglue_pass

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
  local cmd="$1"

  if [[ -x "/bin/$1" ]]; then
    cmd="/bin/$1"
  elif [[ -x "/usr/bin/$1" ]]; then
    cmd="/usr/bin/$1"
  elif [[ -x "/usr/local/bin/$1" ]]; then
    cmd="/usr/local/bin/$1"
  fi
  printf '%s' "${cmd}"
}
readonly -f sglue_which

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
  local -r TYPE="$1"
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
readonly -f sglue_chk

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
  printf "%s\n" "${dashes}"
}
readonly -f sglue_dashes

############################################################
# Prints this scripts header.
#
# @func sglue_header
# @use sglue_header
# @return
#   0  PASS
############################################################
sglue_header()
{
  local title="-- START SGL ${SGLUE_TITLE} --"
  local -i i=0
  local -i len=$(( ${SGLUE_ROW_LEN} - ${#title} ))

  for ((i=0; i<len; i++)); do
    title="${title}-"
  done

  sglue_dashes
  printf "%s\n" "${title}"
  sglue_dashes

  SGLUE_HEADER=1
}
readonly -f sglue_header

############################################################
# Prints this scripts footer.
#
# @func sglue_footer
# @use sglue_footer
# @return
#   0  PASS
############################################################
sglue_footer()
{
  local title="-- END SGL ${SGLUE_TITLE} --"
  local -i i=0
  local -i len=$(( ${SGLUE_ROW_LEN} - ${#title} ))

  for ((i=0; i<len; i++)); do
    title="${title}-"
  done

  sglue_dashes
  printf "%s\n" "${title}"
  sglue_dashes
}
readonly -f sglue_footer

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

[[ "$0" =~ ^(\./)?install\.sh$ ]] || cd "${0%%/install.sh}"

################################################################################
## DEFINE SRC PATHS
################################################################################

readonly SGLUE_REPO_D="$(pwd -P)"
readonly SGLUE_SRC_D="${SGLUE_REPO_D}/src"
readonly SGLUE_CMD_D="${SGLUE_SRC_D}/bin"
readonly SGLUE_LIB_D="${SGLUE_SRC_D}/lib"
readonly SGLUE_HELP_D="${SGLUE_SRC_D}/help"

################################################################################
## CHECK SRC PATHS
################################################################################

sglue_chk DIR "${SGLUE_REPO_D}" "${SGLUE_SRC_D}" "${SGLUE_CMD_D}" \
  "${SGLUE_LIB_D}" "${SGLUE_HELP_D}"

################################################################################
## DEFINE DEST PATHS
################################################################################

readonly SGLUE_LIB_DEST='/lib/superglue'
readonly SGLUE_HELP_DEST='/usr/share/superglue/help'

################################################################################
## PARSE OPTIONS
################################################################################

SGLUE_FORCE=0

if [[ $# -gt 1 ]]; then
  sglue_header
  sglue_err OPT "only 1 OPTION allowed"
fi

if [[ $# -gt 0 ]]; then
  case "$1" in
    -c|--clean)
      SGLUE_TITLE='UNINSTALL'
      sglue_header
      # remove commands
      for SGLUE_CMD in sgl sglue superglue; do
        SGLUE_CMD="/bin/${SGLUE_CMD}"
        [[ -x "${SGLUE_CMD}" ]] && ${rm} -f "${SGLUE_CMD}"
      done
      sglue_pass 'commands uninstalled'
      # remove funcs
      [[ -d "${SGLUE_LIB_DEST}" ]] && ${rm} -rf "${SGLUE_LIB_DEST}"
      sglue_pass 'functions uninstalled'
      # remove help files
      [[ -d "${SGLUE_HELP_DEST}" ]] && ${rm} -rf "${SGLUE_HELP_DEST}"
      sglue_pass 'help files uninstalled'
      # end uninstall
      sglue_footer
      exit 0
      ;;
    -f|--force)
      SGLUE_FORCE=1
      ;;
    -h|--help)
      ${cat} "${SGLUE_REPO_D}/install.help"
      exit 0
      ;;
    *)
      sglue_err OPT "invalid OPTION \`$1'"
      ;;
  esac
fi

################################################################################
## PRINT HEADER
################################################################################

sglue_header

################################################################################
## MAKE DEST PATHS
################################################################################

[[ -d ${SGLUE_LIB_DEST}  ]] || ${mkdir} -m 0755 -p ${SGLUE_LIB_DEST}
[[ -d ${SGLUE_HELP_DEST} ]] || ${mkdir} -m 0755 -p ${SGLUE_HELP_DEST}

################################################################################
## DEFINE METHODS
################################################################################

############################################################
# @func sglue_add_incl
# @use sglue_add_incl SRC DEST
# @val SRC   Must be a valid file path.
# @val DEST  Must be a valid file path.
# @return
#   0  PASS
############################################################
sglue_add_incl()
{
  local -r src="$1"
  local -r dest="$2"
  local -r cwd="${src%/*}"
  local incl
  local line
  local content
  local subline
  local -r tag='^[[:blank:]]*#[[:blank:]]*@incl[[:blank:]]\+'
  local -r space='[[:blank:]]\+$'

  # check SRC for INCL
  ${grep} "${tag}" "${src}" > /dev/null
  RT=$?
  [[ $RT -eq 1 ]] && return 0
  [[ $RT -ne 0 ]] && sglue_err CHLD "\`@incl' \`${grep}' exited with \`$RT'"

  # process each INCL
  while IFS= read -r line; do
    incl="$(printf '%s' "${line}" | ${sed} -e "s/${tag}//" -e "s/${space}//")"
    [[ "${incl}" =~ ^/ ]] || incl="${cwd}/${incl}"
    [[ -f "${incl}" ]] || sglue_err VAL "invalid INCL \`${incl}' in SRC \`${src}'"
    line="$(printf '%s' "${line}" | ${sed} -e 's/[]\/$*.^|[]/\\&/g')"
    content=''
    while IFS= read -r subline; do
      content="${content}${subline}\\n"
    done <<EOF
$(${sed} -e '1,6 d' -e 's/[\/&]/\\&/g' "${incl}")
EOF
    ${sed} -i -e "s/${line}/${content}/" "${dest}"
  done <<EOF
$(/bin/grep "${tag}" "${src}")
EOF
}

############################################################
# @func sglue_mk_cmd
# @use sglue_mk_cmd SRC
# @val SRC  Must be a valid file path.
# @return
#   0  PASS
############################################################
sglue_mk_cmd()
{
  local -r src="$1"
  local dest
  local parent
  local -r tag='^[[:blank:]]*#[[:blank:]]*@dest[[:blank:]]\+'
  local -r space='[[:blank:]]\+$'

  # check SRC for DEST
  ${grep} "${tag}" "${src}" > /dev/null
  RT=$?
  [[ $RT -eq 1 ]] && sglue_err VAL "missing \`@dest DEST' in SRC \`$1'"
  [[ $RT -ne 0 ]] && sglue_err CHLD "\`@dest' \`${grep}' exited with \`$RT'"

  # process each DEST
  while IFS= read -r dest; do
    dest="$(printf '%s' "${dest}" | ${sed} -e "s/${tag}//" -e "s/${space}//")"
    if [[ ! "${dest}" =~ ^(/.+)?/bin/[a-z]+$ ]]; then
      sglue_err VAL "invalid DEST \`${dest}' in SRC \`${src}'"
    fi
    parent="$(printf '%s' "${dest}" | ${sed} -e 's|/[^/]\+$||')"
    if [[ ! -d "${parent}" ]]; then
      sglue_err VAL "invalid DEST \`${dest}' in SRC \`${src}'"
    fi
    if [[ -d "${dest}" ]]; then
      sglue_err VAL "a dir for DEST \`${dest}' already exists in SRC \`${src}'"
    fi
    if [[ -f "${dest}" ]] && [[ ${SGLUE_FORCE} -ne 1 ]]; then
      sglue_err VAL "DEST \`${dest}' already exists (use \`--force' to overwrite)"
    fi
    ${cp} "${src}" "${dest}"
    ${chown} root:root "${dest}"
    ${chmod} 0755 "${dest}"
    sglue_add_incl "${src}" "${dest}"
  done <<EOF
$(/bin/grep "${tag}" "${src}")
EOF
}

############################################################
# @func sglue_mk_lib
# @use sglue_mk_lib SRC
# @val SRC  Must be a valid file path.
# @return
#   0  PASS
############################################################
sglue_mk_lib()
{
  local -r src="$1"
  local dest
  local -r tag='^[[:blank:]]*#[[:blank:]]*@dest[[:blank:]]\+'
  local -r space='[[:blank:]]\+$'

  # check SRC for DEST
  ${grep} "${tag}" "${src}" > /dev/null
  RT=$?
  [[ $RT -eq 1 ]] && sglue_err VAL "missing \`@dest DEST' in SRC \`$1'"
  [[ $RT -ne 0 ]] && sglue_err CHLD "\`@dest' \`${grep}' exited with \`$RT'"

  # process each DEST
  while IFS= read -r dest; do
    dest="$(printf '%s' "${dest}" | ${sed} -e "s/${tag}//" -e "s/${space}//")"
    if [[ ! "${dest}" =~ ^/lib/superglue/[a-z_]+$ ]]; then
      sglue_err VAL "invalid DEST \`${dest}' in SRC \`${src}'"
    fi
    if [[ -d "${dest}" ]]; then
      sglue_err VAL "a dir for DEST \`${dest}' already exists in SRC \`${src}'"
    fi
    if [[ -f "${dest}" ]] && [[ ${SGLUE_FORCE} -ne 1 ]]; then
      sglue_err VAL "DEST \`${dest}' already exists (use \`--force' to overwrite)"
    fi
    ${cp} "${src}" "${dest}"
    ${chown} root:root "${dest}"
    ${chmod} 0644 "${dest}"
  done <<EOF
$(/bin/grep "${tag}" "${src}")
EOF
}

############################################################
# @func sglue_mk_help
# @use sglue_mk_help SRC
# @val SRC  Must be a valid file path.
# @return
#   0  PASS
############################################################
sglue_mk_help()
{
  local -r src="$1"
  local -r dest="${SGLUE_HELP_DEST}/${src##*/}"

  ${cp} "${src}" "${dest}"
  ${chown} root:root "${dest}"
  ${chmod} 0644 "${dest}"
}

################################################################################
## INSTALL COMMANDS
################################################################################

for SGLUE_SRC in "${SGLUE_CMD_D}"/*.sh ; do
  sglue_mk_cmd "${SGLUE_SRC}"
done

sglue_pass 'commands installed'

################################################################################
## INSTALL FUNCTIONS
################################################################################

${rm} -rf ${SGLUE_LIB_DEST}/*

for SGLUE_SRC in "${SGLUE_LIB_D}"/sgl_*.sh ; do
  sglue_mk_lib "${SGLUE_SRC}"
done

sglue_pass 'functions installed'

################################################################################
## INSTALL HELP FILES
################################################################################

${rm} -rf ${SGLUE_HELP_DEST}/*

for SGLUE_SRC in "${SGLUE_HELP_D}"/* ; do
  sglue_mk_help "${SGLUE_SRC}"
done

sglue_pass 'help files installed'

################################################################################
## END INSTALL
################################################################################

sglue_footer
exit 0
