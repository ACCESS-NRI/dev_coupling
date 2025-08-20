#!/bin/usr/env python

import argparse
import cftime
import numpy as np
import os
import re
import shutil
import sys
import time


from pathlib import Path

import xarray as xr
from distributed import Client


FF_UNIT_SUFFIX = {
    "a": "dai",
    "d": "dai",
    "m": "mon"
}

MONTHS = {
    "jan": 1,
    "feb": 2,
    "mar": 3,
    "apr": 4,
    "may": 5,
    "jun": 6,
    "jul": 7,
    "aug": 8,
    "sep": 9,
    "oct": 10,
    "nov": 11,
    "dec": 12
}

MONTH_LENGTHS = [
    np.timedelta64(i, "D") for i in np.arange(28, 32)
]

ATMOSPHERE = "atmosphere"
OCEAN = "ocean"
ICE = "ice"
COUPLER = "coupler"
COMPONENTS_ALL = [ATMOSPHERE, OCEAN, ICE, COUPLER]

AUX_VARS = ["average_DT", "average_T1", "average_T2", "time_bnds"]


def to_proleptic(ds):
    """
    Convert non-decoded time dimension to proleptic gregorian calendar.
    Keeps the same "days/hours since .... " values, and sets the calendar to
    proleptic gregorian.

    Used for MOM and CICE output which erroneously use "gregorian" calendars.

    Parameters
    ----------
    ds: xarray dataset with non-decoded time dimension
    """
    # Check that time variable has not been decoded
    if ((not isinstance(ds["time"].data[0], float)) and (not isinstance(ds["time"].data[0], int))):
        raise TypeError(
            f"Dataset time data has type {type(ds['time'].data[0])}. Time data should not be decoded"
        )

    variables = [
        "time",
        "time_bounds",
        "time_bnds",
        "average_T1",
        "average_T2"
    ]

    vars_in_ds = []
    for var in variables:
        try:
            ds[var]
            vars_in_ds.append(var)
        except KeyError:
            continue

    for var in vars_in_ds:
        ds[var].attrs["calendar"] = "proleptic_gregorian"

    # Remove additional MOM attribute
    try:
        ds.time.attrs.pop("calendar_type")
    except KeyError:
        pass

    units = ds["time"].attrs["units"]
    for var in vars_in_ds:
        # Xarray complains if encoding and units for record variable both set,
        # even if they match.
        if var != "time":
            try:
                ds[var].attrs["units"]
            except KeyError:
                ds[var].attrs["units"] = units
    # decode using correct proleptic_gregorian attribute
    ds_proleptic = xr.decode_cf(ds,
                                use_cftime=True,
                                decode_timedelta=False)

    return ds_proleptic


def move_atmos(year, share_dir, atmosphere_archive_dir):
    pattern = rf"atmosa.p([a-z]){year}([a-z]{{3}}).nc"

    for file in os.listdir(share_dir):
        match = re.match(pattern, file)
        if match:
            stream = match.group(1)
            month = match.group(2)
            outfile = f"atmosa.p{stream}-{year:04d}{MONTHS[month]:02d}-{FF_UNIT_SUFFIX[stream]}.nc"
            shutil.copy2(share_dir / file, atmosphere_archive_dir / outfile)


def move_ocean(year, work_dirs, ocean_archive_dir):
    # Move static ocean file
    static_file = "access-cm3.mom6.h.static.nc"
    if not (ocean_archive_dir / static_file).is_file():
        shutil.copy2(work_dirs[0] / static_file, ocean_archive_dir / static_file)

    # Process non-statc files:
    # - Concatenate into years
    # - Separate non-1d vars into individual files
    # - 1D variables combined into single file
    file_patterns = {
        "native": rf"access-cm3\.mom6.h\.native_{year}_([0-9]{{2}})\.nc",
        "sfc": rf"access-cm3\.mom6\.h\.sfc_{year}_([0-9]{{2}})\.nc",
        "z": rf"access-cm3\.mom6\.h\.z_{year}_([0-9]{{2}})\.nc"
    }
    for output_type, pattern in file_patterns.items():
        matches = []
        for dir in work_dirs:
            for file in os.listdir(dir):
                if re.match(pattern, file):
                    filepath = dir / file
                    matches.append(filepath)

        # Sanity check
        if (matches != []) and (len(matches) != 12):
            raise FileNotFoundError(
                f"Only {len(matches)} file found for pattern {pattern}"
            )

        # Concatenate all files matching the current pattern
        working_file = xr.open_mfdataset(matches,
                                         decode_times=False,
                                         preprocess=to_proleptic)

        # File wide attributes
        frequency = frequency = get_frequency(working_file.time)
        data_years = working_file["time.year"]
        check_year(year, data_years)

        scalar_fields = []
        groups_to_save = []
        # Loop through variables in dataset, saving each one to file
        for var_name in working_file:
            if var_name in AUX_VARS:
                continue

            single_var_da = working_file[var_name]

            dim_label = get_ndims(single_var_da.dims)
            if output_type == "z":
                dim_label = f"{dim_label}_z"

            reduction_method = parse_cell_methods(
                single_var_da.attrs["cell_methods"]
            )["time"]

            # Handle scalar fields separately
            if is_scalar_var(single_var_da.dims):
                scalar_fields.append(var_name)
                continue

            file_name = set_ocn_file_name(dim_label,
                                          var_name,
                                          frequency,
                                          reduction_method,
                                          year)
            file_path = ocean_archive_dir / file_name
            single_var_ds = working_file[[var_name] + AUX_VARS]

            groups_to_save.append((single_var_ds, file_path))

        # Generate file name for scalar variables
        if scalar_fields:
            scalar_file_name = set_scalar_name(working_file, scalar_fields, frequency, year)
            scalar_ds = working_file[scalar_fields + AUX_VARS]
            groups_to_save.append((scalar_ds, ocean_archive_dir / scalar_file_name))

        # Save files in parallel
        datasets, filepaths = zip(*groups_to_save)
        for path in filepaths:
            check_exists(path)
        print("Saving ocean variables")
        xr.save_mfdataset(datasets, filepaths)


