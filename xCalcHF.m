function [HF] = xCalcHF(fx, Px)
    ix = (fx>=0.15) & (fx<=0.4);
    HF = trapz(fx(ix), Px(ix));
end