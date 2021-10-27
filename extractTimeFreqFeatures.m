%% Description
% Calculates the PSD of the input vector IBI, which is used to calculate
% frequency domain features. Finally, composes a vector of time- and frequency domain features using
% user-defined calculation functions. 
%% Input:
%   IBI - Vector of IBI measurements
%% Output:
%   features - Vector with calculated time- and frequency domain features

function [features] = extractTimeFreqFeatures(IBI)
%% Estimate Power Spectral Density using Lomb-Scargle Periodogram
% https://dataespresso.com/en/2019/01/30/Stress-detection-with-wearable-devices-and-Machine-Learning/
[px, fx] = plomb(IBI, 12);
    
%% Frequency domain features
features(1) = xCalcHF(fx, px);
features(2) = xCalcLF(fx, px);
features(3) = xCalcVLF(fx, px);
%% Time domain features
features(4) = xCalcMeanNN(IBI);
features(5) = xCalcNN50(IBI);
features(6) = xCalcSTDSD(IBI);
features(7) = xCalcLFHFRatio(features(1), features(2));
features(8) = xCalcSTDNN(IBI);  
features(9) = xCalcpNN50(IBI);
end