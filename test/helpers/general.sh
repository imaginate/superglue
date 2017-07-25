# General Helpers
# ===============
#
# General helper functions for use throughout the tests. All functions defined
# on this page are listed in declared order below. Note that all functions
# require the prefix `sglue_'.
#
# - `sglue_clean_tree'
# - `sglue_get_paths'
# - `sglue_int_err'
# - `sglue_is_dir'
# - `sglue_is_file'
# - `sglue_is_name'
# - `sglue_is_path'
# - `sglue_is_rel_dir'
# - `sglue_mk_dir'
# - `sglue_rm'
# - `sglue_rm_dir'
#
# @author Adam Smith <adam@imaginate.life> (http://imaginate.life)
# @copyright 2016-2017 Adam A Smith <adam@imaginate.life>
##############################################################################

############################################################
# @func sglue_clean_tree
# @use sglue_clean_tree DIR
# @val DIR
#   Must be a valid file system path to a directory.
# @return
#   0  PASS
# @exit-on-error
#   9  INTERNAL_SUPERGLUE_TEST_ERROR
############################################################
sglue_clean_tree()
{
  if [[ ${#} -lt 1 ]]; then
    sglue_int_err \
      "missing \`DIR' argument for a call to \`sglue_clean_tree'"
  fi

  local -r DIR="${1}"

  if ! sglue_is_dir -r -s "${DIR}"; then
    sglue_int_err \
      "invalid \`DIR' argument passed to \`sglue_clean_tree'" \
      "    invalid-dir-path: \`${DIR}'"
  fi

  local path

  while IFS= read -r path; do
    if [[ -n "${path}" ]]; then
      sglue_clean_tree "${path}"
    fi
  done <<< "$(sglue_get_paths -d -s -- "${DIR}")"

  while IFS= read -r path; do
    if [[ -n "${path}" ]]; then
      sglue_rm -- "${path}"
    fi
  done <<< "$(sglue_get_paths -f -- "${DIR}")"

  return 0
}
declare -f -r sglue_clean_tree

############################################################
# @func sglue_get_paths
# @use sglue_get_paths [...OPTION] DIR
# @opt -d|--dir|--directory
#   Only get paths that are a directory.
# @opt -f|--file
#   Only get paths that are a file.
# @opt -H|--no-sym-link
#   Only get paths that are **not** a symbolic link.
# @opt -h|--sym-link
#   Only get paths that are a symbolic link.
# @opt -r|--readable
#   Only get paths that are readable.
# @opt -x|--executable
#   Only get paths that are executable.
# @opt --
#   End the options.
# @val DIR
#   Must be a valid file system path to a directory.
# @return
#   0  PASS
############################################################
sglue_get_paths()
{
  local -i d=0
  local -i f=0
  local -i H=0
  local -i h=0
  local -i r=0
  local -i x=0
  local opt

  if [[ ${#} -lt 1 ]]; then
    return 0
  fi

  for opt in "${@}"; do
    case "${opt}" in
      -d|--dir|--directory)
        d=1
        f=0
        ;;
      -f|--file)
        d=0
        f=1
        ;;
      -H|--no-sym-link)
        H=1
        h=0
        ;;
      -h|--sym-link)
        H=0
        h=1
        ;;
      -r|--readable)
        r=1
        ;;
      -x|--executable)
        x=1
        ;;
      --)
        shift
        break
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  if [[ ${#} -lt 1 ]]; then
    return 0
  fi

  local -r DIR="${1%/}"

  if ! sglue_is_dir -r -s "${DIR}"; then
    return 0
  fi
  if [[ ${H} -eq 1 ]] && [[ -h "${DIR}" ]]; then
    return 0
  fi
  if [[ ${h} -eq 1 ]] && [[ ! -h "${DIR}" ]]; then
    return 0
  fi

  local -a opts=( '-s' )

  if [[ ${d} -eq 1 ]]; then
    opts+=( '-d' )
  fi
  if [[ ${f} -eq 1 ]]; then
    opts+=( '-f' )
  fi
  if [[ ${H} -eq 1 ]]; then
    opts+=( '-H' )
  fi
  if [[ ${h} -eq 1 ]]; then
    opts+=( '-h' )
  fi
  if [[ ${r} -eq 1 ]]; then
    opts+=( '-r' )
  fi
  if [[ ${x} -eq 1 ]]; then
    opts+=( '-x' )
  fi

  local path

  while IFS= read -r path; do
    path="${DIR}/${path##*/}"
    if sglue_is_path "${opts[@]}" -- "${path}"; then
      printf '%s\n' "${path}"
    fi
  done <<< "$("${SGLUE_LS}" -b -1 -A -- "${DIR}")"
  return 0
}
declare -f -r sglue_get_paths

############################################################
# @func sglue_int_err
# @use sglue_int_err ...LINE
# @val LINE
#   Should be a valid line of text to add to `stderr'. A
#   newline (e.g. `\n') is automatically appended to each
#   LINE.
# @exit
#   9  INTERNAL_SUPERGLUE_TEST_ERROR
############################################################
sglue_int_err()
{
  local -r TITLE="${SGLUE_RED}INTERNAL TEST ERROR${SGLUE_UNCOLOR}"

  if [[ ${#} -lt 1 ]]; then
    printf '%s\n' "${TITLE}" 1>&2
    exit 9
  fi

  printf '%s\n' "${TITLE} ${1}" 1>&2
  shift

  if [[ ${#} -lt 1 ]]; then
    exit 9
  fi

  local line

  for line in "${@}"; do
    printf '%s\n' "${line}" 1>&2
  done

  exit 9
}
declare -f -r sglue_int_err

############################################################
# @func sglue_is_dir
# @use sglue_is_dir [...OPTION] [...PATH]
# @opt -H|--no-sym-link
#   The PATH must **not** be a symbolic link to pass this
#   test.
# @opt -h|--sym-link
#   The PATH must be a symbolic link to pass this test.
# @opt -r|--readable
#   The PATH must be readable to pass this test.
# @opt -s|--strict
#   The PATH must **not** be a special relative directory
#   name to pass this test.
# @opt -x|--executable
#   The PATH must be executable to pass this test.
# @opt --
#   End the options.
# @val PATH
#   Should be a valid file system path.
# @return
#   0  PASS
#   1  FAIL
############################################################
sglue_is_dir()
{
  local -i H=0
  local -i h=0
  local -i r=0
  local -i s=0
  local -i x=0
  local path
  local opt

  if [[ ${#} -lt 1 ]]; then
    return 1
  fi

  for opt in "${@}"; do
    case "${opt}" in
      -H|--no-sym-link)
        H=1
        h=0
        ;;
      -h|--sym-link)
        H=0
        h=1
        ;;
      -r|--readable)
        r=1
        ;;
      -s|--strict)
        s=1
        ;;
      -x|--executable)
        x=1
        ;;
      --)
        shift
        break
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  if [[ ${#} -lt 1 ]]; then
    return 1
  fi

  for path in "${@}"; do
    if ! sglue_is_name "${path}" || [[ ! -d "${path}" ]]; then
      return 1
    fi
  done

  if [[ ${H} -eq 1 ]]; then
    for path in "${@}"; do
      if [[ -h "${path}" ]]; then
        return 1
      fi
    done
  fi

  if [[ ${h} -eq 1 ]]; then
    for path in "${@}"; do
      if [[ ! -h "${path}" ]]; then
        return 1
      fi
    done
  fi

  if [[ ${r} -eq 1 ]]; then
    for path in "${@}"; do
      if [[ ! -r "${path}" ]]; then
        return 1
      fi
    done
  fi

  if [[ ${s} -eq 1 ]]; then
    for path in "${@}"; do
      if sglue_is_rel_dir "${path}"; then
        return 1
      fi
    done
  fi

  if [[ ${x} -eq 1 ]]; then
    for path in "${@}"; do
      if [[ ! -x "${path}" ]]; then
        return 1
      fi
    done
  fi

  return 0
}
declare -f -r sglue_is_dir

############################################################
# @func sglue_is_file
# @use sglue_is_file  [...OPTION] [...PATH]
# @opt -H|--no-sym-link
#   The PATH must **not** be a symbolic link to pass this
#   test.
# @opt -h|--sym-link
#   The PATH must be a symbolic link to pass this test.
# @opt -r|--readable
#   The PATH must be readable to pass this test.
# @opt -x|--executable
#   The PATH must be executable to pass this test.
# @opt --
#   End the options.
# @val PATH
#   Should be a valid file system path.
# @return
#   0  PASS
#   1  FAIL
############################################################
sglue_is_file()
{
  local -i H=0
  local -i h=0
  local -i r=0
  local -i x=0
  local path
  local opt

  if [[ ${#} -lt 1 ]]; then
    return 1
  fi

  for opt in "${@}"; do
    case "${opt}" in
      -H|--no-sym-link)
        H=1
        h=0
        ;;
      -h|--sym-link)
        H=0
        h=1
        ;;
      -r|--readable)
        r=1
        ;;
      -x|--executable)
        x=1
        ;;
      --)
        shift
        break
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  if [[ ${#} -lt 1 ]]; then
    return 1
  fi

  for path in "${@}"; do
    if ! sglue_is_name "${path}" || [[ ! -f "${path}" ]]; then
      return 1
    fi
  done

  if [[ ${H} -eq 1 ]]; then
    for path in "${@}"; do
      if [[ -h "${path}" ]]; then
        return 1
      fi
    done
  fi

  if [[ ${h} -eq 1 ]]; then
    for path in "${@}"; do
      if [[ ! -h "${path}" ]]; then
        return 1
      fi
    done
  fi

  if [[ ${r} -eq 1 ]]; then
    for path in "${@}"; do
      if [[ ! -r "${path}" ]]; then
        return 1
      fi
    done
  fi

  if [[ ${x} -eq 1 ]]; then
    for path in "${@}"; do
      if [[ ! -x "${path}" ]]; then
        return 1
      fi
    done
  fi

  return 0
}
declare -f -r sglue_is_file

############################################################
# @func sglue_is_name
# @use sglue_is_name PATH
# @val PATH  Should be a valid file system path.
# @return
#   0  PASS
#   1  FAIL
############################################################
sglue_is_name()
{
  local name

  name="${1%/}"
  name="${name##*/}"

  if [[ -n "${name}" ]] \
     && [[ "${name}" != '*' ]] \
     && [[ "${name}" != '.*' ]]
  then
    return 0
  fi
  return 1
}
declare -f -r sglue_is_name

############################################################
# @func sglue_is_path
# @use sglue_is_path [...OPTION] [...PATH]
# @opt -d|--dir|--directory
#   The PATH must be to a directory to pass this test.
# @opt -f|--file
#   The PATH must be to a file to pass this test.
# @opt -H|--no-sym-link
#   The PATH must **not** be a symbolic link to pass this
#   test.
# @opt -h|--sym-link
#   The PATH must be a symbolic link to pass this test.
# @opt -r|--readable
#   The PATH must be readable to pass this test.
# @opt -s|--strict
#   The PATH must **not** be a special relative directory
#   name to pass this test.
# @opt -x|--executable
#   The PATH must be executable to pass this test.
# @opt --
#   End the options.
# @val PATH
#   Should be a valid file system path.
# @return
#   0  PASS
#   1  FAIL
############################################################
sglue_is_path()
{
  local -i d=0
  local -i f=0
  local -i H=0
  local -i h=0
  local -i r=0
  local -i s=0
  local -i x=0
  local path
  local opt

  if [[ ${#} -lt 1 ]]; then
    return 1
  fi

  for opt in "${@}"; do
    case "${opt}" in
      -d|--dir|--directory)
        d=1
        f=0
        ;;
      -f|--file)
        d=0
        f=1
        ;;
      -H|--no-sym-link)
        H=1
        h=0
        ;;
      -h|--sym-link)
        H=0
        h=1
        ;;
      -r|--readable)
        r=1
        ;;
      -s|--strict)
        s=1
        ;;
      -x|--executable)
        x=1
        ;;
      --)
        shift
        break
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  if [[ ${#} -lt 1 ]]; then
    return 1
  fi

  for path in "${@}"; do
    if ! sglue_is_name "${path}" || [[ ! -a "${path}" ]]; then
      return 1
    fi
  done

  if [[ ${d} -eq 1 ]]; then
    for path in "${@}"; do
      if [[ ! -d "${path}" ]]; then
        return 1
      fi
    done
  fi

  if [[ ${f} -eq 1 ]]; then
    for path in "${@}"; do
      if [[ ! -f "${path}" ]]; then
        return 1
      fi
    done
  fi

  if [[ ${H} -eq 1 ]]; then
    for path in "${@}"; do
      if [[ -h "${path}" ]]; then
        return 1
      fi
    done
  fi

  if [[ ${h} -eq 1 ]]; then
    for path in "${@}"; do
      if [[ ! -h "${path}" ]]; then
        return 1
      fi
    done
  fi

  if [[ ${r} -eq 1 ]]; then
    for path in "${@}"; do
      if [[ ! -r "${path}" ]]; then
        return 1
      fi
    done
  fi

  if [[ ${s} -eq 1 ]]; then
    for path in "${@}"; do
      if sglue_is_rel_dir "${path}"; then
        return 1
      fi
    done
  fi

  if [[ ${x} -eq 1 ]]; then
    for path in "${@}"; do
      if [[ ! -x "${path}" ]]; then
        return 1
      fi
    done
  fi

  return 0
}
declare -f -r sglue_is_path

############################################################
# @func sglue_is_rel_dir
# @use sglue_is_rel_dir PATH
# @val PATH  Should be a valid file system path.
# @return
#   0  PASS
#   1  FAIL
############################################################
sglue_is_rel_dir()
{
  local name

  if ! sglue_is_name "${1}"; then
    return 1
  fi

  name="${1%/}"
  name="${name##*/}"

  if [[ "${name}" == '.'  ]] \
     || [[ "${name}" == '..' ]]
  then
    return 0
  fi
  return 1
}
declare -f -r sglue_is_rel_dir

############################################################
# @func sglue_mk_dir
# @use sglue_mk_dir [...OPTION] [...PATH]
# @opt -m|--mode=MODE
#   default = `0755'
#   Set the file mode for each PATH.
# @opt -p|--parents
#   Make parent directories as needed instead of throwing
#   an error.
# @opt --
#   End the options.
# @val PATH
#   Should be a valid file system path.
# @return
#   0  PASS
# @exit-on-error
#   9  INTERNAL_SUPERGLUE_TEST_ERROR
############################################################
sglue_mk_dir()
{
  if [[ ${#} -lt 1 ]]; then
    return 0
  fi

  local -i p=0
  local mode='0755'
  local opt

  for opt in "${@}"; do
    case "${opt}" in
      -m|--mode)
        shift
        mode="${1}"
        ;;
      --mode=*)
        mode="${opt#*=}"
        ;;
      -p|--parents)
        p=1
        ;;
      --)
        shift
        break
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  if [[ ${#} -lt 1 ]]; then
    return 0
  fi

  local -a opts=( -m "${mode}" )

  if [[ ${p} -eq 1 ]]; then
    opts+=( -p )
  fi

  local path

  for path in "${@}"; do
    if sglue_is_name "${path}" \
       && ! sglue_is_rel_dir "${path}" \
       && ! sglue_is_dir -- "${path}"
    then
      if ! "${SGLUE_MKDIR}" "${opts[@]}" -- "${path}" > "${SGLUE_NIL}"; then
        sglue_int_err \
          "a call to \`mkdir' made a non-zero exit" \
          "    full-failed-cmd:" \
          "        '${SGLUE_MKDIR}' ${opts[@]} -- '${path}'"
      fi
    fi
  done

  return 0
}
declare -f -r sglue_mk_dir

############################################################
# @func sglue_rm
# @use sglue_rm [...OPTION] [...PATH]
# @opt --
#   End the options.
# @val PATH
#   Should be a valid file system path.
# @return
#   0  PASS
# @exit-on-error
#   9  INTERNAL_SUPERGLUE_TEST_ERROR
############################################################
sglue_rm()
{
  if [[ ${#} -lt 1 ]]; then
    return 0
  fi

  local opt

  for opt in "${@}"; do
    case "${opt}" in
      --)
        shift
        break
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  if [[ ${#} -lt 1 ]]; then
    return 0
  fi

  local path

  for path in "${@}"; do
    if ! sglue_is_path -- "${path}"; then
      continue
    fi
    if ! "${SGLUE_RM}" -- "${path}" > "${SGLUE_NIL}"; then
      sglue_int_err \
        "a call to \`rm' made a non-zero exit" \
        "    full-failed-cmd:" \
        "        '${SGLUE_RM}' -- '${path}'"
    fi
  done

  return 0
}
declare -f -r sglue_rm

############################################################
# @func sglue_rm_dir
# @use sglue_rm_dir [...OPTION] [...PATH]
# @opt -r|--recursive
#   Recursively remove all sub-directories for each PATH.
# @opt --
#   End the options.
# @val PATH
#   Should be a valid file system path.
# @return
#   0  PASS
# @exit-on-error
#   9  INTERNAL_SUPERGLUE_TEST_ERROR
############################################################
sglue_rm_dir()
{
  if [[ ${#} -lt 1 ]]; then
    return 0
  fi

  local -i r=0
  local opt

  for opt in "${@}"; do
    case "${opt}" in
      -r|--recursive)
        r=1
        ;;
      --)
        shift
        break
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  if [[ ${#} -lt 1 ]]; then
    return 0
  fi

  local path
  local child

  for path in "${@}"; do
    if ! sglue_is_path -- "${path}"; then
      continue
    fi
    if ! sglue_is_dir -- "${path}"; then
      sglue_int_err \
        "a non-directory path was passed to \`sglue_rm_dir'" \
        "    invalid-path: \`${path}'"
    fi
    if [[ ${r} -eq 1 ]]; then
      while IFS= read -r child; do
        if [[ -n "${child}" ]]; then
          sglue_rm_dir -r -- "${child}"
        fi
      done <<< "$(sglue_get_paths -d -s -- "${path}")"
    fi
    sglue_rm -- "${path}"
  done

  return 0
}
declare -f -r sglue_rm_dir

