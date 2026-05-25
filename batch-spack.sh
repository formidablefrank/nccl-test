#!/bin/bash

#SBATCH --job-name=nccl-spack
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
#SBATCH --output=logs/slurm-spack-%j.out
#SBATCH --error=logs/slurm-spack-%j.err

set -euo pipefail

repo_root="${SLURM_SUBMIT_DIR:-$(pwd)}"
cd "${repo_root}"

source "${repo_root}/spack-env.sh"

mkdir -p logs

nvcc -O2 allreduce.c -o allreduce.x \
  -I"${HPCX_MPI_HOME}/include" \
  -I"${NCCL_HOME}/include" \
  -L"${HPCX_MPI_HOME}/lib" \
  -L"${NCCL_HOME}/lib" \
  -lmpi -lnccl

export NCCL_DEBUG=INFO
export NCCL_DEBUG_SUBSYS=ALL
export NCCL_DEBUG_FILENAME="logs/IB_4_${SLURM_LOCALID}.log"
export NCCL_TOPO_DUMP_FILE=topo_leo.xml

message_size="${1:-50000000}"
world_size="$((SLURM_NNODES * SLURM_NTASKS_PER_NODE))"

mpirun -np "${world_size}" ./binder.sh ./allreduce.x "${message_size}"
