# Superglue [![version](https://img.shields.io/badge/version-0.1.0--alpha-yellow.svg?style=flat)](http://superglue.tech)

### Eat Bash Steroids

Superglue is a comprehensive bash library and wrapper designed for minimal kernel environments.
- Write quick and clean scripts with helper functions and references.
- Enjoy automatic environment stabilization and dependency checks.
- Discover documentation delight with thorough references and help guides.
- Embrace instant interactive love with automatic executable functions.
- Understand clear and verbose error reports and avoid uncaught errors.
- Master outputs with automatic switches and prettify your terminal with ease.
- Trust in less while getting more by only relying on four dependencies:
  - [Posix Bash v4](http://tiswww.case.edu/php/chet/bash/bashtop.html)
  - [GNU Coreutils](https://www.gnu.org/software/coreutils/coreutils.html)
  - [Posix Grep](https://www.gnu.org/software/grep/grep.html)
  - [Posix Sed](https://www.gnu.org/software/sed/sed.html)

--

**NOTE**<br>
The following work is still left before releasing the alpha version. To help please message [Adam](adam@imaginate.life).
- Add the complete implementation of `--quiet*` and `--silent*`.
- Add the automatic `--alias` creation.
- Add proper unit tests and setup [TravisCI](https://travis-ci.com/).

--

- [Example](#example)
- [Install](#install)
- [Reference](#reference)
- [Everything Else](#everything-else)


## Example
```bash
# Copies the source to each destination found in the source.
# Destinations are defined using `@dest /path/to/dest'.
# Also sets each destinations file mode and owner.
sgl mk_dest -m 0644 -o user -u ./source.file
```
```bash
#!/bin/superglue

# Load only the needed functions.
sgl_source 'chk_*' err parse_args print

# Verify the user is root or exit the process.
sgl_chk_uid --exit --prg='Example' 0

# Parse the arguments easily.
sgl_parse_args --prg 'Example' --options \
  '-a|--ask' Y \
  '-b|--bounce' \
  '-c|--coast' \
  '-t|--tell' M \
  '-?|--help'

# Handle the parsed options.
len=${#SGL_OPTS[@]}
for ((i=0; i<len; i++)); do
  opt="${SGL_OPTS[i]}"
  case "${opt}" in
    -a|--ask)
      DEMO_ASK="${SGL_OPT_VALS[i]}"
      # If empty throw an error and exit the process.
      [[ -n "${DEMO_ASK}" ]] || sgl_err VAL "invalid empty value for \`${opt}'"
      ;;
    -b|--bounce)
      DEMO_BOUNCE=1
      DEMO_COAST=0
      ;;
    -c|--coast)
      DEMO_BOUNCE=0
      DEMO_COAST=1
      ;;
    -t|--tell)
      if [[ ${SGL_OPT_BOOL[i]} -eq 1 ]]; then
        DEMO_TELL="${SGL_OPT_VALS[i]}"
      else
        DEMO_TELL="${DEMO_ASK}"
      fi
      ;;
    -\?|--help)
      echo 'some helpful info'
      exit 0
      ;;
  esac
done

# Print to stdout with easy disabling or prettifying.
sgl_print -C blue -t 'Your Choice' -D ' - ' -- 'Ask or tell?'
#  => "<blue>Your Choice</blue> - Ask or tell?"

# If grep fails exit the process.
${grep} 'a mighty pattern' random.txt > ${NIL}
sgl_chk_exit --exit --prg='Example' --cmd='grep' $?

sgl_print --title=VALUES --delim-msg=',' "${SGL_VALS[@]}"
sgl_print --color-msg green 'EXAMPLE PASSED'
exit 0
```

## Install

```sh
git clone https://github.com/imaginate/superglue.git
make -C superglue && rm -rf superglue
```

**NOTE**<br>
The following Linux packages are on the to-do list. To help please message [Adam](adam@imaginate.life).
- [deb](https://wiki.debian.org/HowToPackageForDebian)
- [rpm](https://fedoraproject.org/wiki/How_to_create_an_RPM_package)
- [pkg](https://wiki.archlinux.org/index.php/creating_packages)
- [apk](https://wiki.alpinelinux.org/wiki/Creating_an_Alpine_package)
- [portage](https://wiki.gentoo.org/wiki/Portage)


## Reference
- [Command](#command)
- [Variables](#varaibles)
  - [main](#main)
  - [options](#options)
  - [colors](#colors)
- [Functions](#functions)
  - [sgl_chk_cmd](#sgl_chk_cmd)
  - [sgl_chk_dir](#sgl_chk_dir)
  - [sgl_chk_exit](#sgl_chk_exit)
  - [sgl_chk_file](#sgl_chk_file)
  - [sgl_chk_uid](#sgl_chk_uid)
  - [sgl_color](#sgl_color)
  - [sgl_cp](#sgl_cp)
  - [sgl_err](#sgl_err)
  - [sgl_mk_dest](#sgl_mk_dest)
  - [sgl_parse_args](#sgl_parse_args)
  - [sgl_print](#sgl_print)
  - [sgl_set_color](#sgl_set_color)
  - [sgl_source](#sgl_source)

### Command
```text

  sgl|sglue|superglue [...OPTION] FUNC [...FUNC_ARG]
  sgl|sglue|superglue [...OPTION] SCRIPT [...SCRIPT_ARG]

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

```

### Variables

#### Main
- `SGL_ARGS`  A _read-only_ zero-based indexed array of each [command](#command) passed `SCRIPT_ARG`.
- `SGL_FUNC`  The _read-only_ name of the [command](#command) passed `FUNC`.
- `SGL_OPTS`  See [sgl_parse_args](#sgl_parse_args).
- `SGL_OPT_BOOL`  See [sgl_parse_args](#sgl_parse_args).
- `SGL_OPT_VALS`  See [sgl_parse_args](#sgl_parse_args).
- `SGL_SCRIPT`  The _read-only_ name of the [command](#command) passed `SCRIPT`.
- `SGL_VALS`  See [sgl_parse_args](#sgl_parse_args).
- `SGL_VERSION`  The _read-only_ `superglue` version.

#### Options
All options are booleans (i.e. their value is `1` for `true` or `0` for `false`).
- `SGL_ALIAS`
- `SGL_COLOR_OFF`
- `SGL_COLOR_ON`
- `SGL_QUIET`
- `SGL_QUIET_CHILD`
- `SGL_QUIET_PARENT`
- `SGL_SILENT`
- `SGL_SILENT_CHILD`
- `SGL_SILENT_PARENT`
- `SGL_VERBOSE`

#### Colors
All colors are evaluated [ANSI SGR escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code#graphics). Use [sgl_set_color](#sgl_set_color) to safely change these values.
- `SGL_BLACK`  Default code is `30`.
- `SGL_BLUE`  Default code is `94`.
- `SGL_CYAN`  Default code is `36`.
- `SGL_GREEN`  Default code is `32`.
- `SGL_PURPLE`  Default code is `35`.
- `SGL_RED`  Default code is `91`.
- `SGL_UNCOLOR`  Default code is `0`.
- `SGL_WHITE`  Default code is `97`.
- `SGL_YELLOW`  Default code is `33`.

### Functions

#### sgl_chk_cmd
```text

  sgl_chk_cmd [...OPTION] ...CMD

  Options:
    -h|-?|--help            Print help info and exit.
    -m|--msg|--message=MSG  Override the default fail message.
    -p|--prg|--program=PRG  Include the parent PRG in the fail message.
    -Q|--silent             Disable `stderr' and `stdout' outputs.
    -q|--quiet              Disable `stdout' output.
    -v|--version            Print version info and exit.
    -x|--exit[=ERR]         Exit on check fail (default= `DPND').
    -|--                    End the options.

  Values:
    CMD  A valid file path to an executable binary.
    ERR  Must be an error from the below options or any valid integer in the
         range of `1' to `126'.
      `MISC'  An unknown error (exit= `1').
      `OPT'   An invalid option (exit= `2').
      `VAL'   An invalid or missing value (exit= `3').
      `AUTH'  A permissions error (exit= `4').
      `DPND'  A dependency error (exit= `5').
      `CHLD'  A child process exited unsuccessfully (exit= `6').
      `SGL'   A `superglue' script error (exit= `7').
    MSG  Can be any string. The patterns, `CMD' and `PRG', are substituted
         with the proper values. The default MSG is:
           `missing executable `CMD'[ for `PRG']'
    PRG  Can be any string.

  Returns:
    0  PASS
    1  FAIL

```

#### sgl_chk_dir
```text

  sgl_chk_dir [...OPTION] ...DIR

  Options:
    -h|-?|--help            Print help info and exit.
    -m|--msg|--message=MSG  Override the default fail message.
    -p|--prg|--program=PRG  Include the parent PRG in the fail message.
    -Q|--silent             Disable `stderr' and `stdout' outputs.
    -q|--quiet              Disable `stdout' output.
    -v|--version            Print version info and exit.
    -x|--exit[=ERR]         Exit on check fail (default= `DPND').
    -|--                    End the options.

  Values:
    DIR  A valid directory path.
    ERR  Must be an error from the below options or any valid integer in the
         range of `1' to `126'.
      `MISC'  An unknown error (exit= `1').
      `OPT'   An invalid option (exit= `2').
      `VAL'   An invalid or missing value (exit= `3').
      `AUTH'  A permissions error (exit= `4').
      `DPND'  A dependency error (exit= `5').
      `CHLD'  A child process exited unsuccessfully (exit= `6').
      `SGL'   A `superglue' script error (exit= `7').
    MSG  Can be any string. The patterns, `DIR' and `PRG', are substituted
         with the proper values. The default MSG is:
           `invalid [`PRG' ]directory path `DIR''
    PRG  Can be any string.

  Returns:
    0  PASS
    1  FAIL

```

#### sgl_chk_exit
```text

  sgl_chk_exit [...OPTION] ...CODE

  Options:
    -h|-?|--help            Print help info and exit.
    -c|--cmd|--command=CMD  Include the CMD string in the fail message.
    -m|--msg|--message=MSG  Override the default fail message.
    -p|--prg|--program=PRG  Include the parent PRG in the fail message.
    -Q|--silent             Disable `stderr' and `stdout' outputs.
    -q|--quiet              Disable `stdout' output.
    -v|--version            Print version info and exit.
    -x|--exit[=ERR]         Exit on check fail (default= `DPND').
    -|--                    End the options.

  Values:
    CMD   Can be any string. The default is `a command'.
    CODE  Must be an integer in the range of `0' to `255'.
    ERR   Must be an error from the below options or any valid integer in the
          range of `1' to `126'.
      `MISC'  An unknown error (exit= `1').
      `OPT'   An invalid option (exit= `2').
      `VAL'   An invalid or missing value (exit= `3').
      `AUTH'  A permissions error (exit= `4').
      `DPND'  A dependency error (exit= `5').
      `CHLD'  A child process exited unsuccessfully (exit= `6').
      `SGL'   A `superglue' script error (exit= `7').
    MSG   Can be any string. The patterns, `CMD', `PRG', and `CODE', are
          substituted with the proper values. The default MSG is:
            ``CMD'[ in `PRG'] exited with `CODE''
    PRG   Can be any string.

  Returns:
    0  PASS  CODE is zero.
    1  FAIL  CODE is non-zero.

```

