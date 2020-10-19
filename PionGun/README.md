# Instructions for Pion Gun
Using `CMSSW_10_6_0/src/Configuration/GenProduction/python/SinglePi0E10_pythia8_dfi.py`, the following steps are run to produce MC events. The initial pion gun configuration file is taken from the generator GitHub files for [neutral pion](https://github.com/cms-sw/cmssw/blob/CMSSW_10_6_X/Configuration/Generator/python/SinglePi0E10_pythia8_cfi.py) or [charged pion](https://github.com/cms-sw/cmssw/blob/CMSSW_10_6_X/Configuration/Generator/python/SinglePiPt10_pythia8_cfi.py). I referenced [FullSim twiki](https://twiki.cern.ch/twiki/bin/view/CMSPublic/WorkBookGenIntro#ComposeFullSimConfig) and [generation twiki](https://twiki.cern.ch/twiki/bin/view/CMSPublic/WorkBookGeneration).

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

## CMSSW Release
TDC is only avaliable in 110X currently. To include it, need the flag in the cmsDriver.py command:
```
--customise_commands 'process.hcalRawDatauHTR.packHBTDC = False \n'
```
Or add
```
process.hcalRawDatauHTR.packHBTDC = False
```
to the python configuration file (step1, DIGI-RAW).

Hack to have TDC in 106X from Long's files:
'''
cmsrel CMSSW_10_6_0
cd CMSSW_10_6_0/src/
cmsenv
git cms-addpkg DataFormats/HcalDigi EventFilter/HcalRawToDigi SimCalorimetry/HcalSimAlgos SimCalorimetry/HcalSimProducers
```
This is currently done in `/afs/cern.ch/work/g/gkopp/MC_GenProduction/PionGun/106X_TDC/CMSSW_10_6_0/src` for Pion gun studies, and in `/afs/cern.ch/work/g/gkopp/MC_GenProduction/106X_TDC/CMSSW_10_6_0/src/` for TDC threshold studies (changing threshold in `SimCalorimetry/HcalSimProducers/python/hcalSimParameters_cfi.py` to 18.7*3).

Copy over files from `/eos/cms/store/user/lowang/public/`. This gives TDC information in 106X, and do not need flags to include as HB is now unpacked by default. Condor scripts to run the TDC threshold files are in `/afs/cern.ch/work/g/gkopp/CondorInfo/LLP_TDC/`.

## Location on lxplus
This is run in `/afs/cern.ch/work/g/gkopp/MC_GenProduction/PionGun/`. The files for this GitHub are stored on `/afs/cern.ch/work/g/gkopp/MC_GenProduction/MonteCarlo_PrivateProduction`.