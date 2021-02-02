#!/bin/bash

# GEN Script begin
rm -f request_fragment_check.py
wget -q https://raw.githubusercontent.com/cms-sw/genproductions/master/bin/utils/request_fragment_check.py
python request_fragment_check.py --bypass_status --prepid HCA-Run3Winter20GS-00035
GEN_ERR=$?
if [ $GEN_ERR -ne 0 ]; then
  echo "GEN Checking Script returned exit code $GEN_ERR which means there are $GEN_ERR errors"
  echo "Validation WILL NOT RUN"
  echo "Please correct errors in the request and run validation again"
  exit $GEN_ERR
fi
echo "Running VALIDATION. GEN Request Checking Script returned no errors"
# GEN Script end

export SCRAM_ARCH=slc7_amd64_gcc820

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_11_3_X_2021-01-29-1100/src ] ; then
  echo release CMSSW_11_3_X_2021-01-29-1100 already exists
else
  scram p CMSSW CMSSW_11_3_X_2021-01-29-1100
fi
cd CMSSW_11_3_X_2021-01-29-1100/src
eval `scram runtime -sh`

# Download fragment from McM
curl -s -k https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_fragment/HCA-Run3Winter20GS-00035 --retry 3 --create-dirs -o Configuration/GenProduction/python/HCA-Run3Winter20GS-00035-fragment.py
[ -s Configuration/GenProduction/python/HCA-Run3Winter20GS-00035-fragment.py ] || exit $?;

# Check if fragment contais gridpack path ant that it is in cvmfs
if grep -q "gridpacks" Configuration/GenProduction/python/HCA-Run3Winter20GS-00035-fragment.py; then
  if ! grep -q "/cvmfs/cms.cern.ch/phys_generator/gridpacks" Configuration/GenProduction/python/HCA-Run3Winter20GS-00035-fragment.py; then
    echo "Gridpack inside fragment is not in cvmfs."
    exit -1
  fi
fi
scram b
cd ../..

# Maximum validation duration: 57600s
# Margin for validation duration: 20%
# Validation duration with margin: 57600 * (1 - 0.20) = 46080s
# Time per event for each sequence: 3.6249s
# Threads for each sequence: 8
# Time per event for single thread for each sequence: 8 * 3.6249s = 28.9996s
# Which adds up to 28.9996s per event
# Single core events that fit in validation duration: 46080s / 28.9996s = 1588
# Produced events limit in McM is 10000
# According to 1.0000 efficiency, up to 10000 / 1.0000 = 10000 events should run
# Clamp (put value) 1588 within 1 and 10000 -> 1588
# It is estimated that this validation will produce: 1588 * 1.0000 = 1588 events
EVENTS=1588


# cmsDriver command
cmsDriver.py Configuration/GenProduction/python/HCA-Run3Winter20GS-00035-fragment.py --python_filename HCA-Run3Winter20GS-00035_1_cfg.py --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --fileout file:HCA-Run3Winter20GS-00035.root --conditions auto:phase1_2021_realistic --beamspot Run3RoundOptics25ns13TeVLowSigmaZ --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(100)" --step GEN,SIM --geometry DB:Extended --era Run3 --no_exec --mc -n $EVENTS || exit $? ;

# Run generated config
cmsRun -e -j HCA-Run3Winter20GS-00035_report.xml HCA-Run3Winter20GS-00035_1_cfg.py || exit $? ;

# Report HCA-Run3Winter20GS-00035_report.xml
cat HCA-Run3Winter20GS-00035_report.xml

# Parse values from HCA-Run3Winter20GS-00035_report.xml report
totalEvents=$(grep -Po "(?<=<TotalEvents>)(\d*)(?=</TotalEvents>)" HCA-Run3Winter20GS-00035_report.xml | tail -n 1)
threads=$(grep -Po "(?<=<Metric Name=\"NumberOfThreads\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20GS-00035_report.xml | tail -n 1)
peakValueRss=$(grep -Po "(?<=<Metric Name=\"PeakValueRss\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20GS-00035_report.xml | tail -n 1)
peakValueVsize=$(grep -Po "(?<=<Metric Name=\"PeakValueVsize\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20GS-00035_report.xml | tail -n 1)
totalSize=$(grep -Po "(?<=<Metric Name=\"Timing-tstoragefile-write-totalMegabytes\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20GS-00035_report.xml | tail -n 1)
totalSizeAlt=$(grep -Po "(?<=<Metric Name=\"Timing-file-write-totalMegabytes\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20GS-00035_report.xml | tail -n 1)
totalJobTime=$(grep -Po "(?<=<Metric Name=\"TotalJobTime\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20GS-00035_report.xml | tail -n 1)
totalJobCPU=$(grep -Po "(?<=<Metric Name=\"TotalJobCPU\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20GS-00035_report.xml | tail -n 1)
eventThroughput=$(grep -Po "(?<=<Metric Name=\"EventThroughput\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20GS-00035_report.xml | tail -n 1)
avgEventTime=$(grep -Po "(?<=<Metric Name=\"AvgEventTime\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20GS-00035_report.xml | tail -n 1)
if [ -z "$threads" ]; then
  echo "Could not find NumberOfThreads in report, defaulting to 1"
  threads=1
fi
if [ -z "$eventThroughput" ]; then
  eventThroughput=$(bc -l <<< "scale=4; 1 / ($avgEventTime / $threads)")
fi
if [ -z "$totalSize" ]; then
  totalSize=$totalSizeAlt
fi
echo "Validation report of HCA-Run3Winter20GS-00035 sequence 1/1"
echo "Total events: $totalEvents"
echo "Threads: $threads"
echo "Peak value RSS: $peakValueRss MB"
echo "Peak value Vsize: $peakValueVsize MB"
echo "Total size: $totalSize MB"
echo "Total job time: $totalJobTime s"
echo "Total CPU time: $totalJobCPU s"
echo "Event throughput: $eventThroughput"
echo "CPU efficiency: "$(bc -l <<< "scale=2; ($totalJobCPU * 100) / ($threads * $totalJobTime)")" %"
echo "Size per event: "$(bc -l <<< "scale=4; ($totalSize * 1024 / $totalEvents)")" kB"
echo "Time per event: "$(bc -l <<< "scale=4; (1 / $eventThroughput)")" s"
echo "Filter efficiency percent: "$(bc -l <<< "scale=8; ($totalEvents * 100) / $EVENTS")" %"
echo "Filter efficiency fraction: "$(bc -l <<< "scale=10; ($totalEvents) / $EVENTS")
