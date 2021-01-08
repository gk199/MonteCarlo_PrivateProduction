import FWCore.ParameterSet.Config as cms
from SimCalorimetry.HcalSimProducers.hcalSimParameters_cfi import *
from DataFormats.HcalCalibObjects.HFRecalibrationParameters_cff import *

# make a block so other modules, such as the data mixing module, can
# also run simulation

hcalSimBlock = cms.PSet(    
    hcalSimParameters,
    # whether cells with MC signal get noise added
    doNoise = cms.bool(True),
    killHE = cms.bool(False),
    HcalPreMixStage1 = cms.bool(False),
    HcalPreMixStage2 = cms.bool(False),
    # whether cells with no MC signal get an empty signal created
    # These empty signals can get noise via the doNoise flag
    doEmpty = cms.bool(True),
    doIonFeedback = cms.bool(True),
    doThermalNoise = cms.bool(True),
    doTimeSlew = cms.bool(True),
    doHFWindow = cms.bool(False),
    hitsProducer = cms.string('g4SimHits'),
    DelivLuminosity = cms.double(0),
    TestNumbering = cms.bool(False),
    doNeutralDensityFilter = cms.bool(True),
    HBDarkening = cms.bool(False),
    HEDarkening = cms.bool(False),
    HFDarkening = cms.bool(False),
    minFCToDelay=cms.double(5.), # old TC model! set to 5 for the new one
    debugCaloSamples=cms.bool(True), #was False in default
    ignoreGeantTime=cms.bool(True), #False),
    # settings for SimHit test injection
    injectTestHits = cms.bool(True), #False),
    # if no time is specified for injected hits, t = 0 will be used
    # (recommendation: enable "ignoreGeantTime" in that case to set t = tof)
    # otherwise, need 1 time value per energy value
    injectTestHitsEnergy = cms.vdouble(1.2), #0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09, 0.1, 0.12, 0.14, 0.16, 0.18, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45),
    injectTestHitsTime = cms.vdouble(),
    # format for cells: subdet, ieta, iphi, depth
    # multiple quadruplets can be specified
    # if instead only 1 value is given, 
    # it will be interpreted as an entire subdetector
    injectTestHitsCells = cms.vint32(1,1,1,1), #, 1,1,2,1, 1,1,3,1, 1,1,4,1, 1,1,5,1, 1,1,6,1, 1,1,7,1, 1,1,8,1, 1,1,9,1, 1,1,10,1, 1,1,11,1, 1,1,12,1, 1,1,13,1, 1,1,14,1, 1,1,15,1, 1,1,16,1, 1,1,17,1, 1,1,18,1, 1,1,19,1, 1,1,20,1),
    HFRecalParameterBlock = HFRecalParameterBlock,
)

from Configuration.Eras.Modifier_fastSim_cff import fastSim
fastSim.toModify( hcalSimBlock, hitsProducer=cms.string('fastSimProducer') )

from Configuration.ProcessModifiers.premix_stage1_cff import premix_stage1
premix_stage1.toModify(hcalSimBlock,
    doNoise = False,
    doEmpty = False,
    doIonFeedback = False,
    doThermalNoise = False,
    doTimeSlew = False,
    HcalPreMixStage1 = True,
)

# test numbering not used in fastsim
from Configuration.Eras.Modifier_run2_HCAL_2017_cff import run2_HCAL_2017
(run2_HCAL_2017 & ~fastSim).toModify( hcalSimBlock, TestNumbering = cms.bool(True) )

# remove HE processing for phase 2, completely put in HGCal land
from Configuration.Eras.Modifier_phase2_hgcal_cff import phase2_hgcal
phase2_hgcal.toModify(hcalSimBlock, killHE = cms.bool(True) )
