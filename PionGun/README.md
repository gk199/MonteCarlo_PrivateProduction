# Instructions for Pion Gun
Using `CMSSW_10_6_0/src/Configuration/GenProduction/python/SinglePi0E10_pythia8_dfi.py`, the following steps are run to produce MC events. The initial pion gun configuration file is taken from the generator GitHub files for [neutral pion](https://github.com/cms-sw/cmssw/blob/CMSSW_10_6_X/Configuration/Generator/python/SinglePi0E10_pythia8_cfi.py) or [charged pion](https://github.com/cms-sw/cmssw/blob/CMSSW_10_6_X/Configuration/Generator/python/SinglePiPt10_pythia8_cfi.py). I referenced [FullSim twiki](https://twiki.cern.ch/twiki/bin/view/CMSPublic/WorkBookGenIntro#ComposeFullSimConfig) and [generation twiki](https://twiki.cern.ch/twiki/bin/view/CMSPublic/WorkBookGeneration).

## Step0 and Step1
This is run in `/afs/cern.ch/work/g/gkopp/MC_GenProduction/PionGun/CMSSW_10_6_0/src' (which has the TDC information copied over) and in `/afs/cern.ch/work/g/gkopp/MC_GenProduction/PionGun/CMSSW_11_0_2/src' which has TDC information as part of the official CMSSW_11_0_X release.

### 106X:
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

### 110X:
Step0 (GEN-SIM):
```
cmsDriver.py Configuration/GenProduction/python/SinglePiE10_10_pythia8_dfi.py --fileout file:SinglePion211_E10_eta1phi0_step0.root --mc --eventcontent RAWSIM --datatier GEN-SIM --conditions 110X_mcRun3_2021_realistic_v6 --beamspot Run3RoundOptics25ns13TeVHighSigmaZ --step GEN,SIM --geometry DB:Extended --era Run3 --python_filename SinglePi211_E10_eta1phi0_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(1408450)" -n 100

cmsRun SinglePi211_E10_eta1phi0_cfg.py
```

Step1 (DIGI-RAW) with PU:
```
cmsDriver.py step1 --filein file:SinglePion211_E10_eta1phi0_step0.root --fileout file:SinglePion211_E10_eta1phi0_PU_step1.root --pileup_input das:/RelValMinBias_13/CMSSW_11_0_0_pre1-106X_upgrade2021_realistic_v5-v1/GEN-SIM --pileup AVE_50_BX_25ns --mc --eventcontent FEVTDEBUGHLT --datatier GEN-SIM-DIGI-RAW --geometry DB:Extended --conditions 110X_mcRun3_2021_realistic_v6 --step DIGI:pdigi_valid,L1,DIGI2RAW,HLT:@relval2017 --nThreads 8 --era Run3 --python_filename SinglePion211_E10_eta1phi0_step1_PU_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n 100

cmsRun SinglePion211_E10_eta1phi0_step1_PU_cfg.py
```

## SiPM Signal Injection
The configuration file `SimCalorimetry/HcalSimProducers/python/hcalUnsuppressedDigis_cfi.py` allows for injecting signals into specific SiPMs. The position, energy, and time may be set. I use the time=tof option by setting;
```
ignoreGeantTime=cms.bool(True),
injectTestHitsTime = cms.vdouble(),
```
### Scanning Parameters
Energy values from 0.001 to 1.3 are scanned with `InjectedSiPMsignal_energy_scan.sh`. This range of energy values corresponds to ADC values from 10-200. The bash script makes 40 Root files with injected SiPM signals at energies: 0.001-0.01 (step size 0.001), 0.01-0.1 (step size 0.01), 0.1-0.2 (step size 0.02), 0.2-0.7 (step size 0.05), and 0.7-1.3 (step size 0.1). Multiple positions can be entered at once, each given a SiPM signal injection:
```
injectTestHitsCells = cms.vint32(1,1,1,1, 1,1,21,4, 1,14,1,1, 1,14,21,4, 2,19,1,1, 2,19,21,4, 2,25,1,1, 2,25,21,4),
```
The TDC threshold and timephase parameters are changed in `SimCalorimetry/HcalSimProducers/python/hcalSimParameters_cfi.py`. The default value for the timephase is 6, and increasing it to 7 decreases the reported TDC values by 1ns (as expected). The default value for the TDC threshold is 18.7, and decreasing it means that lower amplitude signals are picked up as well. 

Edits were made to `SimCalorimetry/HcalSimProducers/src/HcalDigitizer.cc` as this was not recognizing changes in the TestNumbering variable, and was scrambling the detector ID for the SiPM hit injection ([link to HcalDigitizer.cc](https://github.com/gk199/MonteCarlo_PrivateProduction/blob/master/PionGun/HcalDigitizer.cc#L347-L357)).

Then the ADC vs TDC plot is made in `/afs/cern.ch/work/g/gkopp/HCAL_Trigger/L1Ntuples/HCAL_TP_TimingBitEmulator/CMSSW_10_6_0/src/HcalTrigger/Validation` with `ADC_vs_TDC.exe`, along with plots of the CaloSamples with `CaloSampleAnalysis*.exe`.

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
```
cmsrel CMSSW_10_6_0
cd CMSSW_10_6_0/src/
cmsenv
git cms-addpkg DataFormats/HcalDigi EventFilter/HcalRawToDigi SimCalorimetry/HcalSimAlgos SimCalorimetry/HcalSimProducers
```
This is currently done in `/afs/cern.ch/work/g/gkopp/MC_GenProduction/PionGun/106X_TDC/CMSSW_10_6_0/src` for Pion gun studies, and in `/afs/cern.ch/work/g/gkopp/MC_GenProduction/106X_TDC/CMSSW_10_6_0/src/` for TDC threshold studies (changing threshold in `SimCalorimetry/HcalSimProducers/python/hcalSimParameters_cfi.py` to 18.7*3).

Copy over files from `/eos/cms/store/user/lowang/public/`. This gives TDC information in 106X, and do not need flags to include as HB is now unpacked by default. Condor scripts to run the TDC threshold files are in `/afs/cern.ch/work/g/gkopp/CondorInfo/LLP_TDC/`.

## Location on lxplus
This is run in `/afs/cern.ch/work/g/gkopp/MC_GenProduction/PionGun/` in either 110X or 106X. The files for this GitHub are stored on `/afs/cern.ch/work/g/gkopp/MC_GenProduction/MonteCarlo_PrivateProduction`.