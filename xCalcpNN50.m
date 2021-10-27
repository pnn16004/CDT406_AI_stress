function [pNN50] = xCalcpNN50(NN)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    NN50 = sum(abs(diff(NN))>50);
    pNN50 = NN50/sum(NN/1000)*100;
end