#### sgl_chk_file
```text

  sgl_chk_file [...OPTION] ...FILE

  Options:
    -h|-?|--help            Print help info and exit.
    -m|--msg|--message=MSG  Override the default fail message.
    -p|--prg|--program=PRG  Include the parent PRG in the fail message.
    -Q|--silent             Disable `stderr' and `stdout' outputs.
    -q|--quiet              Disable `stdout' output.
    -v|--version            Print version info and exit.
    -x|--exit[=ERR]         Exit on check fail (default= `DPND').
    -|--                    End the options.

  Values:
    ERR   Must be an error from the below options or any valid integer in the
          range of `1' to `126'.
      `MISC'  An unknown error (exit= `1').
      `OPT'   An invalid option (exit= `2').
      `VAL'   An invalid or missing value (exit= `3').
      `AUTH'  A permissions error (exit= `4').
      `DPND'  A dependency error (exit= `5').
      `CHLD'  A child process exited unsuccessfully (exit= `6').
      `SGL'   A `superglue' script error (exit= `7').
    FILE  A valid file path.
    MSG   Can be any string. The patterns, `FILE' and `PRG', are substituted
          with the proper values. The default MSG is:
            `invalid [`PRG' ]file path `FILE''
    PRG   Can be any string.

  Returns:
    0  PASS
    1  FAIL

