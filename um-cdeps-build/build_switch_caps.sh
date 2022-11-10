#!/usr/bin/env bash

esmf_dir=/scratch/tm70/mrd599/esmf-8.3.0
A_blddir=/scratch/tm70/ds0092/cime/scratch/A/bld
GMOM_JRA_blddir=/scratch/tm70/ds0092/cime/scratch/GMOM_JRA/bld
nuopc_dir=$A_blddir/intel/openmpi/nodebug/nothreads/nuopc
cdeps_dir=$nuopc_dir/CDEPS

. /etc/profile.d/modules.sh
module purge
module load openmpi intel-compiler intel-mkl netcdf pnetcdf python3-as-python
export NETCDF_PATH=/apps/netcdf/4.7.3
export PKG_CONFIG_PATH=/apps/netcdf/4.7.3/lib/pkgconfig:/apps/intel-ct/2022.1.0/mkl/lib/pkgconfig:/half-root/usr/lib64/pkgconfig:/apps/netcdf/4.7.3/lib/Intel/pkgconfig:/apps/netcdf/4.7.3/lib/Intel/pkgconfig
export ESMFMKFILE=$esmf_dir/lib/libg/Linux.intel.x86_64_medium.openmpi.default/esmf.mk


object_files=$(find $A_blddir/cpl/obj/ -name "*.o")

mpif90 -o ./cesm.exe $object_files -L$GMOM_JRA_blddir/lib/  -latm   -lfms   -lice   -locn   -lrof -L$cdeps_dir/dshr -ldshr -L$cdeps_dir/streams -lstreams -L$nuopc_dir/nuopc/esmf/c1a1i1o1r1/lib -lcsm_share -L$nuopc_dir/lib -lpiof -lpioc -lgptl -lmct -lmpeu   -mkl=cluster -mkl=cluster -lnetcdf -lnetcdff -lmkl_intel_lp64 -lmkl_core -lmkl_intel_thread -liomp5 -lm -L$cdeps_dir/fox/lib -lFoX_dom -lFoX_sax -lFoX_utils -lFoX_fsys -lFoX_wxml -lFoX_common -lFoX_fsys -L$esmf_dir/lib/libg/Linux.intel.x86_64_medium.openmpi.default -Wl,-rpath,$esmf_dir/lib/libg/Linux.intel.x86_64_medium.openmpi.default -lesmf  -lmpi_cxx -cxxlib -lrt -ldl -mkl -lnetcdff -lnetcdf -lpioc -L$esmf_dir/lib/libg/Linux.intel.x86_64_medium.openmpi.default -L/apps/netcdf/4.7.3/lib
