% function [bpmCurr,IBI] = HR_IBI_fft(rgbAvg,totalFrame)
function [HR1, IBI1] = HRibi_fft(rgbAvg,totalFrame)
% HRf_v4(rgbAvg,totalFrame,x,y)
% Xs = x;
% Xe =y;
numTotalFrame = totalFrame;
frameRate =30;
samplingRate = 30;
numSecond = numTotalFrame/frameRate;
numImg = (numSecond*samplingRate);

% Frequnency filtering
Freq = 1:numImg;
Freq = (Freq-1)/numImg*samplingRate;

wl = 50/60; % 30 bpm
wh = 90/60; % 90 bpm

maskL = (Freq > wl & Freq < wh );
maskR = fliplr(maskL);
mask = maskL | maskR;
maskRgb = repmat(mask, 2,1);


%     rgbAvgData = rgbAvg(:,startFrame:endFrame);
rgbAvgData = rgbAvg;

% FFT
rgbAvgF = fft(rgbAvgData, [], 2);
% Temporal filtering

rgbAvgF_TF = rgbAvgF;
rgbAvgF_TF(~maskRgb) = 0;
% Convert back to time domain
rgbAvgFiltered = real(ifft(rgbAvgF_TF, [], 2));

% Energy normalization
rgbAvgFilteredVar = mean(rgbAvgFiltered.^2, 2);
rgbAvgFilteredN = rgbAvgFiltered./repmat(sqrt(rgbAvgFilteredVar), 1, totalFrame);
% the size of (rgbAvgFiltered) and size of   (repmat(sqrt(rgbAvgFilteredVar), 1, numImg)) should be same

% *****************************************
% during FFT
pc=mean(rgbAvgFilteredN);
[pks,locs]= findpeaks(pc);

% Compute bpm
numPks = length(pks);
HR1 = 60*(numPks/numSecond);


for i=1:length(locs)-1
    ibi(i)= floor(1000*(locs(i+1)-locs(i))/30);
       
end
IBI1 = mean(ibi);

% % ************************************
% % PCA Find principle component
% [U S V] = svd(rgbAvgFilteredN, 0);
% % pc = mean(V);
% 
% [pks,locs]= findpeaks(V(:,1));
% 
% numPks = length(pks);
% 
% HR2 = 60*(numPks/numSecond);
% 
% for i=1:length(locs)-1
%     ibi(i)= floor(1000*(locs(i+1)-locs(i))/30);
%        
% end
% IBI2 = mean(ibi);
% % ************************************
% % applica ICA
% Zica = myICA(rgbAvgFilteredN,3);
% pc=mean(Zica);
% 
% [pks,locs]= findpeaks(pc);
% 
% numPks = length(pks);
% 
% HR3 = 60*(numPks/numSecond);
% 
% 
% for i=1:length(locs)-1
%     ibi(i)= floor(1000*(locs(i+1)-locs(i))/30);
%        
% end
% IBI3 = mean(ibi);

end




