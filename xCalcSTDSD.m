function [STDSD] = xCalcSTDSD(NN)
% Input: 
%   NN - Normal-to-normal intervals
% Output:
%   STDSD - The standard deviation of the averaged normal-to-normal
%   intervals
    diffNN = diff(NN);
    STDSD = std(diffNN);
end

