#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${repo_root}"

source "${repo_root}/spack-env.sh"

nvcc -O2 cuda_aware_bcast_pnetcdf.c -o cuda_aware_bcast_pnetcdf.x \
  -I"${HPCX_MPI_HOME}/include" \
  -L"${HPCX_MPI_HOME}/lib" \
  -lmpi -lpnetcdf
