# taken from https://github.com/cms-sw/cmssw/blob/CMSSW_10_6_X/Configuration/Generator/python/SinglePi0E10_pythia8_cfi.py
# following https://twiki.cern.ch/twiki/bin/view/CMSPublic/WorkBookGenIntro#ComposeFullSimConfig
# referencing https://twiki.cern.ch/twiki/bin/view/CMSPublic/WorkBookGeneration
import FWCore.ParameterSet.Config as cms

generator = cms.EDFilter("Pythia8EGun",
                         PGunParameters = cms.PSet(
                             ParticleID = cms.vint32(111),
                             AddAntiParticle = cms.bool(False),
                             MaxEta = cms.double(3.0),
                             MaxPhi = cms.double(3.14159265359),
                             MinEta = cms.double(-3.0),
                             MinE = cms.double(9.99),
                             MinPhi = cms.double(-3.14159265359), ## in radians
                             MaxE = cms.double(10.01)
                         ),
                         Verbosity = cms.untracked.int32(0), ## set to 1 (or greater)  for printouts
                         psethack = cms.string('single pi0 E 10'),
                         firstRun = cms.untracked.uint32(1),
                         PythiaParameters = cms.PSet(parameterSets = cms.vstring())
                     )
