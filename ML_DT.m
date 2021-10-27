function [label] = ML_DT(inputFD)
feature_data = load('feature_data.csv');

sizeMatrix = size(feature_data);

cols = sizeMatrix(2);

X = feature_data(:, 1:(cols-1));
Y = feature_data(:, cols);

Mdl = fitctree(X, Y);

label = predict(Mdl, inputFD);
end