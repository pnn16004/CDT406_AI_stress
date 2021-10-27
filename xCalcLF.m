function [LF] = xCalcLF(fx, Px)
    ix = (fx>=0.04) & (fx<=0.15);
    LF = trapz(fx(ix), Px(ix));
end

