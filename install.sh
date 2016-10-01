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
## CLEAN ENV
################################################################################

############################################################
# @func
# @use sglue_unalias ...CMD
############################################################
sglue_unalias()
{
  while [ $# -gt 0 ]; do
    unalias "$1" 2> /dev/null || :
    shift
  done
  return 0
}

############################################################
# @func
# @use sglue_unset ...CMD
############################################################
sglue_unset()
{
  while [ $# -gt 0 ]; do
    unset -f "$1" 2> /dev/null || :
    shift
  done
  return 0
}

sglue_unset   cd command declare echo history printf pwd set unalias  return export umask
sglue_unalias cd command declare echo history printf pwd set readonly return export umask

################################################################################
## DEFINE HELPERS
################################################################################

readonly SGLUE_RED="`printf '%b' '\033[0;31m'`"
readonly SGLUE_UNCOLOR="`printf '%b' '\033[0;0m'`"

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
      SGLUE_TITLE='ERROR'
      SGLUE_MSG="$2"
      SGLUE_CODE=1
      ;;
    dep)
      SGLUE_TITLE='DEPENDENCY ERROR'
      SGLUE_MSG="$2"
      SGLUE_CODE=2
      ;;
    int)
      SGLUE_TITLE='INTERNAL ERROR'
      SGLUE_MSG="$2"
      SGLUE_CODE=3
      ;;
    scr)
      SGLUE_TITLE='SCRIPT ERROR'
      SGLUE_MSG="$2"
      SGLUE_CODE=4
      ;;
    *)
      SGLUE_TITLE='SCRIPT ERROR'
      SGLUE_MSG="invalid \`sglue_err' CODE \`$1'"
      SGLUE_CODE=4
      ;;
  esac
  printf "%s\n" "$SGLUE_RED$SGLUE_TITLE$SGLUE_UNCOLOR $SGLUE_MSG" 1>&2
  exit $SGLUE_CODE
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

[ `/usr/bin/id --user` -eq 0 ] || sglue_err usr 'invalid user permissions'

################################################################################
## CHECK $0 VALUE
################################################################################

printf '%s' "$0" | /bin/grep 'install\.sh$' > /dev/null
RT=$?
[ $RT -eq 1 ] && sglue_err int "invalid shell script param \$0 \`$0'"
[ $RT -ne 0 ] && sglue_err int "\$0 \`/bin/grep' exited with \`$RT'"

################################################################################
## CHANGE DIRECTORY
################################################################################

if [ "$0" != './install.sh' ] && [ "$0" != 'install.sh' ]; then

  RS="`printf '%s' "$0" | /bin/sed -e 's/\/install\.sh$//'`"
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

readonly SGLUE_SRC_D="`pwd -P`/src"

sglue_chk dir "$SGLUE_SRC_D"

################################################################################
## PARSE OPTIONS
################################################################################

SGLUE_FORCE=0

while [ $# -gt 0 ]; do
  case "$1" in
    -?|-h|--help)
      sglue_help
      exit 0
      ;;
    -f|--force)
      SGLUE_FORCE=1
      shift
      ;;
    *)
      printf '%s' "$1" | /bin/grep '^-' > /dev/null
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

  # same as `RS=$(basename "$1" .sh)'
  RS="`printf '%s' "$1" | /bin/sed -e 's/^.*\///' -e 's/\.sh$//'`"
  RT=$?
  [ $RT -eq 0 ] || sglue_err int "SCRIPT \`/bin/sed' exited with \`$RT'"
  [ -n "$RS"  ] || sglue_err usr "invalid SCRIPT \`$1'"

  # verify SCRIPT chars
  printf '%s' "$RS" | /bin/grep '^[[:alpha:]]\+$' > /dev/null
  RT=$?
  [ $RT -eq 1 ] && sglue_err usr "invalid SCRIPT \`$1'"
  [ $RT -ne 0 ] && sglue_err int "SCRIPT \`/bin/grep' exited with \`$RT'"

  # verify SRC path
  RS="$SGLUE_SRC_D/$RS.sh"
  [ -f "$RS" ] || sglue_err usr "invalid SCRIPT \`$1' path \`$RS'"

  SGLUE_SRC="$RS"
}

############################################################
# @func
# @use sglue_mk_cmd SCRIPT
############################################################
sglue_mk_cmd()
{
  [ -n "$1" ] || sglue_err usr 'empty SCRIPT'

  sglue_set_src "$1"

  # check SRC for DEST
  /bin/grep '^#[[:blank:]]*@dest[[:blank:]]\+/' "$SGLUE_SRC" > /dev/null
  RT=$?
  [ $RT -eq 1 ] && sglue_err dep "missing \`@dest DEST' in SRC \`$1'"
  [ $RT -ne 0 ] && sglue_err int "\`@dest' \`/bin/grep' exited with \`$RT'"

  # process each DEST
  while IFS= read -r RS; do

    # get DEST from LINE
    RS="`printf '%s' "$RS" | /bin/sed -e 's/^[^\/]\+//' -e 's/[[:blank:]]\+$//'`"
    RT=$?
    [ $RT -eq 0 ] || sglue_err int "DEST \`/bin/sed' exited with \`$RT'"

    # verify `*/bin/' in DEST path
    printf '%s' "$RS" | /bin/grep '^\(/.\+\)\?/bin/[[:alpha:]]\+$' > /dev/null
    RT=$?
    [ $RT -eq 1 ] && sglue_err usr "invalid \`@dest $RS' in SRC \`$SGLUE_SRC'"
    [ $RT -ne 0 ] && sglue_err int "DEST \`/bin/grep' exited with \`$RT'"

    # verify `dirname DEST' exists
    RD="`printf '%s' "$RS" | /bin/sed -e 's/^.\+\///'`"
    RT=$?
    [ $RT -eq 0 ] || sglue_err int "DEST \`/bin/sed' exited with \`$RT'"
    [ -d "$RD"  ] || sglue_err usr "invalid DEST dir \`$RD' in SRC \`$SGLUE_SRC'"

    # verify DEST overwrite
    if [ $SGLUE_FORCE -ne 1 ] && [ -f "$RS" ]; then
      sglue_err usr "\`$RS' already exists (use \`--force' to overwrite)"
    fi

    SGLUE_DEST="$RS"

    # make DEST
    /bin/cp "$SGLUE_SRC" "$SGLUE_DEST"
    /bin/chown root:root "$SGLUE_DEST"
    /bin/chmod 0755 "$SGLUE_DEST"

  done < <<EOF
`/bin/grep '^#[[:blank:]]*@dest[[:blank:]]\+/' "$SGLUE_SRC"`
EOF
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
