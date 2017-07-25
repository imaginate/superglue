# Superglue Wrapper Tests
# =======================
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2017 Adam A Smith <adam@imaginate.life>
##############################################################################

##############################################################################
## SETUP ENV
##############################################################################

# Define test file paths.
local cmd="${SGLUE_DUMMY}/fake.sgl.cmd"

# Make the wrapped script.
"${SGLUE_CAT}" <<'EOF' > "${cmd}"
#!/bin/superglue -C

# Load only the needed functions.
sgl_source 'chk_*' err parse_args print

# Verify the user is root or exit the process.
sgl_chk_uid --exit --prg='Example' 1000

# Parse the arguments easily.
sgl_parse_args \
  --prg 'Example' \
  --options \
    '-a|--ask'    Y \
    '-b|--bounce'   \
    '-c|--coast'    \
    '-t|--tell'   M \
    '-?|--help'

# Handle the parsed options.
(( i=0 ))
for opt in "${SGL_OPTS[@]}"; do
  case "${opt}" in
    -a|--ask)
      DEMO_ASK="${SGL_OPT_VALS[i]}"
      # If empty throw an error and exit the process.
      if [[ -z "${DEMO_ASK}" ]]; then
        sgl_err VAL "invalid empty value for \`${opt}'"
      fi
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
  (( ++i ))
done

# If grep fails exit the process.
printf '%s' 'has a mighty pattern' | ${grep} 'a mighty pattern' > ${NIL}
sgl_chk_exit --exit --cmd='grep' ${?}

exit 0
EOF
"${SGLUE_CHMOD}" 0755 "${cmd}"

##############################################################################
## RUN SCRIPT
##############################################################################

local line

######################################################################
# @note-for-bash-newbies
# @lines 95-99
#
# The `while' loop is used to catch and register any errors from the
# wrapped script. The following is an ordered sequence of events:
# - The script's `stderr' is redirected to `stdout'.
# - The script's original `stdout' is redirected and closed.
# - The script is executed within a here document that captures the 
#   redirected `stderr' and sets it as the `stdin' for `read'.
# - Each line is read and any errors are thrown until `stdin' closes.
######################################################################
while IFS= read -r line; do
  if [[ -n "${line}" ]]; then
    sglue_throw "${line}"
  fi
done <<< "$("${cmd}" --ask='Something?' -ct 3>&2 2>&1 1>&3-)"