```

#### sgl_chk_uid
```text

  sgl_chk_uid [...OPTION] ...UID

  Options:
    -h|-?|--help            Print help info and exit.
    -i|--invert             Invert the check to fail if a UID matches.
    -m|--msg|--message=MSG  Override the default fail message.
    -p|--prg|--program=PRG  Include the parent PRG in the fail message.
    -Q|--silent             Disable `stderr' and `stdout' outputs.
    -q|--quiet              Disable `stdout' output.
    -v|--version            Print version info and exit.
    -x|--exit[=ERR]         Exit on check fail (default= `AUTH').
    -|--                    End the options.

  Values:
    ERR  Must be an error from the below options or any valid integer in the
         range of `1' to `126'.
      `MISC'  An unknown error (exit= `1').
      `OPT'   An invalid option (exit= `2').
      `VAL'   An invalid or missing value (exit= `3').
      `AUTH'  A permissions error (exit= `4').
      `DPND'  A dependency error (exit= `5').
      `CHLD'  A child process exited unsuccessfully (exit= `6').
      `SGL'   A `superglue' script error (exit= `7').
    MSG  Can be any string. The patterns, `UID' and `PRG', are substituted
         with the proper values. The default MSG is:
           `invalid user permissions[ for `PRG']'
    PRG  Can be any string.
    UID  Must be an integer in the range of `0' to `60000'.

  Returns:
    0  PASS  Current effective user matches a UID.
    1  FAIL  Current effective user does not match a UID.

