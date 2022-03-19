# Superglue Installation Tests
# ============================
#
# @author Adam Smith <imagineadamsmith@gmail.com> (https://github.com/imaginate)
# @copyright 2016-2022 Adam A Smith <imagineadamsmith@gmail.com>
##############################################################################

local name
local path

##############################################################################
## CHECK BIN
##############################################################################

if sglue_is_dir -r -- "${SGLUE_BIN}"; then
  for name in "${SGLUE_CMDS[@]}"; do
    path="${SGLUE_BIN}/${name}"
    if ! sglue_is_file -r -x -- "${path}"; then
      sglue_throw "missing executable file \`${path}'"
    fi
  done
else
  sglue_throw "missing readable dir \`${SGLUE_BIN}'"
fi

##############################################################################
## CHECK LIB
##############################################################################

if sglue_is_dir -r -- "${SGLUE_LIB}"; then
  for name in "${SGLUE_FUNCS[@]}"; do
    path="${SGLUE_LIB}/${name}"
    if ! sglue_is_file -r -- "${path}"; then
      sglue_throw "missing readable file \`${path}'"
    fi
  done
else
  sglue_throw "missing readable dir \`${SGLUE_LIB}'"
fi

##############################################################################
## CHECK HELP
##############################################################################

if sglue_is_dir -r -- "${SGLUE_HELP}"; then
  for name in superglue "${SGLUE_FUNCS[@]}"; do
    path="${SGLUE_HELP}/${name}"
    if ! sglue_is_file -r -- "${path}"; then
      sglue_throw "missing readable file \`${path}'"
    fi
  done
else
  sglue_throw "missing readable dir \`${SGLUE_HELP}'"
fi

return 0

