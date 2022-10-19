#PBS -l walltime=2:00:00
#PBS -l ncpus=8
#PBS -l mem=16GB
#PBS -l jobfs=16GB
#PBS -l software=intel-compiler
#PBS -l wd
#PBS -l storage=gdata/tm70

# set WORKDIR
WORKDIR=
# download the esmf release from https://github.com/esmf-org/esmf/releases/tag/v8.3.0 into WORKDIR

module load intel-compiler intel-mkl netcdf intel-mpi
export ESMF_DIR=$WORKDIR/esmf-8.3.0
export ESMF_BOPT=g
export ESMF_COMM=intelmpi
export ESMF_COMPILER=intel
export ESMF_ABI=x86_64_medium
export ESMF_NETCDF=split
export ESMF_LAPACK=mkl
export ESMF_PIO=internal
export ESMF_LAPACK_LIBS=-mkl
export ESMF_NETCDF_INCLUDE=$NETCDF_BASE/include
export ESMF_NETCDF_LIBPATH=$NETCDF_BASE/lib

cd $WORKDIR/esmf-8.3.0
gmake -j 8