```

#### sgl_color
Note that `SGL_QUIET` and `SGL_SILENT` do not disable printing the colored `MSG` to `stdout`.
```text

  sgl_color [...OPTION] COLOR ...MSG

  Options:
    -d|--delim=DELIM  Use DELIM to deliminate each MSG.
    -h|-?|--help      Print help info and exit.
    -Q|--silent       Disable `stderr' and `stdout' outputs.
    -q|--quiet        Disable `stdout' output.
    -v|--version      Print version info and exit.
    -|--              End the options.

  Values:
    COLOR  Must be a color from the below options.
      `black'
      `red'
      `green'
      `yellow'
      `blue'
      `purple'
      `cyan'
      `white'
    DELIM  Can be any string. By default DELIM is ` '.
    MSG    Can be any string.

```

#### sgl_cp
```text

  sgl_cp [...OPTION] SRC DEST
  sgl_cp [...OPTION] ...SRC DEST_DIR
  sgl_cp [...OPTION] -d DEST_DIR ...SRC

  Options:
    -B|--backup-ext=EXT   Override the usual backup file extension.
    -b|--backup[=CTRL]    Make a backup of each existing destination file.
    -D|--no-dest-dir      Treat DEST as a normal file (not a DEST_DIR).
    -d|--dest-dir=DIR     Copy each SRC into DIR.
    -F|--no-force         If destination exists do not overwrite it.
    -f|--force            If destination exists overwrite it.
    -H|--cmd-dereference  Follow command-line SRC symlinks.
    -h|-?|--help          Print help info and exit.
    -K|--no-keep=ATTRS    Do not preserve the ATTRS.
    -k|--keep[=ATTRS]     Keep the ATTRS (default= `mode,ownership,timestamps').
    -L|--dereference      Always follow SRC symlinks.
    -l|--link             Hard link files instead of copying.
    -m|--mode=MODE        Set the file mode for each destination.
    -n|--no-clobber       If destination exists do not overwrite.
    -o|--owner=OWNER      Set the file owner for each destination.
    -P|--no-dereference   Never follow SRC symlinks.
    -Q|--silent           Disable `stderr' and `stdout' outputs.
    -q|--quiet            Disable `stdout' output.
    -r|--recursive        Copy directories recursively.
    -s|--symlink          Make symlinks instead of copying.
    -u|--update           Copy only when SRC is newer than DEST.
    -V|--verbose          Print exec status details.
    -v|--version          Print version info and exit.
    -w|--warn             If destination exists prompt before overwrite.
    -x|--one-file-system  Stay on this file system.
    -|--                  End the options.

  Values:
    ATTRS  A comma-separated list of file attributes from below options.
      `mode'
      `ownership'
      `timestamps'
      `context'
      `links'
      `xattr'
      `all'
    CTRL   A version control method to use for backups from below options.
      `none|off'      Never make backups (even if `--backup' is given).
      `numbered|t'    Make numbered backups.
      `existing|nil'  If numbered backups exist make numbered. Otherwise make simple.
      `simple|never'  Always make simple backups.
    DEST   Must be a valid path.
    DIR    Must be a valid directory path.
    EXT    An extension to append to the end of a backup file. The default is `~'.
    MODE   Must be a valid file mode.
    OWNER  Must be a valid USER[:GROUP].
    SRC    Must be a valid file path.

```

#### sgl_err
```text

  sgl_err [...OPTION] ERR ...MSG

  Options:
    -d|--delim=DELIM  Deliminate each MSG with DELIM.
    -h|-?|--help      Print help info and exit.
    -Q|--silent       Disable `stderr' and `stdout' outputs.
    -q|--quiet        Disable `stdout' output.
    -r|--return       Return instead of exiting.
    -v|--version      Print version info and exit.
    -|--              End the options.

  Values:
    DELIM  Can be any string. The default is ` '.
    ERR    Must be an error from the below options or any valid integer
           in the range of `1' to `126'.
      `MISC'  An unknown error (exit= `1').
      `OPT'   An invalid option (exit= `2').
      `VAL'   An invalid or missing value (exit= `3').
      `AUTH'  A permissions error (exit= `4').
      `DPND'  A dependency error (exit= `5').
      `CHLD'  A child process exited unsuccessfully (exit= `6').
      `SGL'   A `superglue' script error (exit= `7').
    MSG    Can be any string.

  Exit Codes:
    1  MISC  An unknown error.
    2  OPT   An invalid option.
    3  VAL   An invalid or missing value.
    4  AUTH  A permissions error.
    5  DPND  A dependency error.
    6  CHLD  A child process exited unsuccessfully.
    7  SGL   A `superglue' script error.

```

