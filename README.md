# Superglue [![build status](https://travis-ci.org/imaginate/superglue.svg?branch=master)](https://travis-ci.org/imaginate/superglue) [![version](https://img.shields.io/badge/version-0.1.0--alpha.6-brightgreen.svg?style=flat)](http://superglue.tech)

### Eat Bash Steroids

Superglue is a comprehensive bash library and wrapper designed for minimal kernel environments.
- Write quick and clean scripts with helper functions and variables.
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


### Examples
- **Interact Instantly**<br>
  This example copies a source file to multiple destinations with [sgl_mk_dest](#sgl_mk_dest). Destinations and other values are defined with tags (e.g. `# @TAG VALUE`) from within the source file for maximum convenience and flexibility.
  ```bash
  # make an example source file
  src="${HOME}/source.file"
  cat <<'EOF' > "${src}"
  # EXAMPLE SOURCE FILE
  # ...
  # @dest ${HOME}/destination.file
  # @dest $CUSTOM/destination.file
  # @mode 0755
  # @own user:group
  # ...
  EOF
  # run sgl_mk_dest which makes both destinations
  sgl mk_dest --define='CUSTOM=/your/custom/path' "${src}"
  ```

- **Wrap Warmly**<br>
  This example shows how you can quickly create executable scripts that are reliable and clear.
  ```bash
  #!/bin/superglue -S

  # Verify that the effective user is the root or exit.
  sgl_chk_uid --exit -- 0

  # Parse the arguments and exit if an invalid option is used.
  sgl_parse_args --options \
    '-a|--ask' Y \
    '-b|--bounce' \
    '-c|--coast' \
    '-t|--tell' M \
    '-?|--help'

  # Process the parsed options.
  for opt in "${SGL_OPTS[@]}"; do
    # ...
  done

  # On test failure print a clear error message and exit.
  test -n "${str}" || sgl_err VAL "invalid empty string"

  # If grep fails exit the process.
  ${grep} 'a mighty pattern' random.txt > ${NIL}
  sgl_chk_exit --exit --prg='Wrap Warmly' --cmd='grep' $?

  # Prettily print to stdout.
  sgl_print -C blue -t 'Your Choice' -D ' - ' -- 'Maybe...'
  sgl_print --title='VALUES' --delim=',' "${SGL_VALS[@]}"
  sgl_print --color green 'EXAMPLE PASSED'
  ```

## Reference
- [Install](#install)
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
  - [sgl_rm_dest](#sgl_rm_dest)
  - [sgl_set_color](#sgl_set_color)
  - [sgl_source](#sgl_source)

## Install
```sh
git clone https://github.com/imaginate/superglue.git
make -C superglue && rm -rf superglue
```
**NOTE**<br>
The following Linux packages are on the to-do list.
- [deb](https://wiki.debian.org/HowToPackageForDebian)
- [rpm](https://fedoraproject.org/wiki/How_to_create_an_RPM_package)
- [pkg](https://wiki.archlinux.org/index.php/creating_packages)
- [apk](https://wiki.alpinelinux.org/wiki/Creating_an_Alpine_package)
- [portage](https://wiki.gentoo.org/wiki/Portage)

## Command
```text

  sgl|sglue|superglue [...OPTION] FUNC [...FUNC_ARG]
  sgl|sglue|superglue [...OPTION] SCRIPT [...SCRIPT_ARG]

  Options:
    -a|--alias           Enable function names without `sgl_' prefixes for each sourced FUNC.
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
    sgl_rm_dest
    sgl_set_color
    sgl_source

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

## Variables

### Main
- `SGL_ARGS`  A _read-only_ zero-based indexed array of each [command](#command) passed `SCRIPT_ARG`.
- `SGL_FUNC`  The _read-only_ name of the [command](#command) passed `FUNC`.
- `SGL_OPTS`  See [sgl_parse_args](#sgl_parse_args).
- `SGL_OPT_BOOL`  See [sgl_parse_args](#sgl_parse_args).
- `SGL_OPT_VALS`  See [sgl_parse_args](#sgl_parse_args).
- `SGL_SCRIPT`  The _read-only_ name of the [command](#command) passed `SCRIPT`.
- `SGL_VALS`  See [sgl_parse_args](#sgl_parse_args).
- `SGL_VERSION`  The _read-only_ `superglue` version.

### Options
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

### Colors
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

## Functions

### sgl_chk_cmd
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

### sgl_chk_dir
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

### sgl_chk_exit
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

### sgl_chk_file
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

### sgl_chk_uid
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

### sgl_color
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
      `blue'
      `cyan'
      `green'
      `none'
      `purple'
      `red'
      `white'
      `yellow'
    DELIM  Can be any string. By default DELIM is ` '.
    MSG    Can be any string. May be provided via a piped `stdin'.

  Returns:
    0  PASS

```

### sgl_cp
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

### sgl_err
```text

  sgl_err [...OPTION] ERR ...MSG

  Options:
    -C|--color-title[=COLOR]  Color TITLE with COLOR (default= `red').
    -c|--color[-msg][=COLOR]  Color MSG with COLOR (default= `red').
    -D|--delim-title=DELIM    Deliminate TITLE and MSG with DELIM.
    -d|--delim[-msg]=DELIM    Deliminate each MSG with DELIM.
    -E|--no-escape            Do not evaluate escapes in MSG.
    -e|--escape               Do evaluate escapes in MSG.
    -h|-?|--help              Print help info and exit.
    -N|--no-color             Disable colored TITLE or MSG outputs.
    -n|--no-newline           Do not print a trailing newline.
    -P|--child                Mark this error as one for a child process.
    -p|--parent               Mark this error as one for a parent process.
    -Q|--silent               Disable `stderr' and `stdout' outputs.
    -q|--quiet                Disable `stdout' output.
    -r|--return               Return instead of exiting.
    -T|--no-title             Disable any TITLE to be printed.
    -t|--title=TITLE          Override the default TITLE to be printed.
    -V|--verbose              Append the line number and context to output.
    -v|--version              Print version info and exit.
    -|--                      End the options.

  Values:
    COLOR  Must be a color from the below options.
      `black'
      `blue'
      `cyan'
      `green'
      `none'
      `purple'
      `red'
      `white'
      `yellow'
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
    MSG    Can be any string. May be provided via a piped `stdin'.
    TITLE  Can be any string.

  Exit Codes:
    1  MISC  An unknown error.
    2  OPT   An invalid option.
    3  VAL   An invalid or missing value.
    4  AUTH  A permissions error.
    5  DPND  A dependency error.
    6  CHLD  A child process exited unsuccessfully.
    7  SGL   A `superglue' script error.

```

### sgl_mk_dest
```text

  sgl_mk_dest [...OPTION] ...SRC

  Options:
    -B|--backup-ext=EXT   Override the usual backup file extension.
    -b|--backup[=CTRL]    Make a backup of each existing destination file.
    -d|--define=VARS      Define variables for each DEST to use.
    -E|--no-empty         Force SRC to contain at least one destination tag.
    -e|--empty            Allow SRC to not contain a destination tag.
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
    ATTR   Must be a file attribute from below options.
      `mode'
      `ownership'
      `timestamps'
      `context'
      `links'
      `xattr'
      `all'
    ATTRS  Must be a list of one or more ATTR separated by `,'.
    CTRL   Must be a backup control method from below options.
      `none|off'      Never make backups (even if `--backup' is given).
      `numbered|t'    Make numbered backups.
      `existing|nil'  If numbered backups exist make numbered. Otherwise make simple.
      `simple|never'  Always make simple backups.
    DEST   Must be a valid path. Can include defined VAR KEYs identified by a
           leading `$' and optionally wrapped with curly brackets, `${KEY}'.
    EXT    Must be a valid file extension to append to the end of a backup file.
           The default is `~'. Spaces are not allowed.
    MODE   Must be a valid file mode.
    OWNER  Must be a valid USER[:GROUP].
    REGEX  Can be any string. Refer to bash test `=~' operator for more details.
    SRC    Must be a valid file path. The SRC file must contain at least one
           `dest' TAG unless `--empty' is used and can contain one `mode' and
           `own' TAG. Note that OPTION values take priority over TAG values.
    TAG    A TAG is defined within a SRC file's contents. It must be a one-line
           comment formatted as `# @TAG VALUE'. Spacing is optional except
           between TAG and VALUE. The TAG must be one of the options below.
      `dest'  Formatted `# @dest DEST'.
      `mode'  Formatted `# @mode MODE'.
      `own'   Formatted `# @own OWNER'.
    VAR    Must be a valid `KEY=VALUE' pair. The KEY must start with a character
           matching `[a-zA-Z_]', can only contain `[a-zA-Z0-9_]', and must end
           with `[a-zA-Z0-9]'. The VALUE must not contain a `,'.
    VARS   Must be a list of one or more VAR separated by `,'.

  Returns:
    0  PASS

```

### sgl_parse_args
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

### sgl_print
Flexibly print a message to `stdout` or a destination of choice.
```text

  sgl_print [...OPTION] ...MSG

  Options:
    -C|--color-title=COLOR  Color TITLE with COLOR.
    -c|--color[-msg]=COLOR  Color MSG with COLOR.
    -D|--delim-title=DELIM  Deliminate TITLE and MSG with DELIM.
    -d|--delim[-msg]=DELIM  Deliminate each MSG with DELIM.
    -E|--no-escape          Do not evaluate escapes in MSG.
    -e|--escape             Do evaluate escapes in MSG.
    -h|-?|--help            Print help info and exit.
    -N|--no-color           Disable colored TITLE or MSG outputs.
    -n|--no-newline         Do not print a trailing newline.
    -o|--out=DEST           Print this message to DEST.
    -P|--child              Mark this output as one for a child process.
    -p|--parent             Mark this output as one for a parent process.
    -Q|--silent             Disable `stderr' and `stdout' outputs.
    -q|--quiet              Disable `stdout' output.
    -T|--no-title           Disable any TITLE to be printed.
    -t|--title=TITLE        Print TITLE before MSG.
    -v|--version            Print version info and exit.
    -|--                    End the options.

  Values:
    COLOR  Must be a color from the below options.
      `black'
      `blue'
      `cyan'
      `green'
      `none'
      `purple'
      `red'
      `white'
      `yellow'
    DELIM  Can be any string. By default DELIM is ` '.
    DEST   Must be `1|stdout', `2|stderr', or a valid file path.
    MSG    Can be any string. May be provided via a piped `stdin'.
    TITLE  Can be any string.

  Returns:
    0  PASS

```

### sgl_rm_dest
```text

  sgl_rm_dest [...OPTION] ...SRC

  Options:
    -d|--define=VARS      Define variables for each DEST to use.
    -E|--no-empty         Force SRC to contain at least one destination tag.
    -e|--empty            Allow SRC to not contain a destination tag.
    -F|--no-force         If destination exists do not overwrite it.
    -f|--force            If destination exists overwrite it.
    -h|-?|--help          Print help info and exit.
    -Q|--silent           Disable `stderr' and `stdout' outputs.
    -q|--quiet            Disable `stdout' output.
    -t|--test=REGEX       Test each DEST path against REGEX (uses bash `=~').
    -V|--verbose          Print exec status details.
    -v|--version          Print version info and exit.
    -x|--one-file-system  Stay on this file system.
    -|--                  End the options.

  Values:
    DEST   Must be a valid path. Can include defined VAR KEYs identified by a
           leading `$' and optionally wrapped with curly brackets, `${KEY}'.
    REGEX  Can be any string. Refer to bash test `=~' operator for more details.
    SRC    Must be a valid file path. The SRC file must contain at least one
           `dest' TAG unless `--empty' is used and can contain one `mode' and
           `own' TAG. Note that OPTION values take priority over TAG values.
    TAG    A TAG is defined within a SRC file's contents. It must be a one-line
           comment formatted as `# @TAG VALUE'. Spacing is optional except
           between TAG and VALUE. The TAG must be one of the options below.
      `dest'  Formatted `# @dest DEST'.
      `mode'  Formatted `# @mode MODE'.
      `own'   Formatted `# @own OWNER'.
    VAR    Must be a valid `KEY=VALUE' pair. The KEY must start with a character
           matching `[a-zA-Z_]', can only contain `[a-zA-Z0-9_]', and must end
           with `[a-zA-Z0-9]'. The VALUE must not contain a `,'.
    VARS   Must be a list of one or more VAR separated by `,'.

  Returns:
    0  PASS

```

### sgl_set_color
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
      `blue'
      `cyan'
      `green'
      `purple'
      `red'
      `white'
      `yellow'

  Returns:
    0  PASS

```

### sgl_source
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
      sgl_rm_dest
      sgl_set_color
      sgl_source

  Returns:
    0  PASS

```

## Everything Else
[Issue/Suggestion](https://github.com/imaginate/superglue/issues)<br>
[Contribute](adam@imaginate.life)
