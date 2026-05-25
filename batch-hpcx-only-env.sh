#!/bin/bash

#SBATCH --job-name=nccl-hpcx-ext
#SBATCH --hint=nomultithread
#SBATCH --time=00:10:00
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=4
#SBATCH --gres=gpu:4
#SBATCH --mem=490000MB
#SBATCH --exclusive
#SBATCH --mem-bind=local
#SBATCH --distribution=block:block
#SBATCH --account=ICT26_MHPC_0
#SBATCH --partition=boost_usr_prod
#SBATCH --qos=boost_qos_dbg
#SBATCH --output=logs/slurm-hpcx-ext-%j.out
#SBATCH --error=logs/slurm-hpcx-ext-%j.err

set -euo pipefail

repo_root="${SLURM_SUBMIT_DIR:-$(pwd)}"
cd "${repo_root}"

mkdir -p logs
source "${repo_root}/hpcx-only-env.sh"

nvcc -O2 allreduce.c -o allreduce-hpcx-ext.x \
  -I"${HPCX_MPI_HOME}/include" \
  -I"${NCCL_HOME}/include" \
  -L"${HPCX_MPI_HOME}/lib" \
  -L"${NCCL_HOME}/lib" \
  -lmpi -lnccl

export NCCL_DEBUG=INFO
export NCCL_DEBUG_SUBSYS=ALL
export NCCL_DEBUG_FILENAME="logs/hpcx-ext-${SLURM_JOB_ID}-${SLURM_LOCALID}.log"
export NCCL_TOPO_DUMP_FILE="${repo_root}/topo_hpcx_ext.xml"

message_size="${1:-50000000}"
world_size="$((SLURM_NNODES * SLURM_NTASKS_PER_NODE))"

mpirun -np "${world_size}" \
  "${repo_root}/binder.sh" \
  "${repo_root}/allreduce-hpcx-ext.x" \
  "${message_size}"
