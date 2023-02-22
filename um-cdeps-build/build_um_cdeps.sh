bld_dir=/scratch/tm70/$USER/cime/scratch/atest/bld
nuopc_dir=$bld_dir/intel/openmpi/nodebug/nothreads/nuopc
cdeps_dir=$nuopc_dir/CDEPS

flags="-I. -I$nuopc_dir/include -I$nuopc_dir/nuopc/esmf/c1a1i1o1r1/include -I$nuopc_dir/finclude -I/apps/netcdf/4.7.3/include -I$nuopc_dir/include -I. -I/g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator -I/g/data/tm70/$USER/CESM/components/cmeps/cime_config/../cesm/flux_atmocn -I/g/data/tm70/$USER/CESM/components/cmeps/cime_config/../cesm/driver -I$bld_dir/lib/include -qno-opt-dynamic-align  -convert big_endian -assume byterecl -ftz -traceback -assume realloc_lhs -fp-model source -O2 -debug minimal -I/scratch/tm70/mrd599/esmf-8.3.0/mod/modg/Linux.intel.x86_64_medium.openmpi.default -I/scratch/tm70/mrd599/esmf-8.3.0/src/include -I/apps/netcdf/4.7.3/include  -DLINUX  -DCESMCOUPLED -DFORTRANUNDERSCORE -DCPRINTEL -DNDEBUG -DUSE_ESMF_LIB -DHAVE_MPI -DNUOPC_INTERFACE -DPIO2 -DHAVE_SLASHPROC -DESMF_VERSION_MAJOR=8 -DESMF_VERSION_MINOR=3 -DATM_PRESENT -DICE_PRESENT -DOCN_PRESENT -DROF_PRESENT -DMED_PRESENT -DPIO2 -free -DUSE_CONTIGUOUS=" # /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../cesm/driver/esm_time_mod.F90

mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../cesm/driver/esm_time_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_kind_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../cesm/flux_atmocn/shr_flux_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../cesm/driver/t_driver_timers_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../cesm/driver/util.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_constants_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_utils_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_methods_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_internalstate_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/esmFlds.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_time_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_io_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_phases_ocnalb_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_diag_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_phases_profile_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/esmFldsExchange_nems_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_map_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/esmFldsExchange_cesm_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_merge_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/esmFldsExchange_hafs_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_phases_history_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_phases_prep_ice_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_phases_prep_lnd_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_phases_prep_rof_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_fraction_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_phases_prep_wav_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_phases_post_rof_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_phases_prep_glc_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_phases_post_glc_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_phases_post_atm_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_phases_aofluxes_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_phases_post_wav_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_phases_post_ice_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_phases_post_lnd_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_phases_restart_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_phases_post_ocn_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_phases_prep_atm_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med_phases_prep_ocn_mod.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../mediator/med.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../cesm/driver/esm.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../cesm/driver/ensemble_driver.F90
mpif90 -c $flags /g/data/tm70/$USER/CESM/components/cmeps/cime_config/../cesm/driver/esmApp.F90

object_files=""
for file in /home/547/kr4383/cylc-run/u-cq576/share/fcm_make/build-atmos/o/*; do
  object_files="${object_files} ${file}"
done

ar -r libum.a $object_files

object_files="ensemble_driver.o esm.o esmApp.o esmFlds.o esmFldsExchange_cesm_mod.o esmFldsExchange_hafs_mod.o esmFldsExchange_nems_mod.o esm_time_mod.o med.o med_constants_mod.o med_diag_mod.o med_fraction_mod.o med_internalstate_mod.o med_io_mod.o med_kind_mod.o med_map_mod.o med_merge_mod.o med_methods_mod.o med_phases_aofluxes_mod.o med_phases_history_mod.o med_phases_ocnalb_mod.o med_phases_post_atm_mod.o med_phases_post_glc_mod.o med_phases_post_ice_mod.o med_phases_post_lnd_mod.o med_phases_post_ocn_mod.o med_phases_post_rof_mod.o med_phases_post_wav_mod.o med_phases_prep_atm_mod.o med_phases_prep_glc_mod.o med_phases_prep_ice_mod.o med_phases_prep_lnd_mod.o med_phases_prep_ocn_mod.o med_phases_prep_rof_mod.o med_phases_prep_wav_mod.o med_phases_profile_mod.o med_phases_restart_mod.o med_time_mod.o med_utils_mod.o shr_flux_mod.o t_driver_timers_mod.o util.o"
mpif90 -o ./cesm.exe $object_files libum.a -I/home/547/kr4383/cylc-run/u-cq576/share/fcm_make/build-atmos/include -L/scratch/tm70/kr4383/cime/scratch/atest/bld/lib/  -lice   -locn   -lrof -L$cdeps_dir/dshr -ldshr -L$cdeps_dir/streams -lstreams -L$nuopc_dir/nuopc/esmf/c1a1i1o1r1/lib -lcsm_share -L$nuopc_dir/lib -lpiof -lpioc -lgptl -lmct -lmpeu   -mkl=cluster -mkl=cluster -lnetcdf -lnetcdff -lmkl_intel_lp64 -lmkl_core -lmkl_intel_thread -liomp5 -lm -L$cdeps_dir/fox/lib -lFoX_dom -lFoX_sax -lFoX_utils -lFoX_fsys -lFoX_wxml -lFoX_common -lFoX_fsys -L/scratch/tm70/mrd599/esmf-8.3.0/lib/libg/Linux.intel.x86_64_medium.openmpi.default -Wl,-rpath,/scratch/tm70/mrd599/esmf-8.3.0/lib/libg/Linux.intel.x86_64_medium.openmpi.default -lesmf  -lmpi_cxx -cxxlib -lrt -ldl -mkl -lnetcdff -lnetcdf -lpioc -L/scratch/tm70/mrd599/esmf-8.3.0/lib/libg/Linux.intel.x86_64_medium.openmpi.default -L/apps/netcdf/4.7.3/lib
