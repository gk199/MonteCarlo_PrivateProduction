# Instructions for Generating Private Production LLP MC Samples
Private production MC generation for LLP samples is done in order to account for the TDC simulation edits and to test TDC thresholds different than the default value of 18.7. 

## Production Campaign and Setup Commands
The production campaign for the [HTo2LongLivedTo4b](https://cmsweb.cern.ch/das/request?view=list&limit=50&instance=prod%2Fglobal&input=dataset+dataset%3D%2FHTo2LongLivedTo4b*%2F*%2F*) dataset is [here](https://cms-pdmv.cern.ch/mcm/requests?prepid=TSG-Run3Winter20DRPremixMiniAOD-00056&page=0&shown=127). From this, select GEN-SIM (first link in chain) or DIGI (second link in chain) and click through "Action" and "Get Test Command" (3rd picture option). This will give the full executable scripts to run. For example, the [GEN-SIM script](https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_test/HCA-Run3Winter20GS-00035) and the [DIGI script](https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_test/HCA-Run3Winter20DRPremixMiniAOD-00010) are here. 

### Modifications to Scripts
For conditions, use
```
-conditions auto:phase1_2021_realistic
```
and we need to use CMSSW_11_3(2)_X_2021-01-28-1100 for now (or later, since the PR was merged Jan 27). Later we can use 11_3_0_pre3 and in 11_2_0_patch1 once the changes have been merged and integrated fully.

Also need the customization of:
```
--customise_commands 'process.hcalRawDatauHTR.packHBTDC = cms.bool(False)'
```
in DIGI to save the 6 bit TDC value for trigger studies.

## Step 0 (GEN-SIM)
```
cd CMSSW_11_3_X_2021-01-29-1100/src/
cmsenv
scram b
cd ../..
EVENTS=2000

<choose relevant one of following>
condor_argu=HTo2LongLivedTo4b_MH-125_MFF-50_CTau-3000mm_TuneCP5_13TeV_pythia8_cff
condor_argu=HTo2LongLivedTo4b_MH-125_MFF-50_CTau-30000mm_TuneCP5_13TeV_pythia8_cff
condor_argu=HTo2LongLivedTo4b_MH-250_MFF-120_CTau-1000mm_TuneCP5_13TeV_pythia8_cff
condor_argu=HTo2LongLivedTo4b_MH-250_MFF-120_CTau-10000mm_TuneCP5_13TeV_pythia8_cff
condor_argu=QCD_Pt-15to7000_TuneCP5_Flat_13TeV_pythia8        
<proceed with set condor argument>

cmsDriver.py Configuration/GenProduction/python/$condor_argu.py --python_filename $condor_argu-1_cfg.py --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --fileout file:$condor_argu.root --conditions auto:phase1_2021_realistic --beamspot Run3RoundOptics25ns13TeVLowSigmaZ --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(100)" --step GEN,SIM --geometry DB:Extended --era Run3 --no_exec --mc -n $EVENTS

<choose relevant one of following>
cmsRun HTo2LongLivedTo4b_MH-125_MFF-50_CTau-3000mm_TuneCP5_13TeV_pythia8_cff-1_cfg.py
cmsRun HTo2LongLivedTo4b_MH-125_MFF-50_CTau-30000mm_TuneCP5_13TeV_pythia8_cff-1_cfg.py
cmsRun HTo2LongLivedTo4b_MH-250_MFF-120_CTau-1000mm_TuneCP5_13TeV_pythia8_cff-1_cfg.py
cmsRun HTo2LongLivedTo4b_MH-250_MFF-120_CTau-10000mm_TuneCP5_13TeV_pythia8_cff-1_cfg.py
cmsRun QCD_Pt-15to7000_TuneCP5_Flat_13TeV_pythia8-1_cfg.py
<proceed with the processing>
```
This step was also attempted in Condor, however, I am running into errors. Used `GEN-SIM_condor.sh` and `condor*.sub`.

## Step 1 (DIGI-RAW)
```
cd CMSSW_11_3_X_2021-01-29-1100/src/
cmsenv
scram b
cd ../..
EVENTS=2000

<choose relevant one of following>
condor_argu=HTo2LongLivedTo4b_MH-125_MFF-50_CTau-3000mm_TuneCP5_13TeV_pythia8_cff
condor_argu=HTo2LongLivedTo4b_MH-125_MFF-50_CTau-30000mm_TuneCP5_13TeV_pythia8_cff
condor_argu=HTo2LongLivedTo4b_MH-250_MFF-120_CTau-1000mm_TuneCP5_13TeV_pythia8_cff
condor_argu=HTo2LongLivedTo4b_MH-250_MFF-120_CTau-10000mm_TuneCP5_13TeV_pythia8_cff
condor_argu=QCD_Pt-15to7000_TuneCP5_Flat_13TeV_pythia8
<proceed with set condor argument>

cmsDriver.py  --python_filename $condor_argu-digi_1_cfg.py --eventcontent FEVTDEBUGHLT --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-DIGI-RAW --fileout file:$condor_argu-digi.root --pileup_input "dbs:/Neutrino_E-10_gun/RunIISummer17PrePremix-PURun3Winter20_110X_mcRun3_2021_realistic_v6-v2/PREMIX" --conditions auto:phase1_2021_realistic --customise_commands 'process.hcalRawDatauHTR.packHBTDC = cms.bool(False)' --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:GRun --procModifiers premix_stage2 --geometry DB:Extended --filein file:$condor_argu.root --datamix PreMix --era Run3 --no_exec --mc -n $EVENTS
```
This will make the `*-digi_1_cfg.py` files that are run with `cmsRun` to produce the step 1 root files. A couple edits are made in case the PU files are not found in DAS when the python config is made:
```
process.mixData.input.fileNames = cms.untracked.vstring(['/store/mc/RunIISummer17PrePremix/Neutrino_E-10_gun/PREMIX/PURun3Winter20_110X_mcRun3_2021_realistic_v6-v2/10000/003BD9E2-57A0-0B4A-87D3-0D27F7A1210B.root','/store/mc/RunIISummer17PrePremix/Neutrino_E-10_gun/PREMIX/PURun3Winter20_110X_mcRun3_2021_realistic_v6-v2/10000/0050683D-3D10-3045-9C7B-612F2348E41A.root','/store/mc/RunIISummer17PrePremix/Neutrino_E-10_gun/PREMIX/PURun3Winter20_110X_mcRun3_2021_realistic_v6-v2/10000/0069A272-28B8-2F45-83DC-6888A114BB31.root','/store/mc/RunIISummer17PrePremix/Neutrino_E-10_gun/PREMIX/PURun3Winter20_110X_mcRun3_2021_realistic_v6-v2/10000/00EB3048-697C-6A4A-8A29-E7724D48F209.root','/store/mc/RunIISummer17PrePremix/Neutrino_E-10_gun/PREMIX/PURun3Winter20_110X_mcRun3_2021_realistic_v6-v2/10000/01ECE9A4-C33A-8B4F-B7BE-788DFD75C640.root','/store/mc/RunIISummer17PrePremix/Neutrino_E-10_gun/PREMIX/PURun3Winter20_110X_mcRun3_2021_realistic_v6-v2/10000/01F12F67-CC64-A247-94C1-DBA79813D5C7.root','/store/mc/RunIISummer17PrePremix/Neutrino_E-10_gun/PREMIX/PURun3Winter20_110X_mcRun3_2021_realistic_v6-v2/10000/030B5843-5AB5-9C45-93E5-6AC4E6018651.root','/store/mc/RunIISummer17PrePremix/Neutrino_E-10_gun/PREMIX/PURun3Winter20_110X_mcRun3_2021_realistic_v6-v2/10000/035F07C2-A638-7743-8199-FBA03142F637.root','/store/mc/RunIISummer17PrePremix/Neutrino_E-10_gun/PREMIX/PURun3Winter20_110X_mcRun3_2021_realistic_v6-v2/10000/042FEA90-CE90-E847-A93D-E2A03D900404.root','/store/mc/RunIISummer17PrePremix/Neutrino_E-10_gun/PREMIX/PURun3Winter20_110X_mcRun3_2021_realistic_v6-v2/10000/04716161-1DE5-6D40-A067-6B33665B9859.root'])
```
Before producing the files, confirm that the TDC simulation is correct, TDC thresholds are set correctly, and CaloSamples are saved if wanted. These are done in the following files:
```
SimCalorimetry/HcalSimAlgos/src/HcalTDC.cc
SimCalorimetry/HcalSimProducers/python/hcalSimParameters_cfi.py
SimCalorimetry/HcalSimProducers/python/hcalUnsuppressedDigis_cfi.py
```
Following amplitude dependence studies, the TDC threshold is set at 74.8 such that it is right above the noise level. Then the step1 files are submitted using CRAB, since DAS access is needed for the PU mixing.
```
crab submit -c submit*.py
```
for each file: `submit_MH125_ctau30000mm_digi_step1.py`, `submit_MH125_ctau3000mm_digi_step1.py`, `submit_MH250_ctau10000mm_digi_step1.py`, `submit_MH250_ctau1000mm_digi_step1.py`, `submit_QCD_digi_step1.py`, `submit_RelValNuGun_digi_step1.py`. 

## Generator Fragments
Generator fragments for the Higgs to 2 LLP to 4 b-quark are taken from the [official production](https://docs.google.com/spreadsheets/d/1D86SiuXDJBG0q_ObOuCRaCJA8EGp-lbjduKBwNYcz1I/edit#gid=0) request, with specific fragments saved in a [Dropbox](https://www.dropbox.com/sh/9qdwdkplf8kls5j/AAB88P-2_b7om0EUaQHcJYeXa?dl=0&lst=). These fragments were then copied to `CMSSW_11_3_X_2021-01-29-1100/src/Configuration/GenProduction/python/` and used to produce the python config file that is run with cmsRun (step 0).

For the neutrino gun (used to evaluate rates), the GEN-SIM of the official production was saved, linked [here](https://cmsweb.cern.ch/das/request?view=list&limit=50&instance=prod%2Fglobal&input=dataset%3D%2FRelValNuGun%2FCMSSW_11_2*%2F*). This will need to be re-processed through the digitization step with the fixed TDC simulation.