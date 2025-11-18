start_year=2031
end_year=$(($start_year+9))
for year in $(seq $start_year $end_year)
do
  echo "Submitted" $year
  qsub -v YEAR=$year -N cm3-archive-$year archive-run.sh
done