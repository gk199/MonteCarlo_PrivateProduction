#!/bin/bash

export X509_USER_PROXY=$1
voms-proxy-info -all
voms-proxy-info -all -file $1

condor_argu=$2

cd /afs/cern.ch/work/g/gkopp/MC_GenProduction/113X_LLP_TDC/CMSSW_11_3_X_2021-01-29-1100/src/
eval `scram runtime -sh`
cmsRun $condor_argu
