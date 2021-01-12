#!/bin/bash

export X509_USER_PROXY=$1
voms-proxy-info -all
voms-proxy-info -all -file $1

condor_argu=$2

cd /afs/cern.ch/work/g/gkopp/MC_GenProduction/PionGun/CMSSW_11_0_2/src/
eval `scramv1 runtime -sh`
cmsRun $condor_argu

