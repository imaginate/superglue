# Superglue `sgl_mk_dest' Tests
# =============================
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2018 Adam A Smith <adam@imaginate.life>
##############################################################################

##############################################################################
## SETUP ENV
##############################################################################

# Define src and dest file paths.
local src="${SGLUE_DUMMY}/source.sgl.file"
local incl1="${SGLUE_DUMTMP1}/include.sgl.file"
local incl2="${SGLUE_DUMTMP4}/include.sgl.file"
local dest1="${SGLUE_DUMMY}/dest.sgl.file"
local dest2="${SGLUE_DUMTMP2}/dest.sgl.file"
local correct="${SGLUE_DUMMY}/correct.sgl.file"

# Make the test src file.
"${SGLUE_CAT}" <<'EOF' > "${src}"
# SOURCE
# @version 0.1.0-test
#
# @dest "$BASE/dest.sgl.file"
# @dest ${TMP2}/dest.sgl.file
# @mode 0755
#
# @var RESULT=success
# @var HOME="$HOME"
# @var USER='$USER'
# @set ZERO = 0
# @set SPACE = is ok 
##
# @include ./tmp1/*.sgl.file
##

if [[ '/path/to/@RESULT' != '/path/to/success' ]]; then
  echo 'var tag failed'
  exit 1
fi

if [[ "@HOME" != "$HOME" ]]; then
  echo 'var tag failed'
  exit 1
fi

if [[ '@USER' != '$USER' ]]; then
  echo 'var tag failed'
  exit 1
fi

if [[ '@ZERO@ZERO6' != '006' ]]; then
  echo 'var tag failed'
  exit 1
fi

if [[ '@SPACE' != 'is ok' ]]; then
  echo 'var tag failed'
  exit 1
fi

if [[ '@VERSION' != '0.1.0-test' ]]; then
  echo 'version tag failed'
  exit 1
fi
EOF

# Make the first test include file.
"${SGLUE_CAT}" <<'EOF' > "${incl1}"
###
# @include ./tmp4/*.sgl.file
###
EOF

# Make the second test include file.
"${SGLUE_CAT}" <<'EOF' > "${incl2}"
####
# Simple include magic.
####
EOF

# Make the correct result file.
"${SGLUE_CAT}" <<EOF > "${correct}"
# SOURCE
# @version 0.1.0-test
#
# @dest "\$BASE/dest.sgl.file"
# @dest \${TMP2}/dest.sgl.file
# @mode 0755
#
# @var RESULT=success
# @var HOME="\$HOME"
# @var USER='\$USER'
# @set ZERO = 0
# @set SPACE = is ok 
##
###
####
# Simple include magic.
####
###
##

if [[ '/path/to/success' != '/path/to/success' ]]; then
  echo 'var tag failed'
  exit 1
fi

if [[ "$HOME" != "\$HOME" ]]; then
  echo 'var tag failed'
  exit 1
fi

if [[ '\$USER' != '\$USER' ]]; then
  echo 'var tag failed'
  exit 1
fi

if [[ '006' != '006' ]]; then
  echo 'var tag failed'
  exit 1
fi

if [[ 'is ok' != 'is ok' ]]; then
  echo 'var tag failed'
  exit 1
fi

if [[ '0.1.0-test' != '0.1.0-test' ]]; then
  echo 'version tag failed'
  exit 1
fi
EOF

##############################################################################
## RUN FUNCTION
##############################################################################

local line

######################################################################
# @note-for-bash-newbies
# @lines 142-153
#
# The `while' loop is used to catch and register any errors from
# `sgl_mk_dest'. The following is an ordered sequence of events:
# - The `stderr' from `sgl_mk_dest' is redirected to `stdout'.
# - The original `stdout' for `sgl_mk_dest' is redirected and closed.
# - `sgl_mk_dest' is executed within a here document that captures the 
#   redirected `stderr' and sets it as the `stdin' for `read'.
# - Each line is read and any errors are thrown until `stdin' closes.
######################################################################
while IFS= read -r line; do
  if [[ -n "${line}" ]]; then
    sglue_throw "${line}"
  fi
done <<< "$("${SGLUE_BIN%/}/superglue" mk_dest \
  --define "BASE=${SGLUE_DUMMY}" \
  --define "TMP=${SGLUE_DUMTMP}" \
  --define "TMP1=${SGLUE_DUMTMP1}" \
  --define "TMP2=${SGLUE_DUMTMP2}" \
  --define "TMP3=${SGLUE_DUMTMP3}" \
  --define "TMP4=${SGLUE_DUMTMP4}" \
  -- "${src}" 3>&2 2>&1 1>&3-)"

##############################################################################
## CHECK RESULTS
##############################################################################

local path
local contents
local -r CONTENTS="$("${SGLUE_CAT}" "${correct}")"

for path in "${dest1}" "${dest2}"; do

  # Catch a missing dest file.
  if [[ ! -f "${path}" ]]; then
    sglue_throw "missing dest file \`${path}'"
  fi

  # Catch a non-executable dest file.
  if [[ ! -x "${path}" ]]; then
    sglue_throw "invalid file mode for dest file \`${path}'"
  fi

  # Catch incorrect dest file content.
  if [[ -f "${path}" ]]; then
    contents="$("${SGLUE_CAT}" "${path}")"
    if [[ "${contents}" != "${CONTENTS}" ]]; then
      sglue_throw "invalid dest file \`${path}'"
    fi
  fi

done
return 0

