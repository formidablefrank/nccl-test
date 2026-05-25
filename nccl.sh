#!/bin/bash

mod_path="/leonardo/prod/spack/5.2/install/0.21/linux-rhel8-icelake/gcc-8.5.0/nvhpc-24.3-v63z4inohb4ywjeggzhlhiuvuoejr2le/Linux_x86_64/24.3/"
module load /leonardo/prod/spack/5.2/install/0.21/linux-rhel8-icelake/gcc-8.5.0/nvhpc-24.3-v63z4inohb4ywjeggzhlhiuvuoejr2le/modulefiles/nvhpc-hpcx-cuda12/24.3

export LD_LIBRARY_PATH=${mod_path}comm_libs/nccl/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=${mod_path}comm_libs/nccl/lib:$LD_LIBRARY_PATH
export CPATH=${mod_path}comm_libs/nccl/include:$CPATH

module list