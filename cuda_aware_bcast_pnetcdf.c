#include <stdio.h>
#include <stdlib.h>

#include <cuda_runtime.h>
#include <mpi.h>
#include <pnetcdf.h>

#define MPICHECK(cmd) do {                                                   \
  int e_ = (cmd);                                                            \
  if (e_ != MPI_SUCCESS) {                                                   \
    fprintf(stderr, "MPI error %s:%d code=%d\n", __FILE__, __LINE__, e_);    \
    MPI_Abort(MPI_COMM_WORLD, e_);                                           \
    exit(EXIT_FAILURE);                                                      \
  }                                                                          \
} while (0)

#define CUDACHECK(cmd) do {                                                  \
  cudaError_t e_ = (cmd);                                                    \
  if (e_ != cudaSuccess) {                                                   \
    fprintf(stderr, "CUDA error %s:%d %s\n", __FILE__, __LINE__,             \
            cudaGetErrorString(e_));                                         \
    MPI_Abort(MPI_COMM_WORLD, 1);                                            \
    exit(EXIT_FAILURE);                                                      \
  }                                                                          \
} while (0)

#define PNETCDFCHECK(cmd) do {                                               \
  int e_ = (cmd);                                                            \
  if (e_ != NC_NOERR) {                                                      \
    fprintf(stderr, "PnetCDF error %s:%d %s\n", __FILE__, __LINE__,          \
            ncmpi_strerror(e_));                                             \
    MPI_Abort(MPI_COMM_WORLD, e_);                                           \
    exit(EXIT_FAILURE);                                                      \
  }                                                                          \
} while (0)

int main(int argc, char **argv) {
  int rank = 0;
  int size = 0;
  int device_count = 0;
  int device = 0;
  int host_value = 0;
  int *device_value = NULL;
  int ncid = -1;
  int dimid = -1;
  int varid = -1;
  MPI_Offset start[1];
  MPI_Offset count[1];
  const char *output_path = "cuda_aware_bcast.nc";

  MPICHECK(MPI_Init(&argc, &argv));
  MPICHECK(MPI_Comm_rank(MPI_COMM_WORLD, &rank));
  MPICHECK(MPI_Comm_size(MPI_COMM_WORLD, &size));

  if (argc > 1) {
    output_path = argv[1];
  }

  CUDACHECK(cudaGetDeviceCount(&device_count));
  if (device_count <= 0) {
    fprintf(stderr, "No CUDA devices visible to rank %d\n", rank);
    MPICHECK(MPI_Abort(MPI_COMM_WORLD, 1));
  }

  device = rank % device_count;
  CUDACHECK(cudaSetDevice(device));
  CUDACHECK(cudaMalloc((void **) &device_value, sizeof(int)));

  if (rank == 0) {
    host_value = 1234;
  }
  CUDACHECK(cudaMemcpy(device_value, &host_value, sizeof(int),
                       cudaMemcpyHostToDevice));

  MPICHECK(MPI_Bcast(device_value, 1, MPI_INT, 0, MPI_COMM_WORLD));

  CUDACHECK(cudaMemcpy(&host_value, device_value, sizeof(int),
                       cudaMemcpyDeviceToHost));

  PNETCDFCHECK(ncmpi_create(MPI_COMM_WORLD, output_path,
                            NC_CLOBBER | NC_64BIT_DATA, MPI_INFO_NULL, &ncid));
  PNETCDFCHECK(ncmpi_def_dim(ncid, "rank", size, &dimid));
  PNETCDFCHECK(ncmpi_def_var(ncid, "broadcast_value", NC_INT, 1, &dimid,
                             &varid));
  PNETCDFCHECK(ncmpi_enddef(ncid));

  start[0] = rank;
  count[0] = 1;
  PNETCDFCHECK(
      ncmpi_put_vara_int_all(ncid, varid, start, count, &host_value));
  PNETCDFCHECK(ncmpi_close(ncid));

  printf("[Rank %d] GPU %d received value %d and wrote %s\n",
         rank, device, host_value, output_path);

  CUDACHECK(cudaFree(device_value));
  MPICHECK(MPI_Finalize());
  return 0;
}
