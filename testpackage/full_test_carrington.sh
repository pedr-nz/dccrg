#!/bin/bash
#SBATCH -t 12:45:00        # Run time (hh:mm:ss)
#SBATCH --constraint="amd"
#SBATCH --nodes=1
#SBATCH -c 4                 # CPU cores per task
#SBATCH -n 8                  # number of tasks
#SBATCH --mem-per-cpu=8G
#SBATCH --hint=multithread

cd ~

module purge
module load GCC/13.2.0
module load OpenMPI/4.1.6-GCC-13.2.0
module load PMIx/4.2.6-GCCcore-13.2.0
module load PAPI/7.1.0-GCCcore-13.2.0
module load Boost/1.83.0-GCC-13.2.0
export UCX_TLS=dc_mlx5
#export UCX_TLS=rc,sm
export UCX_NET_DEVICES=mlx5_0:1

export OMPI_MCA_btl='^uct,ofi'
export OMPI_MCA_pml='ucx'
export OMPI_MCA_mtl='^ofi'
#Carrington has 2 x 16 cores per node, plus hyperthreading
ht=2
t=$SLURM_CPUS_PER_TASK
export OMP_NUM_THREADS=$t

umask 007
# Launch the OpenMP job to the allocated compute node
echo "Running $exec on $SLURM_NTASKS mpi tasks, with $t threads per task on $SLURM_NNODES nodes ($ht threads per physical core)"

# Optional debug printouts
# srun -np 1 /appl/bin/hostinfo
# srun --cpu-bind=cores bash -c 'echo -n "task $SLURM_PROCID (node $SLURM_NODEID): "; taskset -cp $$' | sort
# srun --mpi=pmix --cpu-bind=cores xthi

# Run tests
cd ~/ndccrg/$1
export DCCRG_ARCH=carrington_gcc_openmpi
export ASAN_OPTIONS=detect_leaks=0
make -j 16 # some executables should be check if they compiles
make test -j 16
#ASAN_OPTIONS=detect_leaks=0 make tests/get_cells/test1.tstN
wait
