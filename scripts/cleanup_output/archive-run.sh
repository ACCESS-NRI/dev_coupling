#!/bin/bash

#PBS -l ncpus=8
#PBS -l mem=20GB
#PBS -q normal
#PBS -P tm70
#PBS -l walltime=03:00:00
#PBS -l storage=gdata/tm70+gdata/hh5+scratch/tm70+gdata/zv30
#PBS -l wd

module use /g/data/hh5/public/modules
module load conda/analysis3

EXPT_DIR=/scratch/tm70/kr4383/cylc-run/cm3-run-29-01-2025-exp-runoff-smoothing-rmax-500-efold-1000
ARCHIVE_DIR=/g/data/zv30/non-cmip/ACCESS-CM3/cm3-run-29-01-2025-exp-runoff-smoothing-rmax-500-efold-1000

for year in {1981..2001}
do
echo "Year: $year"
python cleanup_output.py -y $year -e $EXPT_DIR -a $ARCHIVE_DIR
done
