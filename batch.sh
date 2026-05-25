#!/bin/bash

#SBATCH --hint=nomultithread
#SBATCH --time 00:10:00
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
#SBATCH --output=logs/slurm-%j.out
#SBATCH --error=logs/slurm-%j.err

module purge
source nccl.sh
export NCCL_DEBUG=INFO
export NVVL_DEBUG_SUBSYS=ALL
export NCCL_DEBUG_FILENAME="logs/IB_4_${SLURM_LOCALID}.log"
#export NCCL_NET="Socket"
#export NCCL_IB_SL=1
#export NCCL_IB_ADAPTIVE_ROUTING=0
#export UCX_RNDV_THRESH=8192
#export NCCL_P2P_LEVEL=NVL
#export NCCL_ALGO=Ring

export NCCL_TOPO_DUMP_FILE=topo_leo.xml

# nvcc allreduce.c -o allreduce.x -lmpi -lnccl
mpirun -np 16 ./binder.sh ./allreduce.x 50000000
# mpirun -np 16 nsys profile --stats=true --force-overwrite=true --output=nsys_4_${SLURM_LOCALID} \
#   --trace=cuda,nvtx,mpi,nccl \
#   --nic-metrics=true \
#   ./binder.sh \
#   ./allreduce.x \
#   50000000