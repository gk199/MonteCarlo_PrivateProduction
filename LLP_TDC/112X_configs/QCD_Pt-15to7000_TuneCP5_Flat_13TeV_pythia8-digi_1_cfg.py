# Auto generated configuration file
# using: 
# Revision: 1.19 
# Source: /local/reps/CMSSW/CMSSW/Configuration/Applications/python/ConfigBuilder.py,v 
# with command line options: step2 --python_filename QCD_Pt-15to7000_TuneCP5_Flat_13TeV_pythia8-digi_1_cfg.py --conditions auto:phase1_2021_realistic --pileup_input das:/RelValMinBias_14TeV/CMSSW_11_2_0_pre8-112X_mcRun3_2021_realistic_v10-v1/GEN-SIM -n 2000 --era Run3 --eventcontent FEVTDEBUGHLT -s DIGI:pdigi_valid,L1,DIGI2RAW,HLT:@relval2021 --datatier GEN-SIM-DIGI-RAW --pileup Run3_Flat55To75_PoissonOOTPU --geometry DB:Extended --filein file:/eos/cms/store/group/dpg_hcal/comm_hcal/gillian/LLP_Run3/112X_TDC74pt8/QCD_Pt-15to7000_TuneCP5_Flat_13TeV_pythia8.root --fileout file:/eos/cms/store/group/dpg_hcal/comm_hcal/gillian/LLP_Run3/112X_TDC74pt8/QCD_Pt-15to7000_TuneCP5_Flat_13TeV_pythia8-digi.root --customise_commands process.hcalRawDatauHTR.packHBTDC = cms.bool(False) --no_exec --mc
import FWCore.ParameterSet.Config as cms

from Configuration.Eras.Era_Run3_cff import Run3

process = cms.Process('HLT',Run3)

# import of standard configurations
process.load('Configuration.StandardSequences.Services_cff')
process.load('SimGeneral.HepPDTESSource.pythiapdt_cfi')
process.load('FWCore.MessageService.MessageLogger_cfi')
process.load('Configuration.EventContent.EventContent_cff')
process.load('SimGeneral.MixingModule.mix_Run3_Flat55To75_PoissonOOTPU_cfi')
process.load('Configuration.StandardSequences.GeometryRecoDB_cff')
process.load('Configuration.StandardSequences.MagneticField_cff')
process.load('Configuration.StandardSequences.Digi_cff')
process.load('Configuration.StandardSequences.SimL1Emulator_cff')
process.load('Configuration.StandardSequences.DigiToRaw_cff')
process.load('HLTrigger.Configuration.HLT_GRun_cff')
process.load('Configuration.StandardSequences.EndOfProcess_cff')
process.load('Configuration.StandardSequences.FrontierConditions_GlobalTag_cff')

process.maxEvents = cms.untracked.PSet(
    input = cms.untracked.int32(2000),
    output = cms.optional.untracked.allowed(cms.int32,cms.PSet)
)

# Input source
process.source = cms.Source("PoolSource",
    dropDescendantsOfDroppedBranches = cms.untracked.bool(False),
    fileNames = cms.untracked.vstring('file:/eos/cms/store/group/dpg_hcal/comm_hcal/gillian/LLP_Run3/112X_TDC74pt8/QCD_Pt-15to7000_TuneCP5_Flat_13TeV_pythia8.root'),
    inputCommands = cms.untracked.vstring(
        'keep *', 
        'drop *_genParticles_*_*', 
        'drop *_genParticlesForJets_*_*', 
        'drop *_kt4GenJets_*_*', 
        'drop *_kt6GenJets_*_*', 
        'drop *_iterativeCone5GenJets_*_*', 
        'drop *_ak4GenJets_*_*', 
        'drop *_ak7GenJets_*_*', 
        'drop *_ak8GenJets_*_*', 
        'drop *_ak4GenJetsNoNu_*_*', 
        'drop *_ak8GenJetsNoNu_*_*', 
        'drop *_genCandidatesForMET_*_*', 
        'drop *_genParticlesForMETAllVisible_*_*', 
        'drop *_genMetCalo_*_*', 
        'drop *_genMetCaloAndNonPrompt_*_*', 
        'drop *_genMetTrue_*_*', 
        'drop *_genMetIC5GenJs_*_*'
    ),
    secondaryFileNames = cms.untracked.vstring()
)

