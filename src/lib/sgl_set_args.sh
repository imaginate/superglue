#!/bin/bash
#
# @dest /lib/superglue/sgl_set_args
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016 Adam A Smith <adam@imaginate.life> (http://imaginate.life)
#
# @use sgl_source set_args
# @return
#   0  PASS
################################################################################

############################################################
# @func sgl_set_args
# @use sgl_set_args [...OPTION]
# @opt -h|-?|--help  Print help info and exit.
# @opt -v|--version  Print version info and exit.
# @opt -|--          End the options.
# @return
#   0  PASS
############################################################
sgl_set_args()
{
  local -r FN='sgl_set_args'
  local -i i
  local -i len
  local opt

  # parse each argument
  _sgl_parse_args "${FN}" \
    '-h|-?|--help' 0 \
    '-v|--version' 0 \
    -- "$@"

  # parse each OPTION
  len=${#_SGL_OPTS[@]}
  for ((i=0; i<len; i++)); do
    opt="${_SGL_OPTS[${i}]}"
    case "${opt}" in
      -h|-\?|--help)
        ${cat} <<'EOF'

  sgl_set_args [...OPTION]

  Options:
    -h|-?|--help  Print help info and exit.
    -v|--version  Print version info and exit.
    -|--          End the options.

EOF
        exit 0
        ;;
      -v|--version)
        _sgl_version
        ;;
      *)
        _sgl_err SGL "invalid parsed \`${FN}' OPTION \`${opt}'"
        ;;
    esac
  done

  # set the args
  if [[ ${#SGL_ARGS[@]} -gt 0 ]]; then
    set -- "${SGL_ARGS[@]}"
  else
    set --
  fi
}
readonly -f sgl_set_args
