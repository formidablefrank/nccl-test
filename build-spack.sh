#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${repo_root}"

set +u
module load spack/0.22-06
set -u
spack -e "${repo_root}" concretize -f
spack -e "${repo_root}" install --fail-fast

source "${repo_root}/spack-env.sh"

mkdir -p logs

nvcc -O2 allreduce.c -o allreduce.x \
  -I"${HPCX_MPI_HOME}/include" \
  -I"${NCCL_HOME}/include" \
  -L"${HPCX_MPI_HOME}/lib" \
  -L"${NCCL_HOME}/lib" \
  -lmpi -lnccl
