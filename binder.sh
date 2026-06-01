#!/bin/bash
case $(( ${OMPI_COMM_WORLD_LOCAL_RANK} )) in
    0) export UCX_NET_DEVICES=mlx5_0:1 CUDA_VISIBLE_DEVICES=0 ;;
    1) export UCX_NET_DEVICES=mlx5_1:1 CUDA_VISIBLE_DEVICES=1 ;;
    2) export UCX_NET_DEVICES=mlx5_2:1 CUDA_VISIBLE_DEVICES=2 ;;
    3) export UCX_NET_DEVICES=mlx5_3:1 CUDA_VISIBLE_DEVICES=3 ;;
esac

echo Launching on ${UCX_NET_DEVICES}

$*