#!/bin/bash

#PBS -l ncpus=8
#PBS -l mem=60GB
#PBS -q normal
#PBS -P tm70
#PBS -l walltime=03:00:00
#PBS -l storage=gdata/tm70+gdata/xp65+scratch/tm70+gdata/zv30
#PBS -l wd

module use /g/data/xp65/public/modules
module load conda/analysis3

EXPT_DIR=           # cylc run directory for experiment to be archived
ARCHIVE_DIR=        # Directory for writing the archived data
startyear=1981      # First year to archive
endyear=1981        # Last year to archive


for ((year=startyear;year<=endyear;year++)); do
echo "Year: $year"
python cleanup_output.py -y $year -e $EXPT_DIR -a $ARCHIVE_DIR
done