#### sgl_mk_dest
```text

  sgl_mk_dest [...OPTION] ...SRC

  Options:
    -B|--backup-ext=EXT   Override the usual backup file extension.
    -b|--backup[=CTRL]    Make a backup of each existing destination file.
    -F|--no-force         If destination exists do not overwrite it.
    -f|--force            If destination exists overwrite it.
    -H|--cmd-dereference  Follow command-line SRC symlinks.
    -h|-?|--help          Print help info and exit.
    -K|--no-keep=ATTRS    Do not preserve the ATTRS.
    -k|--keep[=ATTRS]     Keep the ATTRS (default= `mode,ownership,timestamps').
    -L|--dereference      Always follow SRC symlinks.
    -l|--link             Hard link files instead of copying.
    -m|--mode=MODE        Set the file mode for each destination.
    -n|--no-clobber       If destination exists do not overwrite.
    -o|--owner=OWNER      Set the file owner for each destination.
    -P|--no-dereference   Never follow SRC symlinks.
    -Q|--silent           Disable `stderr' and `stdout' outputs.
    -q|--quiet            Disable `stdout' output.
    -s|--symlink          Make symlinks instead of copying.
    -t|--test=REGEX       Test each DEST path against REGEX (uses bash `=~').
    -u|--update           Copy only when SRC is newer than DEST.
    -V|--verbose          Print exec status details.
    -v|--version          Print version info and exit.
    -w|--warn             If destination exists prompt before overwrite.
    -x|--one-file-system  Stay on this file system.
    -|--                  End the options.

  Values:
    ATTRS  A comma-separated list of file attributes from below options.
      `mode'
      `ownership'
      `timestamps'
      `context'
      `links'
      `xattr'
      `all'
    CTRL   A version control method to use for backups from below options.
      `none|off'      Never make backups (even if `--backup' is given).
      `numbered|t'    Make numbered backups.
      `existing|nil'  If numbered backups exist make numbered. Otherwise make simple.
      `simple|never'  Always make simple backups.
    DEST   Must be a valid path.
    EXT    An extension to append to the end of a backup file. The default is `~'.
    MODE   Must be a valid file mode.
    OWNER  Must be a valid USER[:GROUP].
    REGEX  Can be any string. Refer to bash test `=~' operator for more details.
    SRC    Must be a valid file path. File must also contain at least one
           destination tag: `# @dest DEST'.

