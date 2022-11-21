#!/usr/bin/env bash

esmf_dir=/scratch/tm70/mrd599/esmf-8.3.0

cesm_dir=/g/data/tm70/ds0092/CESM
cmeps_dir=$cesm_dir/components/cmeps

A_bld_dir=/scratch/tm70/ds0092/cime/scratch/A/bld
A_nuopc_bld_dir=$A_bld_dir/intel/openmpi/nodebug/nothreads/nuopc

GMOM_JRA_bld_dir=/scratch/tm70/ds0092/cime/scratch/GMOM_JRA/bld

. /etc/profile.d/modules.sh
module purge
module load openmpi intel-compiler intel-mkl netcdf pnetcdf python3-as-python
export NETCDF_PATH=/apps/netcdf/4.7.3
export PKG_CONFIG_PATH=/apps/netcdf/4.7.3/lib/pkgconfig:/apps/intel-ct/2022.1.0/mkl/lib/pkgconfig:/half-root/usr/lib64/pkgconfig:/apps/netcdf/4.7.3/lib/Intel/pkgconfig:/apps/netcdf/4.7.3/lib/Intel/pkgconfig
export ESMFMKFILE=$esmf_dir/lib/libg/Linux.intel.x86_64_medium.openmpi.default/esmf.mk

## Compile CMEPS source
# flags="-I. -I$A_nuopc_bld_dir/CDEPS/fox/include -I$A_nuopc_bld_dir/CDEPS/dshr -I$A_nuopc_bld_dir/include -I$A_nuopc_bld_dir/nuopc/esmf/c1a1i1o1r1/include -I$A_nuopc_bld_dir/finclude -I/apps/netcdf/4.7.3/include -I$A_bld_dir/atm/obj -I$A_bld_dir/ice/obj -I$A_bld_dir/ocn/obj -I$A_bld_dir/glc/obj -I$A_bld_dir/rof/obj -I$A_bld_dir/wav/obj -I$A_bld_dir/esp/obj -I$A_bld_dir/iac/obj -I$A_nuopc_bld_dir/include -I$A_bld_dir/lnd/obj -I. -I$cesm_dir/cime/scripts/atest/SourceMods/src.drv -I$cmeps_dir/mediator -I$cmeps_dir/cesm/flux_atmocn -I$cmeps_dir/cmeps/cesm/driver -I$A_bld_dir/lib/include -qno-opt-dynamic-align  -convert big_endian -assume byterecl -ftz -traceback -assume realloc_lhs -fp-model source -O2 -debug minimal -I$esmf_dir/mod/modg/Linux.intel.x86_64_medium.openmpi.default -I$esmf_dir/src/include -I/apps/netcdf/4.7.3/include  -DLINUX  -DCESMCOUPLED -DFORTRANUNDERSCORE -DCPRINTEL -DNDEBUG -DUSE_ESMF_LIB -DHAVE_MPI -DNUOPC_INTERFACE -DPIO2 -DHAVE_SLASHPROC -DESMF_VERSION_MAJOR=8 -DESMF_VERSION_MINOR=3 -DATM_PRESENT -DICE_PRESENT -DOCN_PRESENT -DROF_PRESENT -DMED_PRESENT -DPIO2 -free -DUSE_CONTIGUOUS="

# cmeps_src_files=$(find $cmeps_dir/cesm/driver $cmeps_dir/cesm/flux_atmocn $cmeps_dir/mediator -name "*.F90")

# for file in $cmeps_src_files; do
#     mpif90 -c $flags $file

## Compile cesm executable
# for file in $cmeps_src_files; do 
#    bname=$(basename $file)
#    object_files="${object_files} ${bname%.F90}.o"
# done
object_files=$(find $A_bld_dir/cpl/obj/ -name "*.o")

mpif90 -o ./cesm.exe $object_files -L$A_bld_dir/lib/ -latm -lice -lrof -L$GMOM_JRA_bld_dir/lib/ -locn -L$A_nuopc_bld_dir/CDEPS/dshr -ldshr -L$A_nuopc_bld_dir/CDEPS/streams -lstreams -L$A_nuopc_bld_dir/nuopc/esmf/c1a1i1o1r1/lib -lcsm_share -L$A_nuopc_bld_dir/lib -lpiof -lpioc -lgptl -lmct -lmpeu -L$GMOM_JRA_nuopc_bld_dir/lib -lfms -mkl=cluster -mkl=cluster -lnetcdf -lnetcdff -lmkl_intel_lp64 -lmkl_core -lmkl_intel_thread -liomp5 -lm -L$A_nuopc_bld_dir/CDEPS/fox/lib -lFoX_dom -lFoX_sax -lFoX_utils -lFoX_fsys -lFoX_wxml -lFoX_common -lFoX_fsys -L$esmf_dir/lib/libg/Linux.intel.x86_64_medium.openmpi.default -Wl,-rpath,$esmf_dir/lib/libg/Linux.intel.x86_64_medium.openmpi.default -lesmf  -lmpi_cxx -cxxlib -lrt -ldl -mkl -lnetcdff -lnetcdf -lpioc -L$esmf_dir/lib/libg/Linux.intel.x86_64_medium.openmpi.default -L/apps/netcdf/4.7.3/lib
