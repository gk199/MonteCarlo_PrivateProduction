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
This step was also attempted in Condor, however, I am running into errors. Used `GEN-SIM_condor.sh' and `condor*.sub`.


## Generator Fragments
Generator fragments for the Higgs to 2 LLP to 4 b-quark are taken from the [official production](https://docs.google.com/spreadsheets/d/1D86SiuXDJBG0q_ObOuCRaCJA8EGp-lbjduKBwNYcz1I/edit#gid=0) request, with specific fragments saved in a [Dropbox](https://www.dropbox.com/sh/9qdwdkplf8kls5j/AAB88P-2_b7om0EUaQHcJYeXa?dl=0&lst=). These fragments were then copied to `CMSSW_11_3_X_2021-01-29-1100/src/Configuration/GenProduction/python/` and used to produce the python config file that is run with cmsRun (step 0).

For the neutrino gun (used to evaluate rates), the GEN-SIM of the official production was saved, linked [here](https://cmsweb.cern.ch/das/request?view=list&limit=50&instance=prod%2Fglobal&input=dataset%3D%2FRelValNuGun%2FCMSSW_11_2*%2F*). This will need to be re-processed through the digitization step with the fixed TDC simulation.