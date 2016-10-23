#!/bin/bash --posix
#
# Install `superglue' scripts `./src/**/*.sh'.
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use ./install.sh [OPTION]
# @opt -f|--force  If destination exists overwrite it.
# @opt -h|--help   Print help info and exit.
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

################################################################################
## DEFINE HELPERS
################################################################################

############################################################
# @func
# @use sglue_err ERR MSG
# @val ERR  Must be one of the below errors.
#   `MISC'  An unknown error (exit= `1').
#   `OPT'   An invalid option (exit= `2').
#   `VAL'   An invalid or missing value (exit= `3').
#   `AUTH'  A permissions error (exit= `4').
#   `DPND'  A dependency error (exit= `5').
#   `CHLD'  A child process exited unsuccessfully (exit= `6').
#   `SGL'   A `superglue' script error (exit= `7').
# @val MSG  Can be any valid string.
# @exit
#   1  MISC  An unknown error.
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
    MISC)
      title='ERR'
      code=1
      ;;
    OPT)
      title='OPT_ERR'
      code=2
      ;;
    VAL)
      title='VAL_ERR'
      code=3
      ;;
    AUTH)
      title='AUTH_ERR'
      code=4
      ;;
    DPND)
      title='DPND_ERR'
      code=5
      ;;
    CHLD)
      title='CHLD_ERR'
      code=6
      ;;
    SGL)
      title='SGL_ERR'
      code=7
      ;;
    *)
      sglue_err SGL "invalid \`${FN}' ERR \`$1'"
      ;;
  esac
  printf "%s\n" "${title} $2" 1>&2
  exit ${code}
}
readonly -f sglue_err

############################################################
# @func
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
# @func
# @use sglue_chk TYPE PATH
# @val PATH  Must be a valid file path.
# @val TYPE  Must be one of the below options.
#   `CMD'
#   `DIR'
#   `FILE'
# @note If the check fails this function does exit.
# @return
#   0  PASS
############################################################
sglue_chk()
{
  local -r FN='sglue_chk'

  [[ -n "$2" ]] || sglue_err SGL "missing \`${FN}' PATH"

  case "$1" in
    CMD)
      [[ -x "$2" ]] || sglue_err DPND "invalid executable path \`$2'"
      ;;
    DIR)
      [[ -d "$2" ]] || sglue_err DPND "invalid directory path \`$2'"
      ;;
    FILE)
      [[ -f "$2" ]] || sglue_err DPND "invalid file path \`$2'"
      ;;
    *)
      sglue_err SGL "invalid \`${FN}' TYPE \`$1'"
      ;;
  esac
}
readonly -f sglue_chk

############################################################
# @func
# @use sglue_help
# @return
#   0  PASS
############################################################
sglue_help()
{
  ${cat} <<'EOF'

  ./install.sh [OPTION]

  Options:
    -f|--force  If destination exists overwrite it.
    -h|--help   Print help info and exit.

  Exit Codes:
    0  PASS  A successful exit.
    1  MISC  An unknown error.
    2  OPT   An invalid option.
    3  VAL   An invalid or missing value.
    4  AUTH  A permissions error.
    5  DPND  A dependency error.
    6  CHLD  A child process exited unsuccessfully.
    7  SGL   A `superglue' script error.

EOF
}
readonly -f sglue_help

################################################################################
## CHECK PERMISSIONS
################################################################################

[[ ${EUID} -eq 0 ]] || sglue_err AUTH 'invalid user permissions'

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

sglue_chk CMD ${cat}
sglue_chk CMD ${chmod}
sglue_chk CMD ${chown}
sglue_chk CMD ${cp}
sglue_chk CMD ${grep}
sglue_chk CMD ${mkdir}
sglue_chk CMD ${rm}
sglue_chk CMD ${sed}

################################################################################
## CHECK $0 VALUE
################################################################################

printf '%s' "$0" | ${grep} 'install\.sh$' > /dev/null
RT=$?
[[ $RT -eq 1 ]] && sglue_err CHLD "invalid shell script param \$0 \`$0'"
[[ $RT -ne 0 ]] && sglue_err CHLD "\$0 \`${grep}' exited with \`$RT'"

################################################################################
## CHANGE DIRECTORY
################################################################################

if [[ ! "$0" =~ ^(\./)?install\.sh$ ]]; then
  RS="$(printf '%s' "$0" | ${sed} -e 's|/install\.sh$||')"
  RT=$?
  [[ $RT -eq 0 ]] || sglue_err CHLD "\$0 \`${sed}' exited with \`$RT'"
  [[ -n "$RS"  ]] || sglue_err CHLD "\$0 \`${sed}' printed empty result"
  [[ -d "$RS"  ]] || sglue_err CHLD "\$0 \`${sed}' printed invalid path \`$RS'"
  cd "$RS"
fi

################################################################################
## SET SRC PATHS
################################################################################

readonly SGLUE_SRC_D="$(pwd -P)/src"
readonly SGLUE_CMD_D="${SGLUE_SRC_D}/bin"
readonly SGLUE_LIB_D="${SGLUE_SRC_D}/lib"
readonly SGLUE_HELP_D="${SGLUE_SRC_D}/help"

################################################################################
## CHECK SRC PATHS
################################################################################

sglue_chk DIR "${SGLUE_SRC_D}"
sglue_chk DIR "${SGLUE_CMD_D}"
sglue_chk DIR "${SGLUE_LIB_D}"
sglue_chk DIR "${SGLUE_HELP_D}"

################################################################################
## SET DEST PATHS
################################################################################

readonly SGLUE_LIB_DEST='/lib/superglue'
readonly SGLUE_HELP_DEST='/usr/share/superglue/help'

################################################################################
## MAKE DEST PATHS
################################################################################

[[ -d ${SGLUE_LIB_DEST}  ]] || ${mkdir} -m 0755 -p ${SGLUE_LIB_DEST}
[[ -d ${SGLUE_HELP_DEST} ]] || ${mkdir} -m 0755 -p ${SGLUE_HELP_DEST}

################################################################################
## CLEAN DEST PATHS
################################################################################

${rm} -rf ${SGLUE_LIB_DEST}/*
${rm} -rf ${SGLUE_HELP_DEST}/*

################################################################################
## PARSE OPTIONS
################################################################################

SGLUE_FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--force)
      SGLUE_FORCE=1
      shift
      ;;
    -h|--help)
      sglue_help
      exit 0
      ;;
    *)
      sglue_err OPT "invalid OPTION \`$1'"
      ;;
  esac
done

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
## INSTALL SUPERGLUE
################################################################################

for SGLUE_SRC in "${SGLUE_CMD_D}"/*.sh ; do
  sglue_mk_cmd "${SGLUE_SRC}"
done

for SGLUE_SRC in "${SGLUE_LIB_D}"/sgl_*.sh ; do
  sglue_mk_lib "${SGLUE_SRC}"
done

for SGLUE_SRC in "${SGLUE_HELP_D}"/* ; do
  sglue_mk_help "${SGLUE_SRC}"
done

################################################################################
## EXIT
################################################################################

exit 0
