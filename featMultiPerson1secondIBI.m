%% Description
% Filters out IBI vectors from the HRIBI matrix provided as input. Function then provides the feature
% extraction function with IBI vectors corresponding to 1 minutes of IBI
% data. Only extracts features if there's complete measurements.
%% Input: 
%   HRIBIMat - Matrix containing HR and IBI measurements extracted
%   from video
%   noFeatures - total number of features
%% Output:
%   features - Matrix containing extracted features, each column
%   corresponds to one persons extracted features
function [features] = featMultiPerson1secondIBI(HRIBIMat, numOfFeatures)
    % extract the IBIS, simpler to work on
    % testMat = csvread('HRIBI.csv');
    %features = zeros(1, numOfFeatures);
    features = [];
    % IBI is every second column
    IBIs = HRIBIMat(:,2:2:end);
    for i=1:size(IBIs,2)
        % only consider if there's no zeroes in the column
        if(all(IBIs(i)) == true)
              for j = 1:180:size(IBIs, 1)
                    %if there's not 1 minute of IBI, then exclude
                    %measurements
                    if(((j+180) > size(IBIs, 1)))
                        break;
                    end
                    secondOfIBI = IBIs(j:j+180,i);        
                    mat = extractTimeFreqFeatures(secondOfIBI);
                    features = [features; mat];
              end
           %features(1,:) = [];
           % write features to csv file
           csvwrite(strcat('.\multiPersFeat\person_',int2str(i),'.csv'), features);
           features = [];
        end
    end   
end