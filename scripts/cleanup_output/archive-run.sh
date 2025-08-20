#!/bin/bash

#PBS -l ncpus=8
#PBS -l mem=60GB
#PBS -q normal
#PBS -P tm70
#PBS -l walltime=03:00:00
#PBS -l storage=gdata/tm70+gdata/hh5+scratch/tm70+gdata/zv30
#PBS -l wd

module use /g/data/hh5/public/modules
module load conda/analysis3

EXPT_DIR=
ARCHIVE_DIR=
startyear=1981
endyear=1981


for ((year=startyear;year<=endyear;year++)); do
echo "Year: $year"
python cleanup_output.py -y $year -e $EXPT_DIR -a $ARCHIVE_DIR
done
