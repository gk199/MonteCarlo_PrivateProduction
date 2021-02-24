#include "SimCalorimetry/HcalSimAlgos/interface/HcalTDC.h"
#include "CalibFormats/HcalObjects/interface/HcalCalibrations.h"
#include "CalibFormats/HcalObjects/interface/HcalDbService.h"
#include "FWCore/MessageLogger/interface/MessageLogger.h"
#include "CLHEP/Random/RandGaussQ.h"

HcalTDC::HcalTDC(double threshold_currentTDC)
    : theTDCParameters(), theDbService(nullptr), threshold_currentTDC_(threshold_currentTDC), lsb(3.74) {}

HcalTDC::~HcalTDC() {}

//template <class Digi>
void HcalTDC::timing(const CaloSamples& lf, QIE11DataFrame& digi) const {
  float const TDC_Threshold(getThreshold());
  bool risingReady(true);
  int tdcBins = theTDCParameters.nbins();
  bool hasTDCValues = true;
  if (lf.preciseSize() == 0)
    hasTDCValues = false;

  for (int ibin = 0; ibin < lf.size(); ++ibin) {
    /*
    If in a given 25ns bunch/time sample, the pulse is above
    TDC_Thresh, then TDC_RisingEdge set to time when threshold
    was crossed.
    TDC_RisingEdge=0 if it was low in the last precision bin 
    on the previous bunch crossing, but above by first precision
    bin in current bunch crossing.
    TDC_RisingEdge=62 if pulse starts above threshold by end of
    previous bunch crossing and stays above threshold in current 
    bunch crossing. 
    TDC_RisingEdge=63 if the pulse never crosses the threshold.
    */
    // special codes
    // if risingReady is true, then no transition. if risingReady is false, then already transition
    int TDC_RisingEdge = (risingReady) ? theTDCParameters.noTransitionCode() : theTDCParameters.alreadyTransitionCode();
    int preciseBegin = ibin * tdcBins;
    int preciseEnd = preciseBegin + tdcBins;
    
    if (hasTDCValues) {
      for (int i = preciseBegin; i < preciseEnd; ++i) {  // go over precise data to find the TDC time value in each 25ns TS
	
	// if high at beginning and were high in previous TS (indicated by risingReady = false), give 62
        if ((!risingReady) && (i == preciseBegin) && (i != 0)) {
	  if (lf.preciseAt(i) / theTDCParameters.deltaT() > TDC_Threshold) {
            TDC_RisingEdge = theTDCParameters.alreadyTransitionCode();
	    // continue looking through sample to have chance to reset risingReady at end of TS (3rd if statement)
          } 
	  else
            risingReady = true;
        }
	
	// if haven't yet crossed threshold (indicated by risingReady = true), find TDC value
        if (risingReady) {
	  if (lf.preciseAt(i) / theTDCParameters.deltaT() > TDC_Threshold) { 
	    TDC_RisingEdge = i - preciseBegin; // TDC = time where threshold crossed
	    risingReady = false; // indicates TDC already found
	  }
	  else if (i == (preciseEnd - 1)) { // if by end of TS have not crossed threshold, give 63
	    TDC_RisingEdge = theTDCParameters.noTransitionCode();
	  }
	}
	
	// check value at end of TS, if low, reset risingReady so prepared for pulse early in next TS
        if ((!risingReady) && (i == (preciseEnd - 1))) {
          if (lf.preciseAt(i) / theTDCParameters.deltaT() < TDC_Threshold) {
            risingReady = true;
          }
        }
      }  //end of looping precise bins
    }
    
    // change packing to allow for special codes
    int packedTDC = TDC_RisingEdge;
    digi.setSample(ibin, digi[ibin].adc(), packedTDC, digi[ibin].soi());
    
  }  // loop over bunch crossing bins
}

void HcalTDC::setDbService(const HcalDbService* service) { theDbService = service; }
