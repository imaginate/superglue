# Superglue `sgl_rm_dest' Tests
# =============================
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2017 Adam A Smith <adam@imaginate.life>
##############################################################################

##############################################################################
## SETUP ENV
##############################################################################

# Define src and dest file paths.
local src="${SGLUE_DUMMY}/source.sgl.file"
local dest1="${SGLUE_DUMMY}/dest.sgl.file"
local dest2="${SGLUE_DUMTMP}/dest.sgl.file"

# Make the test src file.
"${SGLUE_CAT}" <<'EOF' > "${src}"
# SOURCE
# @dest "$HOME/dest.sgl.file"
# @dest ${TMP}/dest.sgl.file
# @mode 0755
# ...
EOF

# Make each dest file.
"${SGLUE_CP}" -T -- "${src}" "${dest1}"
"${SGLUE_CP}" -T -- "${src}" "${dest2}"

##############################################################################
## RUN FUNCTION
##############################################################################

local line

######################################################################
# @note-for-bash-newbies
# @lines 48-55
#
# The `while' loop is used to catch and register any errors from
# `sgl_rm_dest'. The following is an ordered sequence of events:
# - The `stderr' from `sgl_rm_dest' is redirected to `stdout'.
# - The original `stdout' for `sgl_rm_dest' is redirected and closed.
# - `sgl_rm_dest' is executed within a here document that captures the 
#   redirected `stderr' and sets it as the `stdin' for `read'.
# - Each line is read and any errors are thrown until `stdin' closes.
######################################################################
while IFS= read -r line; do
  if [[ -n "${line}" ]]; then
    sglue_throw "${line}"
  fi
done <<< "$("${SGLUE_BIN%/}/superglue" rm_dest \
  --define "HOME=${SGLUE_DUMMY}" \
  --define "TMP=${SGLUE_DUMTMP}" \
  -- "${src}" 3>&2 2>&1 1>&3-)"

##############################################################################
## CHECK RESULTS
##############################################################################

local path

for path in "${dest1}" "${dest2}"; do

  # Catch an existing dest file.
  if [[ -f "${path}" ]]; then
    sglue_throw "existing dest file \`${path}'"
  fi

done
return 0

