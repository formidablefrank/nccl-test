#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

prepend_path() {
  local var_name="$1"
  local value="$2"

  if [[ -z "${value}" || ! -e "${value}" ]]; then
    return
  fi

  if [[ -n "${!var_name:-}" ]]; then
    export "${var_name}=${value}:${!var_name}"
  else
    export "${var_name}=${value}"
  fi
}

add_spack_prefix() {
  local spec="$1"
  local prefix

  if ! prefix="$(spack -e "${repo_root}" location -i "$spec" 2>/dev/null)"; then
    return
  fi

  prepend_path CMAKE_PREFIX_PATH "${prefix}"

  if [[ -d "${prefix}/include" ]]; then
    prepend_path CPATH "${prefix}/include"
    prepend_path C_INCLUDE_PATH "${prefix}/include"
    prepend_path CPLUS_INCLUDE_PATH "${prefix}/include"
  fi

  if [[ -d "${prefix}/lib" ]]; then
    prepend_path LIBRARY_PATH "${prefix}/lib"
    prepend_path LD_LIBRARY_PATH "${prefix}/lib"
    prepend_path PKG_CONFIG_PATH "${prefix}/lib/pkgconfig"
  fi

  if [[ -d "${prefix}/lib64" ]]; then
    prepend_path LIBRARY_PATH "${prefix}/lib64"
    prepend_path LD_LIBRARY_PATH "${prefix}/lib64"
    prepend_path PKG_CONFIG_PATH "${prefix}/lib64/pkgconfig"
  fi
}

set +u
module purge
module load spack/0.22-06
set -u
module load gcc/12.2.0
module load cuda/12.2
module load nvhpc/25.11
module load hpcx-mpi/2.25.1
module load nccl/2.22.3-1--gcc--12.2.0-cuda-12.2-spack0.22
module load cudnn/8.9.7.29-12--gcc--12.2.0-cuda-12.2

add_spack_prefix "hdf5@1.14.3 +mpi +fortran +hl %nvhpc@25.11 ^hpcx-mpi@2.25.1"
add_spack_prefix "parallel-netcdf@1.12.3 +cxx +fortran %nvhpc@25.11 ^hpcx-mpi@2.25.1"

export CUDAARCHS=80
export UCX_TLS="${UCX_TLS:-rc,cuda_copy,cuda_ipc,sm,self}"
