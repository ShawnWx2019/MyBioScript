#!/bin/sh

# Shell script for programatic access to Revigo. Run it with:
#   revigo-shell example-data.csv

# Submit job to Revigo
jobid=$(curl "http://revigo.irb.hr/StartJob.aspx" -X POST --silent --data-urlencode "cutoff=0.5" --data-urlencode "valueType=pvalue" --data-urlencode "speciesTaxon=0" --data-urlencode "measure=SIMREL" --data-urlencode "goList@$1" --header "Content-Type: application/x-www-form-urlencoded" | jq '.jobid')

# Check job status
running=1
while [ $running -ne 0 ]
do
    running=$(curl "http://revigo.irb.hr/QueryJobStatus.aspx" -X POST --silent --data-urlencode "jobid=$jobid" | jq '.running')
    sleep 1
done

# Fetch results
# bp
curl "http://revigo.irb.hr/ExportJob.aspx" -X POST --silent --data-urlencode "jobid=$jobid" --data-urlencode "namespace=1" --data-urlencode "type=csvtable" > bp.$2.csv
curl "http://revigo.irb.hr/ExportJob.aspx" -X POST --silent --data-urlencode "jobid=$jobid" --data-urlencode "namespace=1" --data-urlencode "type=rtable" > bp.$2.r
curl "http://revigo.irb.hr/ExportJob.aspx" -X POST --silent --data-urlencode "jobid=$jobid" --data-urlencode "namespace=1" --data-urlencode "type=xgmml" > bp.$2.xgmml
# cc
curl "http://revigo.irb.hr/ExportJob.aspx" -X POST --silent --data-urlencode "jobid=$jobid" --data-urlencode "namespace=2" --data-urlencode "type=csvtable" > cc.$2.csv
curl "http://revigo.irb.hr/ExportJob.aspx" -X POST --silent --data-urlencode "jobid=$jobid" --data-urlencode "namespace=2" --data-urlencode "type=rtable" > cc.$2.r
curl "http://revigo.irb.hr/ExportJob.aspx" -X POST --silent --data-urlencode "jobid=$jobid" --data-urlencode "namespace=2" --data-urlencode "type=xgmml" > cc.$2.xgmml
# mf
curl "http://revigo.irb.hr/ExportJob.aspx" -X POST --silent --data-urlencode "jobid=$jobid" --data-urlencode "namespace=3" --data-urlencode "type=csvtable" > mf.$2.csv
curl "http://revigo.irb.hr/ExportJob.aspx" -X POST --silent --data-urlencode "jobid=$jobid" --data-urlencode "namespace=3" --data-urlencode "type=rtable" > mf.$2.r
curl "http://revigo.irb.hr/ExportJob.aspx" -X POST --silent --data-urlencode "jobid=$jobid" --data-urlencode "namespace=3" --data-urlencode "type=xgmml" > mf.$2.xgmml

