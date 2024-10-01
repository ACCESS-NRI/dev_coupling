# dev_coupling

Development space for documenting code and issues related to coupling

## CM3 instructions

### Install OM3 components

Clone `access-om3`, switch to the `cm3` branch, and clone the submodules:
```
git clone https://github.com/COSIMA/access-om3.git
cd access-om3
git checkout cm3
git submodule update --init --recursive
```

Point the CMEPS, CICE, and Icepack submodules to the ACCESS-NRI forks (enables you to push/pull latest changes):
```
cd CMEPS/CMEPS
git remote set-url origin https://github.com/ACCESS-NRI/CMEPS.git
git fetch
git checkout access-cmeps-0.14.35
cd ../../CICE/CICE/
git remote set-url origin https://github.com/ACCESS-NRI/CICE.git
git fetch
git checkout cice-export
cd icepack
git remote set-url origin https://github.com/ACCESS-NRI/Icepack.git
git fetch
git checkout cm3-coupling
```

Build!
```
bash build.sh
```


### Clone UM source and suite
```
git clone git@github.com:ACCESS-NRI/cm3-um.git
git clone git@github.com:ACCESS-NRI/cm3-suite.git
```
In `cm3-suite/bin/build.sh` set `OM3_DIR` to the location of your `access-om3` repo.
In `cm3-suite/app/fcm_make/rose-app.conf` set `um_sources` to the location of your `cm3-um` repo.

### Setup persistent sessions (if not already done)

Follow instructions here: https://access-hive.org.au/models/run-a-model/run-access-cm/#set-up-access-cm-persistent-session

### Run the model!

```
module use /g/data/hr22/modulefiles
module load cylc7/23.09
rose suite-run --name RUN_NAME
```

