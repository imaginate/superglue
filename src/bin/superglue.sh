#!/bin/bash --
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
# @opt -a|--alias           Enable aliases without `sgl_' prefixes for each sourced FUNC.
# @opt -C|--no-color        Disable ANSI output coloring for terminals.
# @opt -c|--color           Enable ANSI output coloring for non-terminals.
# @opt -D|--silent-child    Disable `stderr' and `stdout' outputs for child processes.
# @opt -d|--quiet-child     Disable `stdout' output for child processes.
# @opt -P|--silent-parent   Disable `stderr' and `stdout' outputs for parent process.
# @opt -p|--quiet-parent    Disable `stdout' output for parent process.
# @opt -Q|--silent          Disable `stderr' and `stdout' outputs.
# @opt -q|--quiet           Disable `stdout' output.
# @opt -S|--source-all      Source every FUNC.
# @opt -s|--source=FUNCS    Source each FUNC in FUNCS.
# @opt -V|--verbose         Appends line number and context to errors.
# @opt -v|--version[=FUNC]  Print version info and exit.
# @opt -x|--xtrace          Enables bash `xtrace' option.
# @opt -?|-h|--help[=FUNC]  Print help info and exit.
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
#   5  DEP   A dependency error.
#   6  CHLD  A child process exited unsuccessfully.
#   7  INTL  An internal script error.
################################################################################
