#!/bin/bash

#PBS -l ncpus=48
#PBS -l mem=192GB
#PBS -q normal
#PBS -P tm70
#PBS -l walltime=03:00:00
#PBS -l storage=gdata/tm70+gdata/xp65+scratch/tm70+gdata/zv30
#PBS -l wd

module use /g/data/xp65/public/modules
module load conda/analysis3

EXPT_DIR=          # cylc run directory for experiment to be archived
ARCHIVE_DIR=       # Directory for writing the archived data
#startyear=

echo "Year $YEAR"

python cleanup_output.py -y $YEAR -e $EXPT_DIR -a $ARCHIVE_DIR