function [NN50] = xCalcNN50(NN)
% Input:
%   NN - vector of Normal-to-normal intervals(filtered IBI) 
% Output:
%   NN50 - Scalar corresponding to the number of number of adjacent NN-intervals
%   which differs from each other by more than 50ms
    NN50 = sum(abs(diff(NN))>50);
end