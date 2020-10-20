# DelayedModels
Files and instruction for generation of LLP models for delayed jet trigger

## Using MadGraph to generate parton-level events
To generate events (LHE), follow the [CMSDAS tutorial](https://twiki.cern.ch/twiki/bin/viewauth/CMS/SWGuideCMSDataAnalysisSchoolCERN2020GeneratorsExercise). This has been done in `/afs/cern.ch/user/g/gkopp/nobackup/cmsdas_2020_gen`. First, the `scalar` directory must be added as a model to define the processes. This directory was added directly to `/afs/cern.ch/user/g/gkopp/nobackup/cmsdas_2020_gen/MG5_aMC_v2_6_1/models`.

After MadGraph is started, the contents of the proc_card must be imported. These are the lines:
```
import model scalar
generate p p > psiplus psiminus , psiplus > psil l+ vl , psiminus > psil l- vl~
output <output directory>
```
The output directory is titled something like "Displaced_Model_Single_BP_200_220_3m".

Next, the appropriate param_card must be moved to the output directory. These are also found in the `cards` directory. The path to this param_card must be input to MadGraph. This is placed in the directory: `/afs/cern.ch/user/g/gkopp/nobackup/cmsdas_2020_gen/MG5_aMC_v2_6_1/Displaced_Model_Single_BP_200_220_3m/Cards/`.

Finally, the run_card can be loaded in as well, or manually updated from the default one to have 
```
10000 = nevents
0 = iseed
0.0 = time_of_flight
```
Then the generation can proceed, and will result in an LHE file. This, along with the other output files is saved in `MG5_aMC_v2_6_1/Displaced_Model_Single_BP_200_220_3m/Events/run_01/`. 

Another option: once the output directory is made and the cards are there, then the generation may be run with 
```
./bin/generate_events
```
This is equivalent to doing the generation by restarting MG5 and manually importing the cards.

For longer lifetimes, the second order loop corrections (second step of the generation) can take quite a while. 

## Gridpack Generation
For larger scale production, we will want to use gridpacks. These are archive files with all the MG5 code to produce LHE events for a process. The param, proc, and run cards must be used, as well as the model. Work in progress.

Use the proc_card created from the standalone generation, as this is set up for the correct version of MadGraph. To do so:
```
cp /afs/cern.ch/user/g/gkopp/nobackup/cmsdas_2020_gen/MG5_aMC_v2_6_1/Displaced_Model_Single_BP_200_220_3m/Cards/proc_card_mg5.dat /afs/cern.ch/user/g/gkopp/nobackup/cmsdas_2020_gen/genprod_mg261_slc7/bin/MadGraph5_aMCatNLO/nfwLLP2002203m_cards/nfwLLP2002203m_proc_card.dat
```
The `param_card` and files for the model also need to be added for the gridpack generation. This is done by editing some lines in the `gridpack_generation.sh` script, which is stored in `/afs/cern.ch/user/g/gkopp/nobackup/cmsdas_2020_gen/genprod_mg261_slc7/bin/MadGraph5_aMCatNLO/gridpack_generation.sh`.
```      
# models/scalar to models directory  
cp -r /afs/cern.ch/user/g/gkopp/nobackup/cmsdas_2020_gen/MG5_aMC_v2_6_1/models/scalar ./models/
./bin/mg5_aMC mgconfigscript
# customized param card
if [ -e $CARDSDIR/${name}_param_card.dat ]; then
   echo "copying custom param_card.dat file"      	  
   cp $CARDSDIR/${name}_param_card.dat ./Cards/param_card.dat
fi
```
The run card from the W+ example may also be copied over to the `nfwLLP2002203m_cards` directory. The only change needed is:
```
 0.0      = time_of_flight    ! Threshold to store the time of flight information
```
Then the gridpack generation is initiated with:
```
time ./gridpack_generation.sh nfwLLP2002203m nfwLLP2002203m_cards local
```
The third argument (nfwLLP2002203m) is the directory where the output is stored, and this process name must agree with the input card naming scheme ($NAME_run_card.dat, $NAME_proc_card.dat,etc...). The run, proc, and param card should be stored in `nfwLLP2002203m_cards/`. The resulting LHE file from the gridpack generation is stored:
```
/afs/cern.ch/user/g/gkopp/nobackup/cmsdas_2020_gen/genprod_mg261_slc7/bin/MadGraph5_aMCatNLO/work_LLP3m/cmsgrid_final.lhe
```

## Comparing LHE Output Files
This is done in MadAnalysis, following the CMSDAS tutorial. After launching MA, direct it to the LHE files:
```
import Displaced_Model_Single_BP_200_220_3m/Events/run_01/unweighted_events.lhe as STANDALONE
import ../genprod_mg261_slc7/bin/MadGraph5_aMCatNLO/work_LLP3m/cmsgrid_final.lhe as GRIDPACK
```
And the distributions we look at can also be defined (some suggested by the twiki, some in addition after discussion with collaborators):
```
define mu = mu+ mu-
define el = e+ e-
define lep = mu el
plot PT(lep) 100 0 100
plot N(lep) 10 0 10
plot PT(mu) 100 0 100
plot N(mu) 10 0 10
plot PT(el) 100 0 100
plot N(el) 10 0	10
plot PT(l+) 20 0 100
plot PT(mu vm) 20 0 100
plot M(mu vm) 40 40 120
plot M(el ve) 40 40 120
```
This can also be done with the file `MA_plots_LHEcomp.txt`, which lists the input commands to MadAnalysis. Events are normalized to unity with the method normalize2one referenced from [MadAnalysis 5 Arxiv paper](https://arxiv.org/pdf/1206.1599.pdf). Run with:
```
./HEPTools/madanalysis5/madanalysis5/bin/ma5 MA_plots_LHEcomp.txt
```
Plots can be seen by copying the HTML directory locally and opening in a browser:
```
scp "gkopp@lxplus.cern.ch:/afs/cern.ch/user/g/gkopp/nobackup/cmsdas_2020_gen/MG5_aMC_v2_6_1/ANALYSIS_0/Output/HTML/MadAnalysis5job_0/*" ./
```
This has the gridpack and standalone distributions overlayed, and provides a good check that both generations are proceeding as expected.

## Showering to Pythia
Comparisons between the LHE files generated with gridpack generation and standalone generation is done, and the results are plotted following the CMSDAS tutorial.

## Event Generation and Simulation, processing to Step0 and Step1
Goal: have GEN-SIM-DIGI-RAW files for the trigger studies. [Event Generation and Simulation](https://twiki.cern.ch/twiki/bin/view/CMSPublic/WorkBookChapter6) twiki has useful commands that will be useful.

## Displaced Leptons Model
This is from the model used in the [Soft displaced leptons at the LHC](https://arxiv.org/abs/2007.03708). The cards are from [A.R.'s GitHub](https://github.com/arsahasransu/SoftDisplacedLeptons/tree/master/Madgraph), and we collaborate on the model generation.

## Locations on lxplus
These files are saved in `/afs/cern.ch/work/g/gkopp/MC_GenProduction/CompressedSpectra/MadGraph` and the generation is currently done in `/afs/cern.ch/user/g/gkopp/nobackup/cmsdas_2020_gen`.
