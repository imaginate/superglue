#!/bin/sh
#
# Install `superglue' scripts.
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use ./install.sh --help
# @use ./install.sh [--force] [...SCRIPT]
# @opt -?|-h|--help  Print help info and exit.
# @opt -f|--force    Overwrite existing SCRIPT destinations.
# @val SCRIPT  Must be the name or path of a file located in the `./src' tree.
# @exit
#   0  success
#   1  user error
#   2  dependency error
#   3  internal error
#   4  script error
################################################################################

################################################################################
## CLEAN COMMANDS
################################################################################

unset -f cd
unset -f command
unset -f echo
unset -f printf
unset -f pwd
unset -f unalias

unalias cd
unalias command
unalias echo
unalias printf
unalias pwd
unalias readonly

################################################################################
## DEFINE HELPERS
################################################################################

readonly SGLUE_RED="$(printf '\033[0;31m')"
readonly SGLUE_NC="$(printf '\033[0;0m')"

############################################################
# @func
# @use sglue_err CODE MSG
# @val CODE  Must be one of the below options.
#   `usr'
#   `dep'
#   `int'
#   `scr'
# @val MSG   Can be any valid string.
# @exit
#   1  user error
#   2  dependency error
#   3  internal error
#   4  script error
############################################################
sglue_err()
{
  case "$1" in
    usr)
      echo "${SGLUE_RED}ERROR${SGLUE_NC} $2" 1>&2
      exit 1
      ;;
    dep)
      echo "${SGLUE_RED}DEPENDENCY ERROR${SGLUE_NC} $2" 1>&2
      exit 2
      ;;
    int)
      echo "${SGLUE_RED}INTERNAL ERROR${SGLUE_NC} $2" 1>&2
      exit 3
      ;;
    scr)
      echo "${SGLUE_RED}SCRIPT ERROR${SGLUE_NC} $2" 1>&2
      exit 4
      ;;
    *)
      echo "${SGLUE_RED}SCRIPT ERROR${SGLUE_NC} invalid \`sglue_err' CODE \`$1'" 1>&2
      exit 4
      ;;
  esac
}

############################################################
# @func
# @use sglue_chk TYPE PATH
# @val PATH  Must be a valid file path.
# @val TYPE  Must be one of the below options.
#   `cmd'
#   `dir'
#   `file'
# @note If the check fails this function does exit with `2'.
############################################################
sglue_chk()
{
  [ -n "$2" ] || sglue_err scr "missing \`sglue_chk' PATH"

  case "$1" in
    cmd)
      [ -x "$2" ] || sglue_err dep "invalid executable path \`$2'"
      ;;
    dir)
      [ -d "$2" ] || sglue_err dep "invalid directory path \`$2'"
      ;;
    file)
      [ -f "$2" ] || sglue_err dep "invalid file path \`$2'"
      ;;
    *)
      sglue_err scr "invalid \`sglue_chk' CODE \`$1'"
      ;;
  esac
}

