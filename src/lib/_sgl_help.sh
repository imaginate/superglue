#!/bin/bash
#
# @dest /lib/superglue/_sgl_help
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use _sgl_source help
# @return
#   0  PASS
################################################################################

############################################################
# @func _sgl_help
# @use _sgl_help [FUNC]
# @val FUNC  Must be a valid `superglue' function. The `sgl_' prefix is optional.
# @exit
#   0  PASS
############################################################
_sgl_help()
{
  if [[ $# -eq 0 ]]; then
    ${cat} <<'EOF'

  sgl [...OPTION] FUNC [...FUNC_ARG]
  sgl [...OPTION] SCRIPT [...SCRIPT_ARG]

  Options:
    -a|--alias           Enable aliases without `sgl_' prefixes for each sourced FUNC.
    -C|--no-color        Disable ANSI output coloring for terminals.
    -c|--color           Enable ANSI output coloring for non-terminals.
    -D|--silent-child    Disable `stderr' and `stdout' outputs for child processes.
    -d|--quiet-child     Disable `stdout' output for child processes.
    -h|-?|--help[=FUNC]  Print help info and exit.
    -P|--silent-parent   Disable `stderr' and `stdout' outputs for parent process.
    -p|--quiet-parent    Disable `stdout' output for parent process.
    -Q|--silent          Disable `stderr' and `stdout' outputs.
    -q|--quiet           Disable `stdout' output.
    -S|--source-all      Source every FUNC.
    -s|--source=FUNCS    Source each FUNC in FUNCS.
    -V|--verbose         Appends line number and context to errors.
    -v|--version         Print version info and exit.
    -x|--xtrace          Enables bash `xtrace' option.
    -|--                 End the options.

  Values:
    FUNC    Must be a valid `superglue' function. The `sgl_' prefix is optional.
    FUNCS   Must be a list of 1 or more FUNC using `,', `|', or ` ' to separate each.
    SCRIPT  Must be a valid file path to a `superglue' script.

  Functions:
    sgl_chk_cmd
    sgl_chk_dir
    sgl_chk_exit
    sgl_chk_file
    sgl_chk_uid
    sgl_color
    sgl_cp
    sgl_err
    sgl_mk_dest
    sgl_parse_args
    sgl_print
    sgl_set_color

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
    exit 0
  else
    local -r P='superglue'
    [[ "$1" =~ ^[a-z_]+$ ]] || _sgl_err VAL "invalid \`$P' FUNC \`$1'"

    local func="$1"
    [[ "$1" =~ ^sgl_ ]] || func="sgl_$1"
    [[ -f "${SGL_LIB}/${func}" ]] || _sgl_err VAL "invalid \`$P' FUNC \`$1'"
    [[ ${func} == sgl_source ]] && _sgl_err VAL "invalid \`$P' FUNC \`$1'"
    sgl_source ${func}
    ${func} --help
  fi
}
readonly -f _sgl_help
