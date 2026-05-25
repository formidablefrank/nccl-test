#!/bin/bash

#SBATCH --job-name=cuda-aware-bcast
#SBATCH --hint=nomultithread
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --gres=gpu:4
#SBATCH --mem=120000MB
#SBATCH --exclusive
#SBATCH --mem-bind=local
#SBATCH --distribution=block:block
#SBATCH --account=ICT26_MHPC_0
#SBATCH --partition=boost_usr_prod
#SBATCH --qos=boost_qos_dbg
#SBATCH --output=logs/cuda-aware-bcast-%j.out
#SBATCH --error=logs/cuda-aware-bcast-%j.err

set -euo pipefail

repo_root="${SLURM_SUBMIT_DIR:-$(pwd)}"
cd "${repo_root}"

mkdir -p logs
source "${repo_root}/spack-env.sh"

nvcc -O2 cuda_aware_bcast_pnetcdf.c -o cuda_aware_bcast_pnetcdf.x \
  -I"${HPCX_MPI_HOME}/include" \
  -L"${HPCX_MPI_HOME}/lib" \
  -lmpi -lpnetcdf

output_file="${1:-cuda_aware_bcast.nc}"
world_size="$((SLURM_NNODES * SLURM_NTASKS_PER_NODE))"

export OMPI_MCA_coll="^ucc"

mpirun -np "${world_size}" \
  "${repo_root}/binder.sh" \
  "${repo_root}/cuda_aware_bcast_pnetcdf.x" \
  "${output_file}"
