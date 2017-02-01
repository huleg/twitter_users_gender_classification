% Author: Max Lu
% Date: Nov 18
% Description: This is a standalone file to generate submit.txt that beats
% Baseline 1.
%
%% Load the data first, see data_preprocess.m
tic
% load('train/genders_train.mat', 'genders_train');
% load('train/images_train.mat', 'images_train');
% load('train/image_features_train.mat', 'image_features_train');
% load('train/words_train.mat', 'words_train');
% load('test/images_test.mat', 'images_test');
% load('test/image_features_test.mat', 'image_features_test');
% load('test/words_test.mat', 'words_test');
% load('coef.mat', 'coef');
% load('scores.mat', 'scores');
% load('eigens.mat', 'eigens');
% Load the data first, see prepare_data.
if exist('genders_train','var')~= 1
prepare_data;
load('train/genders_train.mat', 'genders_train');
load('train/images_train.mat', 'images_train');
load('train/image_features_train.mat', 'image_features_train');
load('train/words_train.mat', 'words_train');
load('test/images_test.mat', 'images_test');
load('test/image_features_test.mat', 'image_features_test');
load('test/words_test.mat', 'words_test');
end

% Prepare/Load PCA-ed data,  
if exist('eigens','var')~= 1
    if exist('coef.mat','file') ~= 2 
        X = [words_train, image_features_train; words_test, image_features_test]; 
        [coef, scores, eigens] = pca(X);
        save('coef.mat', 'coef');
        save('scores.mat', 'scores');
        save('eigens.mat', 'eigens');
    else 
        load('coef.mat', 'coef');
        load('scores.mat', 'scores');
        load('eigens.mat', 'eigens');
    end
end

% add lib path:
addpath('./liblinear');
toc 

%%
tic
X = [words_train, image_features_train; words_test, image_features_test];
% X = normc(X);
Y = genders_train;
% folds = 8;
[n,~] = size(words_train);

toc
trainX = scores(1:n, 1:3200);
testX = scores(n+1:size(scores,1), 1:3200);
model = train(Y, sparse(trainX), ['-s 0', 'col']);
[Yhat] = predict(ones(size(testX, 1),1), sparse(testX), model, ['-q', 'col']);
dlmwrite('submit.txt',Yhat,'\n');
toc