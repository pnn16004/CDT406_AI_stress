function [meanNN] = xCalcMeanNN(NN)
% Input:
%   NN - vector of Normal-to-normal intervals(filtered IBI) 
% Output:
%   MeanNN - Mean of measured normal-to-normal intervals
    meanNN = mean(NN);
end

