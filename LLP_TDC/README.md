# Instructions for Generating Private Production LLP MC Samples
Private production MC generation for LLP samples is done in order to account for the TDC simulation edits and to test TDC thresholds different than the default value of 18.7. This is done on lxplus in `/afs/cern.ch/work/g/gkopp/MC_GenProduction/MonteCarlo_PrivateProduction/LLP_TDC/`.

## Production Campaign and Setup Commands
The production campaign for the [HTo2LongLivedTo4b](https://cmsweb.cern.ch/das/request?view=list&limit=50&instance=prod%2Fglobal&input=dataset+dataset%3D%2FHTo2LongLivedTo4b*%2F*%2F*) dataset is [here](https://cms-pdmv.cern.ch/mcm/requests?prepid=TSG-Run3Winter20DRPremixMiniAOD-00056&page=0&shown=127). From this, select GEN-SIM (first link in chain) or DIGI (second link in chain) and click through "Action" and "Get Test Command" (3rd picture option). This will give the full executable scripts to run. For example, the [GEN-SIM script](https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_test/HCA-Run3Winter20GS-00035) and the [DIGI script](https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_test/HCA-Run3Winter20DRPremixMiniAOD-00010) are here. 

## Generator Fragments
Generator fragments for the Higgs to 2 LLP to 4 b-quark are taken from the [official production](https://docs.google.com/spreadsheets/d/1D86SiuXDJBG0q_ObOuCRaCJA8EGp-lbjduKBwNYcz1I/edit#gid=0) request, with specific fragments saved in a [Dropbox](https://www.dropbox.com/sh/9qdwdkplf8kls5j/AAB88P-2_b7om0EUaQHcJYeXa?dl=0&lst=). These fragments were then copied to `CMSSW_11_2_0/src/Configuration/GenProduction/python/` and used to produce the python config file that is run with cmsRun (step 0).

For the neutrino gun (used to evaluate rates), the GEN-SIM of the official production was saved, linked [here](https://cmsweb.cern.ch/das/request?view=list&limit=50&instance=prod%2Fglobal&input=dataset%3D%2FRelValNuGun%2FCMSSW_11_2*%2F*). This will need to be re-processed through the digitization step with the fixed TDC simulation.

### Modifications to Scripts
For conditions, use
```
-conditions auto:phase1_2021_realistic
```
and we need to use CMSSW_11_3(2)_X_2021-01-28-1100 for now (or later, since the PR was merged Jan 27). Later we can use 11_3_0_pre3 and in 11_2_0_patch1 once the changes have been merged and integrated fully. I use 11_2_0 below since the L1 environment is rebased to this, but had to copy over files for TDC timing information.

Also need the customization of:
```
--customise_commands 'process.hcalRawDatauHTR.packHBTDC = cms.bool(False)'
```
in DIGI to save the 6 bit TDC value for trigger studies.

### Comparison to 112X RelVal steps
It is helpful to compare to the standard set of RelVal steps in 112X to troubleshoot errors in the PU mxing. These steps are found by:
```
cd CMSSW_11_2_0/src
cmsenv
runTheMatrix.py -l 11834.0 --dryRun
cd 11834.0_TTbar_14TeV+2021PU+TTbar_14TeV_TuneCP5_GenSim+DigiPU+RecoPU+HARVESTPU+Nano/
more cmdLog
```
Which shows the PU mixing DIGI cmsDriver command as:
```
cmsDriver.py step2 --conditions auto:phase1_2021_realistic --pileup_input das:/RelValMinBias_14TeV/CMSSW_11_2_0_pre8-112X_mcRun3_2021_realistic_v10-v1/GEN-SIM -n 10 --era Run3 --eventcontent FEVTDEBUGHLT -s DIGI:pdigi_valid,L1,DIGI2RAW,HLT:@relval2021 --datatier GEN-SIM-DIGI-RAW --pileup Run3_Flat55To75_PoissonOOTPU --geometry DB:Extended --filein  file:step1.root  --fileout file:step2.root
```
This is then slightly adapted for the LLP sample (filenames, adding HB TDC unpacked).

## Step 0 (GEN-SIM)
```
cd /afs/cern.ch/work/g/gkopp/MC_GenProduction/MonteCarlo_PrivateProduction/LLP_TDC
cmsrel CMSSW_11_2_0
cd CMSSW_11_2_0/src
cmsenv
git cms-init
git cms-addpkg SimCalorimetry/HcalSimAlgos SimCalorimetry/HcalSimProducers
scram b -j 8
cd ../..
voms-proxy-init --rfc --voms cms --valid 48:00
cp /tmp/x509up_u101898 /afs/cern.ch/user/g/gkopp
chmod 777 /afs/cern.ch/user/g/gkopp/x509up_u101898
kinit

EVENTS=2000

<choose relevant one of following>
condor_argu=HTo2LongLivedTo4b_MH-125_MFF-50_CTau-3000mm_TuneCP5_13TeV_pythia8_cff
condor_argu=HTo2LongLivedTo4b_MH-125_MFF-50_CTau-30000mm_TuneCP5_13TeV_pythia8_cff
condor_argu=HTo2LongLivedTo4b_MH-250_MFF-120_CTau-500mm_TuneCP5_13TeV_pythia8_cff
condor_argu=HTo2LongLivedTo4b_MH-250_MFF-120_CTau-1000mm_TuneCP5_13TeV_pythia8_cff
condor_argu=HTo2LongLivedTo4b_MH-250_MFF-120_CTau-10000mm_TuneCP5_13TeV_pythia8_cff
condor_argu=HTo2LongLivedTo4b_MH-350_MFF-160_CTau-500mm_TuneCP5_13TeV_pythia8_cff
condor_argu=HTo2LongLivedTo4b_MH-350_MFF-160_CTau-1000mm_TuneCP5_13TeV_pythia8_cff
condor_argu=HTo2LongLivedTo4b_MH-350_MFF-160_CTau-10000mm_TuneCP5_13TeV_pythia8_cff
condor_argu=HTo2LongLivedTo4b_MH-1000_MFF-450_CTau-10000mm_TuneCP5_13TeV_pythia8_cff
condor_argu=HTo2LongLivedTo4b_MH-1000_MFF-450_CTau-100000mm_TuneCP5_13TeV_pythia8_cff
condor_argu=QCD_Pt-15to7000_TuneCP5_Flat_13TeV_pythia8        
<proceed with set condor argument>

<make all configuration files at once is easier, here is the GEN SIM cfg cmsDriver command>
cmsDriver.py Configuration/GenProduction/python/$condor_argu.py --python_filename $condor_argu-1_cfg.py --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --fileout file:/eos/cms/store/group/dpg_hcal/comm_hcal/gillian/LLP_Run3/110X_TDC74pt8/$condor_argu.root --conditions auto:phase1_2021_realistic --beamspot Run3RoundOptics25ns13TeVLowSigmaZ --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(100)" --step GEN,SIM --geometry DB:Extended --era Run3 --no_exec --mc -n $EVENTS

<choose relevant one of following>
cmsRun HTo2LongLivedTo4b_MH-*_MFF-*_CTau-*mm_TuneCP5_13TeV_pythia8_cff-1_cfg.py
cmsRun QCD_Pt-15to7000_TuneCP5_Flat_13TeV_pythia8-1_cfg.py
<proceed with the processing>

<or submit Condor jobs>
condor_submit condor_*.sub
```
The condor submission uses `GEN-SIM_condor.sh`.

## Step 1 (DIGI-RAW)
```
cd CMSSW_11_2_0/src
cmsenv
scram b
cd ../..
EVENTS=2000

<choose relevant one of the condor_argu listed in the previous section>
condor_argu=*
<proceed with set condor argument>

<with PU>
cmsDriver.py step2 --python_filename $condor_argu-digi_1_cfg.py --conditions auto:phase1_2021_realistic --pileup_input das:/RelValMinBias_14TeV/CMSSW_11_2_0_pre8-112X_mcRun3_2021_realistic_v10-v1/GEN-SIM -n $EVENTS --era Run3 --eventcontent FEVTDEBUGHLT -s DIGI:pdigi_valid,L1,DIGI2RAW,HLT:@relval2021 --datatier GEN-SIM-DIGI-RAW --pileup Run3_Flat55To75_PoissonOOTPU --geometry DB:Extended --filein file:/eos/cms/store/group/dpg_hcal/comm_hcal/gillian/LLP_Run3/112X_TDC74pt8/$condor_argu.root --fileout file:/eos/cms/store/group/dpg_hcal/comm_hcal/gillian/LLP_Run3/112X_TDC74pt8/$condor_argu-digi.root --customise_commands 'process.hcalRawDatauHTR.packHBTDC = cms.bool(False)' --no_exec --mc

<no PU>
cmsDriver.py --python_filename $condor_argu-digi_noPU_1_cfg.py --eventcontent FEVTDEBUGHLT --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-DIGI-RAW --fileout file:/eos/cms/store/group/dpg_hcal/comm_hcal/gillian/LLP_Run3/112X_TDC74pt8/$condor_argu-digi_noPU.root --pileup NoPileUp --conditions auto:phase1_2021_realistic --customise_commands 'process.hcalRawDatauHTR.packHBTDC = cms.bool(False)' --step DIGI,L1,DIGI2RAW,HLT:GRun --geometry DB:Extended --filein file:/eos/cms/store/group/dpg_hcal/comm_hcal/gillian/LLP_Run3/112X_TDC74pt8/$condor_argu.root --era Run3 --no_exec --mc -n $EVENTS

./DigiConfigs.sh
cd ..
./CondorSubmit112X.sh
```
This will make the `*-digi_1_cfg.py` or `*-digi_noPU_1_cfg.py*` files that are run with `cmsRun` to produce the step 1 root files. The PU mixing file in 110X, and has 8TS. This is incompatabile with the 112X or 113X configurations unfortunately. For 112X, RelValMinBias samples are avaliable. 

Avaliable files used at various points in testing:

[1120_pre8 min bias for PU mixing](https://cmsweb.cern.ch/das/request?view=list&limit=50&instance=prod%2Fglobal&input=dataset%3D%2FRelValMinBias_14TeV%2FCMSSW_11_2_0_pre8-112X_mcRun3_2021_realistic_v10-v1%2FGEN-SIM+), this one is used for PU mixing successfully

[112X min bias for rates](https://cmsweb.cern.ch/das/request?input=dataset%3D%2FRelValMinBias_14TeV%2FCMSSW_11_2_0-112X_mcRun3_2021_realistic_v14-v1%2FGEN-SIM&instance=prod/global)

[PU premix file in 112X](https://cmsweb.cern.ch/das/request?view=list&limit=50&instance=prod%2Fglobal&input=dataset%3D%2F*%2F*112X*mcRun3*%2FPREMIX)

[112X neutrino gun](https://cmsweb.cern.ch/das/request?input=dataset%3D%2FRelValNuGun%2FCMSSW_11_2_0-112X_mcRun3_2021_realistic_v13-v1%2FGEN-SIM&instance=prod/global)

[PU premix file in 110X](https://cmsweb.cern.ch/das/request?view=list&limit=50&instance=prod%2Fglobal&input=dataset%3D%2FNeutrino_E-10_gun%2FRunIISummer17PrePremix-PURun3Winter20_110X_mcRun3_2021_realistic_v6-v2%2FPREMIX), which does not seem to work for PU since there is a difference in calo sample size between signal and this

[110X neutrino gun](https://cmsweb.cern.ch/das/request?input=dataset%3D%2FRelValNuGun%2FCMSSW_11_0_0_pre13-110X_mcRun3_2021_realistic_v6-v1%2FGEN-SIM&instance=prod/global)

Before producing the files, confirm that the TDC simulation is correct, TDC thresholds are set correctly, and CaloSamples are saved if wanted. These are done in the following files:
```
SimCalorimetry/HcalSimAlgos/src/HcalTDC.cc
SimCalorimetry/HcalSimProducers/python/hcalSimParameters_cfi.py
SimCalorimetry/HcalSimProducers/python/hcalUnsuppressedDigis_cfi.py
```
Following amplitude dependence studies, the TDC threshold is set at 74.8 such that it is right above the noise level. 

Neutrino gun (for rates) sample is made in the DIGI step, since the GEN SIM step of it is saved on DAS. A 112X PU mixing file is attempted, following the steps [here](https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_test/PPD-RunIISummer17PrePremix-00020).

## Step 2 (AOD, RECO-AODSIM)
```
cd CMSSW_11_2_0/src
cmsenv
scram b
cd ../..
EVENTS=2000

<choose relevant one of the condor_argu listed in the previous section>
condor_argu=*
<proceed with set condor argument>

cmsDriver.py step3 --python_filename $condor_argu-AOD_2_cfg.py --eventcontent RECOSIM,AODSIM --datatier GEN-SIM-RECO,AODSIM --fileout file:/eos/cms/store/group/dpg_hcal/comm_hcal/gillian/LLP_Run3/112X_TDC74pt8/$condor_argu-AOD.root --conditions auto:phase1_2021_realistic --step RAW2DIGI,L1Reco,RECO,RECOSIM,EI --geometry DB:Extended --filein file:/eos/cms/store/group/dpg_hcal/comm_hcal/gillian/LLP_Run3/112X_TDC74pt8/$condor_argu-digi.root --era Run3 --no_exec --mc -n $EVENTS 

cmsRun $condor_argu-AOD_2_cfg.py
```
This will produce 2 step 3 ROOT files, saved as `*AOD_inAODSIM.root` and `*AOD.root`. These are for use in the offline analysis comparison, using the Run 2 displaced jet (Jingyu's analysis) as a benchmark. AOD files are used as they save full precision tracking information, which is relied on in the displaced jet analysis.

### CRAB submission
Note: CRAB submissions will not work with intermediate CMSSW integration branches (only production versions), so in this case CRAB submissions won't work. Use condor instead if need to work in an IB.
The step1 files are submitted using CRAB, since DAS access is needed for the PU mixing.
```
crab submit -c submit*.py
```
for each file: `submit_MH125_ctau30000mm_digi_step1.py`, `submit_MH125_ctau3000mm_digi_step1.py`, `submit_MH250_ctau10000mm_digi_step1.py`, `submit_MH250_ctau1000mm_digi_step1.py`, `submit_QCD_digi_step1.py`, `submit_RelValNuGun_digi_step1.py`. To check the status of CRAB jobs, simply do:
```
crab status -d crab_projects/crab_*
```
where the name of the job is listed as the directory in `crab_projects`. A disk copy of data may be requested if a sample is stored on TAPE.

### Condor submissions
Condor is used to submit the step1 processing.
```
voms-proxy-init --rfc --voms cms --valid 48:00
cp /tmp/x509up_u101898 /afs/cern.ch/user/g/gkopp
chmod 777 /afs/cern.ch/user/g/gkopp/x509up_u101898
kinit
condor_submit condor_*.sub
```
Currently have an issue with the CaloSamples size between 110X (PU mixing) and 112X (signal) files that is being investigated (PU mixing files have 8TS, while signals have 10TS). Condor submissions for no PU work, and for step0.