function [average] = ML_DT_test_rand_loop
%Train decision tree with equal amounts of stressed and non stressed,
%where the choice for the ones used to train and the ones used to
%classify are randomed. Returns the average of all the ratios calculated
%from the amount correct.
feature_data = load('finalFeatureData.csv');

%normA = mat2gray(feature_data(:, 1:9));
%normA = [normA feature_data(:, 10)];

%feature_data = normA;

sizeMatrix = size(feature_data);

rows = sizeMatrix(1);
cols = sizeMatrix(2);

%Order the rows after the 0's and 1's
ordered = zeros(rows, cols);
count = 0;
reverseCount = rows + 1;
for i = 1:rows
    if (feature_data(i, cols) == 0)
        ordered(count+1, :) = feature_data(i, :);
        count = count + 1;
    elseif (feature_data(i, cols) == 1)
        ordered(reverseCount-1, :) = feature_data(i, :);
        reverseCount = reverseCount - 1;
    end
end

trainNum = 60;
loops = 250;
ratio = zeros(1, loops);

%Shuffle the rows but not the 0's and 1's
XY0 = ordered(1:count, :);
XY0 = XY0(randperm(size(XY0,1)), :);
XY1 = ordered(reverseCount:rows, :);
XY1 = XY1(randperm(size(XY1,1)), :);

%Separate from the last column
X = [XY0(:, 1:(cols-1)); XY1(:, 1:(cols-1))];
Y = [XY0(:, cols); XY1(:, cols)];

%Separate 0's and 1's
x0 = X(1:count, :);
x1 = X(reverseCount:rows, :);
y0 = Y(1:count);
y1 = Y(reverseCount:rows);

if (mod(trainNum, 2))
    lower = floor(trainNum/2);
    higher = ceil(trainNum/2);
else
    lower = trainNum/2;
    higher = (trainNum/2) + 1;
end

secCount = rows - reverseCount + 1;
for i = 1:loops
    %Put equal amount of 0's with 1's after shuffling
    train = [x0(1:lower, :); x1(1:lower, :)];
    class = [x0(higher:count, :); x1(higher:secCount, :)];
    
    train_ans = [y0(1:lower); y1(1:lower)];
    class_ans = [y0(higher:count); y1(higher:secCount)];
    
    %Train decision tree
    Mdl = fitctree(train, train_ans);
    
    %Get ratio
    ratio(i) = 1 - loss(Mdl,class,class_ans);
    
    %Shuffle again
    XY0 = ordered(1:count, :);
    XY0 = XY0(randperm(size(XY0,1)),:);
    XY1 = ordered(reverseCount:rows, :);
    XY1 = XY1(randperm(size(XY1,1)),:);
    
    X = [XY0(:, 1:(cols-1)); XY1(:, 1:(cols-1))];
    Y = [XY0(:, cols); XY1(:, cols)];
    
    x0 = X(1:count, :);
    x1 = X(reverseCount:rows, :);
    
    y0 = Y(1:count);
    y1 = Y(reverseCount:rows);
end

%Get the average of all ratios
average = sum(ratio, 'All')/loops;