### Script for archiving CM3 output

This script archives CM3 output from a cylc run directory, and rearanges the
the history and restart files into the following structure:

```
├── archive
│   └── 1981
│       ├── atmosphere
│       │   ├── atmosa.pa-198101-dai.nc
...
│       │   └── atmosa.pm-198112-mon.nc
│       ├── ice
│       │   ├── access-cm3.cice.1day.mean.1981-01-01.nc
│       │   ├── access-cm3.cice.1day.mean.1981-01-02.nc
...
│       │   ├── access-cm3.cice.1mon.mean.1981-11.nc
│       │   └── access-cm3.cice.1mon.mean.1981-12.nc
│       └── ocean
│           ├── access-cm3.mom6.2d.evs.1mon.mean.1981.nc
│           ├── access-cm3.mom6.2d.ficeberg.1mon.mean.1981.nc
│           ├── access-cm3.mom6.2d.friver.1mon.mean.1981.nc
...
└── restart
    └── 1981
        ├── atmosphere
        │   └── atmosa.da19820101_00
        ├── coupler
        │   └── access-cm3.cpl.r.1982-01-01-00000.nc
        ├── ice
        │   └── access-cm3.cice.r.1982-01-01-00000.nc
        └── ocean
            └── access-cm3.mom6.r.1982-01-01-00000.nc
```

The following modifications are made to the history files:
- The `calendar` attribute is reset to `proleptic_gregorian` for the CICE and MOM output.
- MOM output is concatenated into yearly files, and split into separate files for each variable. 1D variables
are combined into a single file.


### Usage:
The input and output paths are set via the following options in the `archive_run.sh` qsub script:
```bash
EXPT_DIR=           # cylc run directory for experiment to be archived
ARCHIVE_DIR=        # Directory for writing the archived data
startyear=1981      # First year to archive
endyear=1981        # Last year to archive
```

Note that the script will fail on incomplete years of output. 

By default, coupler history files `access-cm3.cpl.h.*.nc` are not archived. These can also be archived
by adding the flag `--cpl` to the line
```
python cleanup_output.py -y $year -e $EXPT_DIR -a $ARCHIVE_DIR
``` 
in `archive-run.sh`.
