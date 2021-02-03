from CRABClient.UserUtilities import config
config = config()

config.General.requestName = 'MH125_ctau3000mm'
config.General.workArea = 'crab_projects'
config.General.transferLogs = True

config.JobType.pluginName = 'Analysis'
config.JobType.psetName = 'HTo2LongLivedTo4b_MH-125_MFF-50_CTau-3000mm_TuneCP5_13TeV_pythia8_cff-digi_1_cfg.py'
config.JobType.allowUndistributedCMSSW = True

config.Data.inputDataset = '/Neutrino_E-10_gun/RunIISummer17PrePremix-PURun3Winter20_110X_mcRun3_2021_realistic_v6-v2/PREMIX'
config.Data.inputDBS = 'global'
config.Data.splitting = 'FileBased'
config.Data.unitsPerJob = 10
config.Data.publication = True
config.Data.outputDatasetTag = 'CRAB3_MH125_ctau3000mm'

# Where the output files will be transmitted to                                                                                                                                                   
config.Data.outLFNDirBase = '/store/group/dpg_hcal/comm_hcal/gillian/LLP_Run3/113X_TDC74pt8/'
config.Site.storageSite = 'T2_CH_CERN'
