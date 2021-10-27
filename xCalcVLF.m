function [VLF] = xCalcVLF(fx, Px)
% extract the power of VLF(0.0033-0.04hz range) of the input IBI
    ix = (fx>=0.0033) & (fx<=0.04);
    VLF = trapz(fx(ix), Px(ix));
end

