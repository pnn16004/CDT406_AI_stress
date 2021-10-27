function [] = ML_DT_test_loop
trainingData = load('finalFeatureData.csv');

loops = 250;
allAcc = zeros(1, loops);
for n = 1:loops
    [trainedClassifier, validationAccuracy] = trainClassifier(trainingData);
    allAcc(n) = validationAccuracy;
end

minAcc = min(allAcc)
maxAcc = max(allAcc)
avgAcc = sum(allAcc, 'All')/loops
end