def is_scalar_var(dims):
    return ("scalar_axis" in dims)


def get_ndims(dims):
    non_time_dims = [dim for dim in dims
                     if dim != "time"]
    return f"{len(non_time_dims)}d"


def get_frequency(times):
    """
    Find whether variable frequency is daily or monthly
    """
    time_deltas = [(times[i+1] - times[i]).astype('timedelta64[D]') for i in range(len(times) - 1)]

    if all([delta in MONTH_LENGTHS for delta in time_deltas]):
        frequency = "1mon"
    elif all([delta == np.timedelta64(1,'D') for delta in time_deltas]):
        frequency = "1day"
    else:
        raise RuntimeError(
            f"Unable to extract frequency from times {times}"
        )
    return frequency


def check_year(year, da_years):
    if all([da_year == year for da_year in da_years]):
        return
    else:
        raise ValueError(
            f"Data years {da_years} do not all match specified year {year}."
        )


def set_scalar_name(ds, scalar_vars, frequency, year):
    """
    Set file name for scalar output.
    """
    reduction_methods = [
        parse_cell_methods(ds[var].attrs["cell_methods"])["time"]
        for var in scalar_vars
    ]
    if len(set(reduction_methods)) == 1:
        reduction_method = reduction_methods[0]
    else:
        raise RuntimeError(
            f"Require single reduction method. Instead recieved {reduction_methods}"
        )

    name = f"access-cm3.mom6.scalar.{frequency}.{reduction_method}.{year}.nc"
    return name


def set_ocn_file_name(ndims,
                      field_name,
                      frequency,
                      reduction_method,
                      year):
    """
    Set the file name for a single variable.
    File names follow format:
    'access-cm3.mom6.h.<dimension>.<field-name>.<frequency>.<reduction-method>.<year>.nc
    """
    return(
        f"access-cm3.mom6.{ndims}.{field_name}.{frequency}.{reduction_method}.{year}.nc"
    )


def parse_cell_methods(methods_string):
    """
    Return each cell method from a string of form
    'area:mean yh:mean xh:mean time: mean'
    """
    pattern = r"(.+?:\s?[a-z]+)"
    method_list = re.findall(pattern, methods_string)
    # Strip any whitespace
    method_list = ["".join(method.split()) for method in method_list]

    method_pattern = r"(.+):([a-z]+)"

    cell_methods = {}
    for method_str in method_list:
        match = re.match(method_pattern, method_str)
        if not match:
            raise RuntimeError("Failed to parse cell methods")
        dim = match[1]
        method = match[2]
        cell_methods[dim] = method

    return cell_methods


def move_ice(work_dirs, ice_archive_dir):
    pattern = r"access-cm3\.cice\.(?!r)"
    datasets = []
    output_paths = []
    for dir in work_dirs:
        for file in os.listdir(dir):
            if re.match(pattern, file):
                infile = dir / file
                outfile = ice_archive_dir / file

                ds = xr.open_dataset(infile, decode_times=False)
                ds = to_proleptic(ds)

                datasets.append(ds)
                output_paths.append(outfile)

    xr.save_mfdataset(datasets, output_paths)


def move_coupler(work_dirs, coupler_archive_dir):
    pattern = r"access-cm3\.cpl\.h.+\.nc"
    for dir in work_dirs:
        for file in os.listdir(dir):
            if re.match(pattern, file):
                infile = dir / file
                outfile = coupler_archive_dir / file
                shutil.copy2(infile, outfile)


def get_current_year_work_dirs(year, work_dir):
    # Get directory names for the current year
    pattern = fr"{year}[0-9]{{4}}"
    current_year_dirs = [dir for dir in os.listdir(work_dir)
                         if re.fullmatch(pattern, dir)]

    return [work_dir/dir for dir in current_year_dirs]


