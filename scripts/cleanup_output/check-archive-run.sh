start_year=1981
end_year=1981

ARCHIVE_DIR=/g/data/zv30/non-cmip/ACCESS-CM3/cm3-run-20-01-2026-om3-update

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
  if [ "$nfiles" -ne "86" ]; then
    echo "MOM number of files incorrect"
  fi
done