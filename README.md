# dev_coupling

Development space for documenting code and issues related to coupling

# dev_coupling

Development space for documenting code and issues related to coupling

## Spack CM3 instructions

### Setup persistent sessions (if not already done)

Follow instructions here: https://access-hive.org.au/models/run-a-model/run-access-cm/#set-up-access-cm-persistent-session

### Clone UM source and suite
```
git clone git@github.com:ACCESS-NRI/UM.git
cd UM
git checkout vn13.0_nuopc
cd ..
git clone git@github.com:ACCESS-NRI/access-cm3-configs.git
cd access3-configs
git checkout cm3_O100km
```
Or 
```
git checkout cm3_O25km
```
for the 25km ocean. 

In `cm3-suite/app/fcm_make/rose-app.conf` set `um_sources` and `config_root_path` to the location of your `UM` repo.

### Run the model!

From the `access-cm3-configs` directory run:

```
module use /g/data/hr22/modulefiles
module load cylc7/23.09
rose suite-run --name RUN_NAME
```

## Model cost

| Ocn resolution | Cost (kSU/yr) | Speed (SYPD) |
|----------------|---------------|--------------|
| 25km           | 30            | 3            |
| 100km          | 8             | 6            |