def move_restarts(current_year_output_dirs,
                  atmosphere_data_dir,
                  restart_dirs,
                  year):
    """
    Move restart files for a single year into archive. Only move
    end of year restarts.
    """
    # Time code for start of next year
    next_year_start = f"{year+1}-01-01-00000"
    patterns = {
        ICE: f"access-cm3.cice.r.{next_year_start}.nc",
        OCEAN: f"access-cm3.mom6.r.{next_year_start}.nc",
        COUPLER: f"access-cm3.cpl.r.{next_year_start}.nc"
    }
    copy_paths = []
    for dir in current_year_output_dirs:
        for file in os.listdir(dir):
            file_path = dir / file
            for component, pattern in patterns.items():
                if re.match(pattern, file):
                    copy_path = restart_dirs[component] / file
                    copy_paths.append((file_path, copy_path))

    # Copy atmosphere restarts
    atm_pattern = f"atmosa.da{year + 1}0101_00"
    for file in os.listdir(atmosphere_data_dir):        
        if re.match(atm_pattern, file):
            file_path = atmosphere_data_dir / file
            copy_path = restart_dirs[ATMOSPHERE] / file
            copy_paths.append((file_path, copy_path))

    for input_path, copy_path in copy_paths:
        check_exists(copy_path)
        shutil.copy2(input_path, copy_path)


def check_exists(file_path):
    """Guard against overwriting existing file"""
    if file_path.exists():
        raise FileExistsError(
            f"File {file_path} already exists and will not be overwritten."
        )


def make_year_archive(archive_dir, components, year, dir_type):
    """
    Make archive directory tree of form:
        <history/restart>
            <year>
                <component 1>
                <component 2>
                ...
                <component n>

    Parameters:
    -----------
    archive_dir: top-level archive directory
    components: components to make directories for
    year: Model year for archival
    dir_type: history or restart
    """

    print(f"Making {dir_type} directory for year {year}.")
    # Setup the top-level directory
    archive_dir.mkdir(exist_ok=True)
    try:
        year_archive = (archive_dir / dir_type / f"{year}")
        year_archive.mkdir(exist_ok=False, parents=True)

    except FileExistsError as err:
        print(
            f"{dir_type} directory for year {year} already exists. Exiting.",
            file=sys.stderr
            )
        raise err

    component_archive_dirs = {
        component: year_archive / component 
        for component in components
    }

    for component_archive in component_archive_dirs.values():
        component_archive.mkdir()

    return component_archive_dirs


def parse_args():
    parser = argparse.ArgumentParser(description="Copy CM3 output and organise structure")
    parser.add_argument("-y",
                        dest="year",
                        required=True,
                        type=int,
                        help="Year to copy")
    parser.add_argument("-e",
                        dest="expt_dir",
                        required=True,
                        type=str,
                        help="Path to experiment cylc-run directory")
    parser.add_argument("-a",
                        dest="archive_dir",
                        required=True,
                        type=str,
                        help="Path to experiment archive directory")
    parser.add_argument("--cpl",
                        dest="copy_cpl",
                        action="store_true",
                        help="Copy coupler history fields (default false)"
                        )
    return parser.parse_args()


if __name__ == "__main__":

    args = parse_args()
    client = Client()
    print(client)
    t1 = time.perf_counter()
    year = args.year
    expt_dir = Path(args.expt_dir).resolve()
    work_dir = expt_dir / "work"

    atmosphere_data_dir = expt_dir / "share" / "data" / "History_Data" 
    atmosphere_netcdf_dir = atmosphere_data_dir / "netCDF"
    archive_dir = Path(args.archive_dir).resolve()

    # Components to copy histroy for:
    components_hist = [ICE, OCEAN, ATMOSPHERE]
    if args.copy_cpl:
        components_hist = components_hist + [COUPLER]
    history_dirs = make_year_archive(archive_dir, components_hist, year, "archive")

    # Always copy restarts for all components
    restart_dirs = make_year_archive(archive_dir, COMPONENTS_ALL, year, "restart")

    current_year_work_dirs = get_current_year_work_dirs(year, work_dir)
    current_year_output_dirs = [dir/"atmos" for dir in current_year_work_dirs]

    print("Moving ice")
    move_ice(current_year_output_dirs, history_dirs[ICE])
    print("Moving ocean")
    move_ocean(year, current_year_output_dirs, history_dirs[OCEAN])
    print("Moving atmosphere")
    move_atmos(year, atmosphere_netcdf_dir, history_dirs[ATMOSPHERE])

    if args.copy_cpl:
        print("Moving coupler")
        move_coupler(current_year_output_dirs, history_dirs[COUPLER])

    t2 = time.perf_counter()

    print("Moving end of year restarts")
    move_restarts(current_year_output_dirs,
                  atmosphere_data_dir,
                  restart_dirs,
                  year)

    print(f"Time: {t2-t1}")
