# Instructions for generating private production MC for LLP samples
Private production MC generation for LLP samples is done in order to account for the TDC simulation edits and to test TDC thresholds different than the default value of 18.7. 

## Production Campaign and Setup Commands
The production campaign for the [HTo2LongLivedTo4b](https://cmsweb.cern.ch/das/request?view=list&limit=50&instance=prod%2Fglobal&input=dataset+dataset%3D%2FHTo2LongLivedTo4b*%2F*%2F*) dataset is [here](https://cms-pdmv.cern.ch/mcm/requests?prepid=TSG-Run3Winter20DRPremixMiniAOD-00056&page=0&shown=127). From this, select GEN-SIM (first link in chain) or DIGI (second link in chain) and click through ``Action'' and ``Get Test Command'' (3rd picture option). This will give the full executable scripts to run. For example, the [GEN-SIM script](https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_test/HCA-Run3Winter20GS-00035) and the [DIGI script](https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_test/HCA-Run3Winter20DRPremixMiniAOD-00010) are here. 

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

## Generator Fragments
Generator fragments for the Higgs to 2 LLP to 4 b-quark are taken from the [official production](https://docs.google.com/spreadsheets/d/1D86SiuXDJBG0q_ObOuCRaCJA8EGp-lbjduKBwNYcz1I/edit#gid=0) request, with specific fragments saved in a [Dropbox](https://www.dropbox.com/sh/9qdwdkplf8kls5j/AAB88P-2_b7om0EUaQHcJYeXa?dl=0&lst=). 

For the neutrino gun (used to evaluate rates), the GEN-SIM of the official production was saved, linked [here](https://cmsweb.cern.ch/das/request?view=list&limit=50&instance=prod%2Fglobal&input=dataset%3D%2FRelValNuGun%2FCMSSW_11_2*%2F*). This will need to be re-processed through the digitization step with the fixed TDC simulation.