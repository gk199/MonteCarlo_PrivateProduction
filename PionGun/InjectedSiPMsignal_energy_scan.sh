for energy in 0.001 0.002 0.003 0.004 0.005 0.006 0.007 0.008 0.009 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.12 0.14 0.16 0.18 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.80 0.90 1.0 1.1 1.2 1.3
do
sed -i "s/injectTestHitsEnergy = cms\.vdouble(.*/injectTestHitsEnergy = cms\.vdouble(${energy}),/" SimCalorimetry/HcalSimProducers/python/hcalUnsuppressedDigis_cfi.py
scram b -j 8
cmsRun SinglePion211_E10_step1_cfg.py
mv SinglePion211_E10_injected_step1.root Injected_HB111_tdc2pt34_E${energy/./pt}_tof_step1.root
done
hadd Injected_Energy_0pt001_to_1pt3_HB111_tdc2pt34_tof_step1.root Injected_HB111_tdc2pt34_E*pt*_tof_step1.root
