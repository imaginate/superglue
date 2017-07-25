#!/bin/bash
#
# Verify the installation.
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2017 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
################################################################################

local name
local path

################################################################################
## CHECK BIN
################################################################################

for name in "${SGLUE_CMDS[@]}"; do
  path="${BIN}/${name}"
  if [[ ! -x "${path}" ]]; then
    throw "missing executable path \`${path}'"
  fi
done

################################################################################
## CHECK LIB
################################################################################

for name in "${SGLUE_FUNCS[@]}"; do
  path="${LIB}/${name}"
  if [[ ! -r "${path}" ]]; then
    throw "missing readable path \`${path}'"
  fi
done

################################################################################
## CHECK HELP
################################################################################

for name in superglue "${SGLUE_FUNCS[@]}"; do
  path="${HELP}/${name}"
  if [[ ! -r "${path}" ]]; then
    throw "missing readable path \`${path}'"
  fi
done
return 0

