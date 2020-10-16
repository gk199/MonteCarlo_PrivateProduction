# Instructions for Pion Gun
Using `CMSSW_10_6_0/src/Configuration/GenProduction/python/SinglePi0E10_pythia8_dfi.py`, the following steps are run to produce MC events. The initial pion gun configuration file is taken from (generator GitHub)[https://github.com/cms-sw/cmssw/blob/CMSSW_10_6_X/Configuration/Generator/python/SinglePi0E10_pythia8_cfi.py]. I referenced (FullSim twiki)[https://twiki.cern.ch/twiki/bin/view/CMSPublic/WorkBookGenIntro#ComposeFullSimConfig] and (generation twiki)[https://twiki.cern.ch/twiki/bin/view/CMSPublic/WorkBookGeneration].

## Step0 and Step1
This is run in `/afs/cern.ch/work/g/gkopp/MC_GenProduction/PionGun/CMSSW_10_6_0/src'.

Step0 (GEN-SIM):
```
cmsDriver.py Configuration/GenProduction/python/SinglePi0E10_pythia8_dfi.py --fileout file:SinglePion_step0.root --mc --eventcontent RAWSIM --datatier GEN-SIM --conditions 106X_upgrade2021_realistic_v5 --beamspot Run3RoundOptics25ns13TeVHighSigmaZ --step GEN,SIM --geometry DB:Extended --era Run3 --python_filename SinglePi0E10_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(1408450)" -n 10000

cmsRun SinglePi0E10_cfg.py
```

Step1 (DIGI-RAW) with no PU:
```
cmsDriver.py step1 --filein file:SinglePion_step0.root --fileout file:SinglePion_PU_step1.root --pileup NoPileUp --mc --eventcontent FEVTDEBUGHLT --datatier GEN-SIM-DIGI-RAW --geometry DB:Extended --conditions 106X_upgrade2021_realistic_v5 --step DIGI:pdigi_valid,L1,DIGI2RAW,HLT:@relval2017 --nThreads 8 --era Run3 --python_filename SinglePi0E10_step1_PU_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n 100

cmsRun SinglePi0E10_step1_cfg.py
``` 

Step1 (DIGI-RAW) with PU:
``` 
cmsDriver.py step1 --filein file:SinglePion_step0.root --fileout file:SinglePion_PU_step1.root --pileup_input das:/RelValMinBias_13/CMSSW_10_6_0_pre4-106X_upgrade2021_realistic_v4-v1/GEN-SIM --pileup AVE_50_BX_25ns --mc --eventcontent FEVTDEBUGHLT --datatier GEN-SIM-DIGI-RAW --geometry DB:Extended --conditions 106X_upgrade2021_realistic_v5 --step DIGI:pdigi_valid,L1,DIGI2RAW,HLT:@relval2017 --nThreads 8 --era Run3 --python_filename SinglePi0E10_step1_PU_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n 100

cmsRun SinglePi0E10_step1_PU_cfg.py
```
To do: need to find new pileup file, this one seems to be unavaliable. 

## Location on lxplus
This is run in `/afs/cern.ch/work/g/gkopp/MC_GenProduction/PionGun/`. The files for this GitHub are stored on `/afs/cern.ch/work/g/gkopp/MC_GenProduction/MonteCarlo_PrivateProduction`.