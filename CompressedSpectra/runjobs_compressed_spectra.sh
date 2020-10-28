#!/bin/bash

export X509_USER_PROXY=$1
voms-proxy-info -all
voms-proxy-info -all -file $1

condor_argu=$2

cd /afs/cern.ch/user/g/gkopp/nobackup/cmsdas_2020_gen/genprod_mg261_slc7/bin/MadGraph5_aMCatNLO
eval `scramv1 runtime -sh`
mkdir $condor_argu
cd $condor_argu
tar xf ../nfwLLP2002203m_slc7_amd64_gcc700_CMSSW_10_6_0_tarball.tar.xz
cp ../runcmsgrid.sh ./
NEVENTS=10000
RANDOMSEED=12345
NCPU=1
./runcmsgrid.sh $NEVENTS $RANDOMSEED $NCPU

