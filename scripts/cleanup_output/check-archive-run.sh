start_year=2031
end_year=2040

ARCHIVE_DIR=/g/data/zv30/non-cmip/ACCESS-CM3/cm3-run-11-08-2025-25km-beta-om3-new-um-params-continued

for year in $(seq $start_year $end_year)
do
  echo "Checking" $year
  
  nfiles=$(ls -l $ARCHIVE_DIR/archive/$year/atmosphere | wc -l)
  if [ "$nfiles" -ne "37" ]; then
    echo "UM number of files incorrect"
  fi

  nfiles=$(ls -l $ARCHIVE_DIR/archive/$year/ice | wc -l)
  if [ "$nfiles" -ne "13" ]; then
    echo "CICE number of files incorrect"
  fi

  nfiles=$(ls -l $ARCHIVE_DIR/archive/$year/ocean | wc -l)
  if [ "$nfiles" -ne "97" ]; then
    echo "MOM number of files incorrect"
  fi
done