process.options = cms.untracked.PSet(
    FailPath = cms.untracked.vstring(),
    IgnoreCompletely = cms.untracked.vstring(),
    Rethrow = cms.untracked.vstring(),
    SkipEvent = cms.untracked.vstring(),
    allowUnscheduled = cms.obsolete.untracked.bool,
    canDeleteEarly = cms.untracked.vstring(),
    emptyRunLumiMode = cms.obsolete.untracked.string,
    eventSetup = cms.untracked.PSet(
        forceNumberOfConcurrentIOVs = cms.untracked.PSet(
            allowAnyLabel_=cms.required.untracked.uint32
        ),
        numberOfConcurrentIOVs = cms.untracked.uint32(1)
    ),
    fileMode = cms.untracked.string('FULLMERGE'),
    forceEventSetupCacheClearOnNewRun = cms.untracked.bool(False),
    makeTriggerResults = cms.obsolete.untracked.bool,
    numberOfConcurrentLuminosityBlocks = cms.untracked.uint32(1),
    numberOfConcurrentRuns = cms.untracked.uint32(1),
    numberOfStreams = cms.untracked.uint32(0),
    numberOfThreads = cms.untracked.uint32(1),
    printDependencies = cms.untracked.bool(False),
    sizeOfStackForThreadsInKB = cms.optional.untracked.uint32,
    throwIfIllegalParameter = cms.untracked.bool(True),
    wantSummary = cms.untracked.bool(False)
)

# Production Info
process.configurationMetadata = cms.untracked.PSet(
    annotation = cms.untracked.string('step2 nevts:2000'),
    name = cms.untracked.string('Applications'),
    version = cms.untracked.string('$Revision: 1.19 $')
)

# Output definition

process.FEVTDEBUGHLToutput = cms.OutputModule("PoolOutputModule",
    dataset = cms.untracked.PSet(
        dataTier = cms.untracked.string('GEN-SIM-DIGI-RAW'),
        filterName = cms.untracked.string('')
    ),
    fileName = cms.untracked.string('file:/eos/cms/store/group/dpg_hcal/comm_hcal/gillian/LLP_Run3/112X_TDC74pt8/QCD_Pt-15to7000_TuneCP5_Flat_13TeV_pythia8-digi.root'),
    outputCommands = process.FEVTDEBUGHLTEventContent.outputCommands,
    splitLevel = cms.untracked.int32(0)
)

# Additional output definition

# Other statements
process.mix.input.fileNames = cms.untracked.vstring(['/store/relval/CMSSW_11_2_0_pre8/RelValMinBias_14TeV/GEN-SIM/112X_mcRun3_2021_realistic_v10-v1/00000/33b2fbd9-2544-44af-8652-c9a19edfa400.root', '/store/relval/CMSSW_11_2_0_pre8/RelValMinBias_14TeV/GEN-SIM/112X_mcRun3_2021_realistic_v10-v1/00000/5ac1ea44-a5e0-4454-8945-45fd29c2947f.root', '/store/relval/CMSSW_11_2_0_pre8/RelValMinBias_14TeV/GEN-SIM/112X_mcRun3_2021_realistic_v10-v1/00000/932b9bde-6ae4-44cb-b1db-66dab83ab7d1.root', '/store/relval/CMSSW_11_2_0_pre8/RelValMinBias_14TeV/GEN-SIM/112X_mcRun3_2021_realistic_v10-v1/00000/936b7b11-5eec-4f97-83ff-48be106b100d.root', '/store/relval/CMSSW_11_2_0_pre8/RelValMinBias_14TeV/GEN-SIM/112X_mcRun3_2021_realistic_v10-v1/00000/ae4379b2-d002-4adc-a168-e782ee296f91.root', '/store/relval/CMSSW_11_2_0_pre8/RelValMinBias_14TeV/GEN-SIM/112X_mcRun3_2021_realistic_v10-v1/00000/f052be2f-f604-48e6-b484-1e412f0391f6.root'])
process.mix.digitizers = cms.PSet(process.theDigitizersValid)
from Configuration.AlCa.GlobalTag import GlobalTag
process.GlobalTag = GlobalTag(process.GlobalTag, 'auto:phase1_2021_realistic', '')

# Path and EndPath definitions
process.digitisation_step = cms.Path(process.pdigi_valid)
process.L1simulation_step = cms.Path(process.SimL1Emulator)
process.digi2raw_step = cms.Path(process.DigiToRaw)
process.endjob_step = cms.EndPath(process.endOfProcess)
process.FEVTDEBUGHLToutput_step = cms.EndPath(process.FEVTDEBUGHLToutput)

# Schedule definition
process.schedule = cms.Schedule(process.digitisation_step,process.L1simulation_step,process.digi2raw_step)
process.schedule.extend(process.HLTSchedule)
process.schedule.extend([process.endjob_step,process.FEVTDEBUGHLToutput_step])
from PhysicsTools.PatAlgos.tools.helpers import associatePatAlgosToolsTask
associatePatAlgosToolsTask(process)

# customisation of the process.

# Automatic addition of the customisation function from HLTrigger.Configuration.customizeHLTforMC
from HLTrigger.Configuration.customizeHLTforMC import customizeHLTforMC 

#call to customisation function customizeHLTforMC imported from HLTrigger.Configuration.customizeHLTforMC
process = customizeHLTforMC(process)

# End of customisation functions


# Customisation from command line

process.hcalRawDatauHTR.packHBTDC = cms.bool(False)
# Add early deletion of temporary data products to reduce peak memory need
from Configuration.StandardSequences.earlyDeleteSettings_cff import customiseEarlyDelete
process = customiseEarlyDelete(process)
# End adding early deletion