```

#### sgl_parse_args
This function parses each argument in `SGL_ARGS` and saves the resulting option/values to the following zero-based indexed arrays:
- `SGL_OPTS`  Each parsed option (e.g. `-s` or `--long`).
- `SGL_OPT_BOOL`  Whether each option has a value (`0` or `1`).
- `SGL_OPT_VALS`  The parsed option value.
- `SGL_VALS`  The remaining (non-option) parsed values.
```text

  sgl_parse_args [...OPTION]

  Options:
    -a|--args|--arguments [...ARG]
      Override the args to parse (default uses `"${SGL_ARGS[@]}"'). Must be the
      last OPTION used. Do not use `=' between this OPTION and any ARG.
    -o|--opts|--options [...OPTS[=VAL]] [-|--]
      Define each acceptable OPT and VAL (default= `0'). If this OPTION is not
      the last one used, it must use `-' or `--' to indicate the end of OPTS.
      Do not use `=' between this OPTION and any OPTS. Note that the OPTS
      `"-|--" NO' is automatically assumed.
    -p|--prg|--program=PRG
      Define a program name to include in any error messages.
    -Q|--silent   Disable `stderr' and `stdout' outputs.
    -q|--quiet    Disable `stdout' output.
    -v|--version  Print version info and exit.
    -?|-h|--help  Print help info and exit.

  Values:
    ARG   Each original argument. Can be any string.
    OPT   A short (e.g. `-o') or long (e.g. `--opt') option pattern.
    OPTS  One or more OPT. Use `|' to separate each OPT (e.g. `-o|--opt').
    PRG   A program name. Can be any string.
    VAL   Indicates whether each OPT accepts a value. Must be a choice from below.
      `0|N|NO'     The OPT has no value.
      `1|Y|YES'    The OPT requires a value.
      `2|M|MAYBE'  The OPT can have a value.

```

#### sgl_print
```text

  sgl_print [...OPTION] ...MSG

  Options:
    -C|--color-title=COLOR  Color TITLE with COLOR.
    -c|--color[-msg]=COLOR  Color MSG with COLOR.
    -D|--delim-title=DELIM  Deliminate TITLE and MSG with DELIM.
    -d|--delim[-msg]=DELIM  Deliminate each MSG with DELIM.
    -e|--escape             Evaluate escapes.
    -h|-?|--help            Print help info and exit.
    -n|--no-newline         Do not print a trailing newline.
    -Q|--silent             Disable `stderr' and `stdout' outputs.
    -q|--quiet              Disable `stdout' output.
    -t|--title=TITLE        Print TITLE before MSG.
    -v|--version            Print version info and exit.
    -|--                    End the options.

  Values:
    COLOR  Must be a color from the below options.
      `black'
      `red'
      `green'
      `yellow'
      `blue'
      `purple'
      `cyan'
      `white'
    DELIM  Can be any string. By default DELIM is ` '.
    MSG    Can be any string.
    TITLE  Can be any string.

```

#### sgl_set_color
```text

  sgl_set_color [...OPTION] [...COLOR[=ANSI]]

  Options:
    -d|--disable  Disable a COLOR or all colors.
    -e|--enable   Enable a COLOR or all colors.
    -h|-?|--help  Print help info and exit.
    -Q|--silent   Disable `stderr' and `stdout' outputs.
    -q|--quiet    Disable `stdout' output.
    -r|--reset    Reset a COLOR or all colors.
    -v|--version  Print version info and exit.
    -|--          End the options.

  Values:
    ANSI   Must be an ANSI color code with or without evaluated escapes and
           form (e.g. `36', `0;36m', `\e[0;36m', or `\033[0;36m').
    COLOR  Must be a color from the below options. If a COLOR is defined
           without any OPTION or ANSI then the COLOR is reset.
      `black'
      `red'
      `green'
      `yellow'
      `blue'
      `purple'
      `cyan'
      `white'

```

#### sgl_source
Note that `sgl_source` is automatically available within `superglue`.
```text

  sgl_source [...OPTION] ...FUNC

  Options:
    -h|-?|--help  Print help info and exit.
    -Q|--silent   Disable `stderr' and `stdout' outputs.
    -q|--quiet    Disable `stdout' output.
    -v|--version  Print version info and exit.
    -|--          End the options.

  Values:
    FUNC  Must be one of the below `superglue' functions. The `sgl_' prefix
          is optional, and the globstar, `*', may be used.
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

  Returns:
    0  PASS

```


## Everything Else
[Issue/Suggestion](https://github.com/imaginate/superglue/issues)<br>
[Contribute](adam@imaginate.life)
