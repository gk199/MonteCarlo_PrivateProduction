#!/bin/bash

export SCRAM_ARCH=slc7_amd64_gcc820

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_11_0_3/src ] ; then
  echo release CMSSW_11_0_3 already exists
else
  scram p CMSSW CMSSW_11_0_3
fi
cd CMSSW_11_0_3/src
eval `scram runtime -sh`

scram b
cd ../..

# Maximum validation duration: 28800s
# Margin for validation duration: 20%
# Validation duration with margin: 28800 * (1 - 0.20) = 23040s
# Time per event for each sequence: 1.8979s, 2.7644s
# Threads for each sequence: 8, 8
# Time per event for single thread for each sequence: 8 * 1.8979s = 15.1832s, 8 * 2.7644s = 22.1152s
# Which adds up to 37.2984s per event
# Single core events that fit in validation duration: 23040s / 37.2984s = 617
# Produced events limit in McM is 10000
# According to 1.0000 efficiency, up to 10000 / 1.0000 = 10000 events should run
# Clamp (put value) 617 within 1 and 10000 -> 617
# It is estimated that this validation will produce: 617 * 1.0000 = 617 events
EVENTS=617


# cmsDriver command
cmsDriver.py  --python_filename HCA-Run3Winter20DRPremixMiniAOD-00010_1_cfg.py --eventcontent FEVTDEBUGHLT --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-DIGI-RAW --fileout file:HCA-Run3Winter20DRPremixMiniAOD-00010_0.root --pileup_input "dbs:/Neutrino_E-10_gun/RunIISummer17PrePremix-PURun3Winter20_110X_mcRun3_2021_realistic_v6-v2/PREMIX" --conditions 110X_mcRun3_2021_realistic_v6 --customise_commands 'process.hcalRawDatauHTR.packHBTDC = cms.bool(False)' --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:GRun --procModifiers premix_stage2 --geometry DB:Extended --filein file:HCA-Run3Winter20GS-00035.root --datamix PreMix --era Run3 --no_exec --mc -n $EVENTS || exit $? ;

# Run generated config
cmsRun -e -j HCA-Run3Winter20DRPremixMiniAOD-00010_0_report.xml HCA-Run3Winter20DRPremixMiniAOD-00010_1_cfg.py || exit $? ;

# Report HCA-Run3Winter20DRPremixMiniAOD-00010_0_report.xml
cat HCA-Run3Winter20DRPremixMiniAOD-00010_0_report.xml

# Parse values from HCA-Run3Winter20DRPremixMiniAOD-00010_0_report.xml report
totalEvents=$(grep -Po "(?<=<TotalEvents>)(\d*)(?=</TotalEvents>)" HCA-Run3Winter20DRPremixMiniAOD-00010_0_report.xml | tail -n 1)
threads=$(grep -Po "(?<=<Metric Name=\"NumberOfThreads\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20DRPremixMiniAOD-00010_0_report.xml | tail -n 1)
peakValueRss=$(grep -Po "(?<=<Metric Name=\"PeakValueRss\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20DRPremixMiniAOD-00010_0_report.xml | tail -n 1)
peakValueVsize=$(grep -Po "(?<=<Metric Name=\"PeakValueVsize\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20DRPremixMiniAOD-00010_0_report.xml | tail -n 1)
totalSize=$(grep -Po "(?<=<Metric Name=\"Timing-tstoragefile-write-totalMegabytes\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20DRPremixMiniAOD-00010_0_report.xml | tail -n 1)
totalSizeAlt=$(grep -Po "(?<=<Metric Name=\"Timing-file-write-totalMegabytes\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20DRPremixMiniAOD-00010_0_report.xml | tail -n 1)
totalJobTime=$(grep -Po "(?<=<Metric Name=\"TotalJobTime\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20DRPremixMiniAOD-00010_0_report.xml | tail -n 1)
totalJobCPU=$(grep -Po "(?<=<Metric Name=\"TotalJobCPU\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20DRPremixMiniAOD-00010_0_report.xml | tail -n 1)
eventThroughput=$(grep -Po "(?<=<Metric Name=\"EventThroughput\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20DRPremixMiniAOD-00010_0_report.xml | tail -n 1)
avgEventTime=$(grep -Po "(?<=<Metric Name=\"AvgEventTime\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20DRPremixMiniAOD-00010_0_report.xml | tail -n 1)
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
echo "Validation report of HCA-Run3Winter20DRPremixMiniAOD-00010 sequence 1/2"
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

# cmsDriver command
cmsDriver.py  --python_filename HCA-Run3Winter20DRPremixMiniAOD-00010_2_cfg.py --eventcontent RECOSIM,MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RECO,MINIAODSIM --fileout file:HCA-Run3Winter20DRPremixMiniAOD-00010.root --conditions 110X_mcRun3_2021_realistic_v6 --step RAW2DIGI,L1Reco,RECO,RECOSIM,EI,PAT --procModifiers premix_stage2 --geometry DB:Extended --filein file:HCA-Run3Winter20DRPremixMiniAOD-00010_0.root --era Run3 --runUnscheduled --no_exec --mc -n $EVENTS || exit $? ;

# Run generated config
cmsRun -e -j HCA-Run3Winter20DRPremixMiniAOD-00010_report.xml HCA-Run3Winter20DRPremixMiniAOD-00010_2_cfg.py || exit $? ;

# Report HCA-Run3Winter20DRPremixMiniAOD-00010_report.xml
cat HCA-Run3Winter20DRPremixMiniAOD-00010_report.xml

# Parse values from HCA-Run3Winter20DRPremixMiniAOD-00010_report.xml report
totalEvents=$(grep -Po "(?<=<TotalEvents>)(\d*)(?=</TotalEvents>)" HCA-Run3Winter20DRPremixMiniAOD-00010_report.xml | tail -n 1)
threads=$(grep -Po "(?<=<Metric Name=\"NumberOfThreads\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20DRPremixMiniAOD-00010_report.xml | tail -n 1)
peakValueRss=$(grep -Po "(?<=<Metric Name=\"PeakValueRss\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20DRPremixMiniAOD-00010_report.xml | tail -n 1)
peakValueVsize=$(grep -Po "(?<=<Metric Name=\"PeakValueVsize\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20DRPremixMiniAOD-00010_report.xml | tail -n 1)
totalSize=$(grep -Po "(?<=<Metric Name=\"Timing-tstoragefile-write-totalMegabytes\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20DRPremixMiniAOD-00010_report.xml | tail -n 1)
totalSizeAlt=$(grep -Po "(?<=<Metric Name=\"Timing-file-write-totalMegabytes\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20DRPremixMiniAOD-00010_report.xml | tail -n 1)
totalJobTime=$(grep -Po "(?<=<Metric Name=\"TotalJobTime\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20DRPremixMiniAOD-00010_report.xml | tail -n 1)
totalJobCPU=$(grep -Po "(?<=<Metric Name=\"TotalJobCPU\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20DRPremixMiniAOD-00010_report.xml | tail -n 1)
eventThroughput=$(grep -Po "(?<=<Metric Name=\"EventThroughput\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20DRPremixMiniAOD-00010_report.xml | tail -n 1)
avgEventTime=$(grep -Po "(?<=<Metric Name=\"AvgEventTime\" Value=\")(.*)(?=\"/>)" HCA-Run3Winter20DRPremixMiniAOD-00010_report.xml | tail -n 1)
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
echo "Validation report of HCA-Run3Winter20DRPremixMiniAOD-00010 sequence 2/2"
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
