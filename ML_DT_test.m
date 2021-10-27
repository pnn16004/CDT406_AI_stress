%A = load('feature_data75P.csv');
%normA = mat2gray(A(:, 1:9));
%normA = [normA A(:, 10)];

function [ratio] = ML_DT_test
feature_data = load('feature_data.csv');

sizeMatrix = size(feature_data);

rows = sizeMatrix(1);
cols = sizeMatrix(2);
trainNum = 80;

feature_data = feature_data(randperm(size(feature_data,1)),:);

X = feature_data(:, 1:(cols-1));
Y = feature_data(:, cols);

train = X(1:trainNum, :);
class = X((trainNum+1):rows, :);

train_ans = Y(1:trainNum);
class_ans = Y((trainNum+1):rows);

Mdl = fitctree(train, train_ans);

label = predict(Mdl, class);

count = 0;
n = (rows-trainNum);
for i = 1:n
    if (label(i) == class_ans(i))
        count = count + 1;
    end
end


ratio = count/n;