############################################################
# @func
# @use sglue_help
############################################################
sglue_help()
{
  /bin/cat <<'EOF'

  ./install.sh --help
  ./install.sh [--force] [...SCRIPT]

  Options:
    -?|-h|--help  Print help info and exit.
    -f|--force    Overwrite existing SCRIPT destinations.

  Values:
    SCRIPT  Must be the name or path of a file located in the `./src' tree.

  Exit Codes:
    0  success
    1  user error
    2  dependency error
    3  internal error
    4  script error

EOF
}

################################################################################
## CHECK COMMAND PATHS
################################################################################

sglue_chk cmd /bin/cat
sglue_chk cmd /bin/chmod
sglue_chk cmd /bin/chown
sglue_chk cmd /bin/cp
sglue_chk cmd /bin/grep
sglue_chk cmd /usr/bin/id
sglue_chk cmd /bin/sed

################################################################################
## CHECK PERMISSIONS
################################################################################

[ $(/usr/bin/id --user) -eq 0 ] || sglue_err usr 'invalid user permissions'

################################################################################
## CHECK $0 VALUE
################################################################################

echo -n "$0" | /bin/grep 'install\.sh$' > /dev/null
RT=$?
[ $RT -eq 1 ] && sglue_err int "invalid shell script param \$0 \`$0'"
[ $RT -ne 0 ] && sglue_err int "\$0 \`/bin/grep' exited with \`$RT'"

################################################################################
## CHANGE DIRECTORY
################################################################################

if [ "$0" != './install.sh' ] && [ "$0" != 'install.sh' ]; then

  RS="$(echo -n "$0" | /bin/sed -e 's|/install\.sh$||')"
  RT=$?
  [ $RT -eq 0 ] || sglue_err int "\$0 \`/bin/sed' exited with \`$RT'"
  [ -n "$RS"  ] || sglue_err int "\$0 \`/bin/sed' printed empty result"
  [ -d "$RS"  ] || sglue_err int "\$0 \`/bin/sed' printed invalid path \`$RS'"

  cd "$RS"
  RT=$?
  [ $RT -eq 0 ] || sglue_err int "\`cd $RS' exited with \`$RT'"
fi

################################################################################
## SET SRC PATH
################################################################################

readonly SGLUE_SRC_D="$(pwd -P)/src"

sglue_chk dir "${SGLUE_SRC_D}"

################################################################################
## PARSE OPTIONS
################################################################################

SGLUE_FORCE=0

while [ $# -gt 0 ]; do
  case "$1" in
    -?|-h|--help)
      sglue help
      exit 0
      ;;
    -f|--force)
      SGLUE_FORCE=1
      shift
      ;;
    *)
      echo -n "$1" | /bin/grep '^-' > /dev/null
      RT=$?
      [ $RT -eq 0 ] && sglue_err usr "invalid OPTION \`$1'"
      [ $RT -ne 1 ] && sglue_err int "\`$1' \`/bin/grep' exited with \`$RT'"
      break
      ;;
  esac
done

################################################################################
## DEFINE METHODS
################################################################################

SGLUE_SRC=''
SGLUE_DEST=''

############################################################
# @func
# @use sglue_set_src SCRIPT
############################################################
sglue_set_src()
{
  [ -n "$1" ] || sglue_err scr "empty \`sglue_set_src' SCRIPT"

  RS="$(echo -n "$1" | /bin/sed -e 's|^.*/||' -e 's|\.sh$||')"
  RT=$?
  [ $RT -eq 0 ] || sglue_err int "SCRIPT \`/bin/sed' exited with \`$RT'"
  [ -n "$RS"  ] || sglue_err usr "invalid SCRIPT \`$1'"

  echo -n "$RS" | /bin/grep '^[:alpha:]\+$' > /dev/null
  RT=$?
  [ $RT -eq 1 ] && sglue_err usr "invalid SCRIPT \`$1'"
  [ $RT -ne 0 ] && sglue_err int "SCRIPT \`/bin/grep' exited with \`$RT'"

  RS="${SGLUE_SRC_D}/${RS}.sh"
  [ -f "$RS" ] || sglue_err usr "invalid SCRIPT \`$1' path \`$RS'"

  SGLUE_SRC="$RS"
}

############################################################
# @func
# @use sglue_set_dest SRC
############################################################
sglue_set_dest()
{
  [ -n "$1" ] || sglue_err scr "empty \`sglue_set_dest' SRC"
  [ -f "$1" ] || sglue_err scr "invalid \`sglue_set_dest' SRC path \`$1'"

  RS="$(/bin/grep --max-count=1 -F '@dest' "$1")"
  RT=$?
  [ $RT -eq 1 ] && sglue_err dep "missing \`@dest DEST' in SRC \`$1'"
  [ $RT -ne 0 ] && sglue_err int "\`@dest' \`/bin/grep' exited with \`$RT'"

  RS="$(echo -n "$RS" | /bin/sed -e 's|^[^/]\+||' -e 's|[:blank:]\+$||')"
  RT=$?
  [ $RT -eq 0 ] || sglue_err int "DEST \`/bin/sed' exited with \`$RT'"
  [ -n "$RS"  ] || sglue_err usr "invalid \`@dest DEST' in SRC \`$1'"

  echo -n "$RS" | /bin/grep '^\(/.\+\)\?/bin/[:alpha:]\+$' > /dev/null
  RT=$?
  [ $RT -eq 1 ] && sglue_err usr "invalid \`@dest $RS' in SRC \`$1'"
  [ $RT -ne 0 ] && sglue_err int "DEST \`/bin/grep' exited with \`$RT'"

  SGLUE_DEST="$RS"
}

############################################################
# @func
# @use sglue_mk_cmd SCRIPT
############################################################
sglue_mk_cmd()
{
  [ -n "$1" ] || sglue_err usr 'empty SCRIPT'

  sglue_set_src "$1"
  sglue_set_dest "${SGLUE_SRC}"

  if [ ${SGLUE_FORCE} -ne 1 ] && [ -f "${SGLUE_DEST}" ]; then
    sglue_err usr "\`${SGLUE_DEST}' already exists (use \`--force' to overwrite)"
  fi

  /bin/cp "${SGLUE_SRC}" "${SGLUE_DEST}"
  /bin/chown root:root "${SGLUE_DEST}"
  /bin/chmod 0755 "${SGLUE_DEST}"
}

############################################################
# @func
# @use sglue_mk_cmds ...SCRIPT
############################################################
sglue_mk_cmds()
{
  [ $# -gt 0 ] || sglue_err scr "missing \`sglue_mk_cmds' SCRIPT"

  while [ $# -gt 0 ]; do
    sglue_mk_cmd "$1"
    shift
  done
}

################################################################################
## MAKE COMMANDS
################################################################################

if [ $# -gt 0 ]; then
  sglue_mk_cmds "$@"
else
  sglue_mk_cmds ./src/*
fi

################################################################################
## EXIT
################################################################################

exit 0
