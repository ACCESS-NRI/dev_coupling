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

## Checkout and modify suite
```
rosie checkout u-db245
```
In `bin/build.sh` set `OM3_DIR` to the location of your `access-om3` repo.
