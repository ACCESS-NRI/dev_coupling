# dev_coupling

Development space for documenting code and issues related to coupling

## CM3 instructions

### Install OM3 components

```
git clone https://github.com/COSIMA/access-om3.git
cd access-om3
git checkout cm3
git submodule update --init --recursive
bash build.sh
```

To point the CMEPS, CICE, and Icepack submodules to the ACCESS-NRI forks (enables you to push/pull latest changes):

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
git remote set-url origin https://github.com/ACCESS-NRI/CICE.git](https://github.com/ACCESS-NRI/Icepack.git)
git fetch
git checkout cm3-coupling
```


## Checkout and modify suite
```
rosie checkout u-db245
```
In `bin/build.sh` set `OM3_DIR` to the location of your `access-om3` repo.
