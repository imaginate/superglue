# Verify `sgl_mk_dest'.
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2017 Adam A Smith <adam@imaginate.life>
##############################################################################

##############################################################################
## SETUP ENV
##############################################################################

# Define src and dest file paths.
local src="${DUMMY}/source.sgl.file"
local incl1="${DUMTMP1}/include.sgl.file"
local incl2="${DUMTMP4}/include.sgl.file"
local dest1="${DUMMY}/dest.sgl.file"
local dest2="${DUMTMP2}/dest.sgl.file"
local correct="${DUMMY}/correct.sgl.file"

# Make the test src file.
cat <<'EOF' > "${src}"
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
# @var SPACE = is ok 
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
cat <<'EOF' > "${incl1}"
###
# @include ./tmp4/*.sgl.file
###
EOF

# Make the second test include file.
cat <<'EOF' > "${incl2}"
####
# Simple include magic.
####
EOF

# Make the correct result file.
cat <<EOF > "${correct}"
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
# @var SPACE = is ok 
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
# @lines 141-152
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
    throw "${line}"
  fi
done <<< "$(sgl mk_dest \
  --define "BASE=${DUMMY}" \
  --define "TMP=${DUMTMP}" \
  --define "TMP1=${DUMTMP1}" \
  --define "TMP2=${DUMTMP2}" \
  --define "TMP3=${DUMTMP3}" \
  --define "TMP4=${DUMTMP4}" \
  -- "${src}" 3>&2 2>&1 1>&3-)"

##############################################################################
## CHECK RESULTS
##############################################################################

local path

for path in "${dest1}" "${dest2}"; do

  # Catch a missing dest file.
  if [[ ! -f "${path}" ]]; then
    throw "missing dest file \`${path}'"
  fi

  # Catch a non-executable dest file.
  if [[ ! -x "${path}" ]]; then
    throw "invalid file mode for dest file \`${path}'"
  fi

  # Catch incorrect dest file content.
  if [[ -f "${path}" ]]; then
    if [[ "$(cat "${correct}")" != "$(cat "${path}")" ]]; then
      throw "invalid dest file \`${path}'"
    fi
  fi

done
return 0

