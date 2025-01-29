import xarray as xr
import os
import numpy as np
from matplotlib import pyplot as plt
import esmpy
import iris

# parameters
nlon = 192
nlat = 144
r_max = 500
e_fold = 1_000

# get runoff points from a suite
# choose point ~1yr from start of run to ensure all river outflow points are active
SUITE_DIR = "cm3-run-21-01-2025-control"
DATA_DIR = f'/scratch/tm70/kr4383/cylc-run/{SUITE_DIR}/work'

year = 1981
month = 12
day = 25

month_str = str(month).zfill(2)
day_str = str(day).zfill(2)

fn = f"access-cm3.cpl.ha.atm.{year}-{month_str}-{day_str}-00000.nc"
fp = os.path.join(DATA_DIR, f"{year}{month_str}01/atmos", fn)
ds_atm_flat = xr.open_dataset(fp)
runoff = ds_atm_flat.atmImp_Foxx_rofl.compute()

river_outflow_mask_mask = (runoff.data.ravel() > 0)

# get ocean fracs and mask
# land_frac_fn = '/g/data/vk83/prerelease/configurations/inputs/access-cm3/ancil/n96e_momO1_20201102/qrparm.landfrac'
land_frac_fn = '/g/data/tm70/kr4383/qrparm.landfrac'

land_frac = iris.load_cube(land_frac_fn).data
ocn_frac = 1.0 - land_frac
ocn_mask = (ocn_frac > 0).ravel()


# create UM mesh
def create_um_mesh(nlon, nlat):

  num_elements = nlon * nlat

  element_ids = np.arange(1, num_elements + 1)
  element_types = np.array([
      esmpy.MeshElemType.TRI] * nlon + [esmpy.MeshElemType.QUAD] * ((nlat - 2) * nlon) + [esmpy.MeshElemType.TRI] * nlon
                          )
  element_lon = np.zeros(num_elements)
  element_lon[:] = ((element_ids - 1) % nlon + 0.5) * (360 / nlon) 

  element_lat = np.zeros(num_elements)
  element_lat[:] = ((element_ids - 1) // nlon + 0.5) * (180 / nlat)  - 90

  element_coords = np.zeros((num_elements, 2))
  element_coords[:, 0] = element_lon
  element_coords[:, 1] = element_lat

  dx = 360 / nlon
  dy = 180 / nlat
  pi_over_180 = np.pi / 180
  element_areas = dx * pi_over_180 * (
      np.sin((element_lat + 0.5 * dy) * pi_over_180) - np.sin((element_lat - 0.5 * dy) * pi_over_180)
  ) * ocn_frac.ravel()

  num_nodes = nlon * (nlat - 1) + 2
  node_ids = np.arange(1, num_nodes + 1)

  node_lon = np.zeros(num_nodes)
  node_lon[0] = 0.0
  node_lon[-1] = 0.0
  node_lon[1:-1] = element_lon[:-nlon] - 0.5 * (360 / nlon) 

  node_lat = np.zeros(num_nodes)
  node_lat[0] = -90.0
  node_lat[-1] = 90.0
  node_lat[1:-1] = element_lat[:-nlon] + 0.5 * (180 / nlat) 

  node_coords = np.zeros((num_nodes, 2))
  node_coords[:, 0] = node_lon
  node_coords[:, 1] = node_lat

  element_conn = []

  iy = 0
  for ix in range(nlon):
      south_pole = 1
      north_west = iy * nlon + 2 + ix
      north_east = iy * nlon + 2 + (ix + 1) % nlon
      conn = [north_west, south_pole, north_east]
      
      element_conn.extend(conn)

  for iy in range(1, nlat - 1):
      for ix in range(nlon):
          north_west = iy * nlon + 2 + ix
          north_east = iy * nlon + 2 + (ix + 1) % nlon
          
          south_west = (iy - 1) * nlon + 2 + ix
          south_east = (iy - 1) * nlon + 2 + (ix + 1) % nlon
          
          conn = [north_west, south_west, south_east, north_east]
          element_conn.extend(conn)

  iy = nlat - 1
  for ix in range(nlon):
      north_pole = num_nodes
      south_west = (iy - 1) * nlon + 2 + ix
      south_east = (iy - 1) * nlon + 2 + (ix + 1) % nlon
      conn = [north_pole, south_west, south_east]
      
      element_conn.extend(conn)      

  element_conn = np.array(element_conn) - 1
  len(element_conn), sum(element_types)

  um_mesh = esmpy.Mesh(parametric_dim=2, spatial_dim=2)
  um_mesh.add_nodes(num_nodes, node_ids, node_coords.ravel(), node_owners=np.zeros(num_nodes))
  um_mesh.add_elements(num_elements, element_ids, element_types, element_conn, element_coords=element_coords)

  return um_mesh, element_areas, element_lon, element_lat


def great_circle_distance(point1, point2):

    lon1, lat1 = point1
    lon2, lat2 = point2

    deg2rad = np.pi / 180.0
    
    lat1 = lat1 * deg2rad
    lat2 = lat2 * deg2rad
    
    lon1 = lon1 * deg2rad
    lon2 = lon2 * deg2rad

    radius = 6_378 # radius of earth in km

    tmp = np.sin(lat1) * np.sin(lat2) + np.cos(lat1) * np.cos(lat2) * np.cos(lon1 - lon2)
    tmp = np.clip(tmp, a_min=-1.0, a_max=1.0)

    return radius * np.arccos(tmp)


um_mesh, element_areas, element_lon, element_lat = create_um_mesh(nlon=nlon, nlat=nlat)

# create mapping weights
mapping_weights = []
destination_points = []
source_points = []

for src_point in np.where(river_outflow_mask_mask)[0]:

    dist = great_circle_distance((element_lon[src_point], element_lat[src_point]), (element_lon, element_lat))
    
    dest_mask = (dist < r_max) & ocn_mask
    
    weights = np.exp(-dist[dest_mask] / e_fold)
    weights *= element_areas[src_point] / (weights * element_areas[dest_mask]).sum()

    mapping_weights.extend(weights)
    destination_points.extend(np.where(dest_mask)[0] + 1)
    source_points.extend([src_point + 1] * len(weights))

mapping_ds = xr.Dataset(data_vars={'S': ('n_s', mapping_weights), 'col': ('n_s', source_points), 
                                   'row': ('n_s', destination_points)})

mapping_ds.to_netcdf('runoff_smoothing_weights.nc')