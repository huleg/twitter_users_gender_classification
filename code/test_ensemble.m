% Author: Max Lu
% Date: Nov 20


%% Accuracy ensemble, see @accuracy_ensemble;

tic
% note that here we are calling cross_validation_idx; I leave data
% preparation to each classifier.
disp('Accuracy ensemble + cross-validation');
[accuracy, Ypredicted, Ytest] = cross_validation_idx(5000, 5, @accuracy_ensemble_new);
accuracy
mean(accuracy)
toc

%% incorprated certain test data 1250

tic
% note that here we are calling cross_validation_idx; I leave data
% preparation to each classifier.
disp('Accuracy ensemble + cross-validation');
[accuracy, Ypredicted, Ytest] = cross_validation_idx(6250, 5, @accuracy_ensemble_cotraining);
accuracy
mean(accuracy)
toc



%% test ensemblers:



addpath ./libsvm
load bag2.mat

train_y_test = [bag.train_y_test{1};bag.train_y_test{2};bag.train_y_test{3};bag.train_y_test{4};bag.train_y_test{5}];
ytrainscores = [bag.ytrainscores{1};bag.ytrainscores{2};bag.ytrainscores{3};bag.ytrainscores{4};bag.ytrainscores{5}];
% train ensembler
addpath ./liblinear
addpath('./DL_toolbox/util','./DL_toolbox/NN','./DL_toolbox/DBN');
addpath ./bagging
% LogRmodel = train(train_y_test, sparse(ytrainscores), ['-s 0', 'col']);
% [Yhat_lr, ~, YProb_lr] = predict(train_y_test, sparse(ytrainscores), LogRmodel, ['-q', 'col']);
% sum(Yhat_lr == train_y_test)/size(train_y_test,1)



% svmmodel = svmtrain(train_y_test, ytrainscores, '-t 2 -c 10000');
% [Yhat_svm,~, Yprob_svm] = svmpredict(train_y_test, ytrainscores, svmmodel);
% sum(Yhat_svm == train_y_test)/size(train_y_test,1)
% [accuracy, Ypredicted, Ytest] = cross_validation(train_y_test, ytrainscores, 5, @acc_logistic_regression);
% mean(accuracy)



svm_acc= [];
lr_acc = [];
bg_acc = [];
nn_acc= [];

for i = 1:5
train_x = [];    
train_y = [];
% for j = 1:5
%     if j ~= i
%     train_x = [train_x;bag.ytrainscores{j}];
%     train_y = [train_y;bag.train_y_test{j}];
%     end
% end

train_x = bag.ytrainscores{j};
train_y = bag.train_y_test{j};

% test_x = bag.ytrainscores{i};
% test_y = bag.train_y_test{i};
test_x = bag.yscores{i};
test_y = bag.test_y{i};

%  -g 0.003 -d 2
svmmodel = svmtrain(train_y, train_x, '-t 1 -c 800 -d 6');
[Yhat_svm,~, Yprob_svm] = svmpredict(test_y, test_x, svmmodel);


LogRmodel = train(train_y, sparse(train_x), ['-s 0', 'col']);
[Yhat_lr, ~, YProb_lr] = predict(test_y, sparse(test_x), LogRmodel, ['-q', 'col']);

svm_acc = [svm_acc;sum(Yhat_svm == test_y)/size(test_y,1)];
lr_acc = [lr_acc;sum(Yhat_lr == test_y)/size(test_y,1)];

s=6;
c=100;
F=0.85;%
M_lib_re=20; % number of linear models
[models_linear_re,cols_sel_linear_re]=train_bag_linear(train_x,train_y,size(train_x,2),0,0,s,c,F,M_lib_re);
[Yhat_lib_re,~,~,~]= predict_bagged_linear(models_linear_re,test_x,M_lib_re);
bg_acc = [bg_acc; sum(Yhat_lib_re == test_y)/size(test_y,1)];

i
svm_acc(end)
lr_acc(end)





printtesterr=1
X=train_x;
Y=train_y;
train_x = X;
train_y = [Y, ~Y];
% test_x = testX;
testY = test_y;

rand('state',0);
nn = nnsetup([size(X,2) 5 2]);

% nn.momentum    = 0;  
nn.activation_function = 'sigm';
% nn.weightPenaltyL2 = 1e-2;  %  L2 weight decay
nn.scaling_learningRate = 0.9;
% nn.dropoutFraction     = 0.1;
% nn.nonSparsityPenalty = 0.001;
opts.numepochs = 5;        %  Number of full sweeps through data
opts.batchsize = 1;       %  Take a mean gradient step over this many samples

train_err = [];
test_err = [];
nn.learningRate = 1;

for k = 1:3
[nn loss] = nntrain(nn, train_x, train_y, opts);
% new_feat = nnpredict(nn, train_x);

[Yhat_t prob_t] = nnpredict_my(nn, train_x);
train_err = [train_err;sum(~(Yhat_t-1) == Y)/size(train_y,1)];
k
train_err(end)

if printtesterr==1
[Yhat prob] = nnpredict_my(nn, test_x);
test_err = [test_err; sum(~(Yhat-1) == testY)/size(testY,1)];
test_err(end)
end

end

[Yhat_nn prob_nn] = nnpredict_my(nn, test_x);
nn_acc = [nn_acc;sum(~(Yhat_nn-1) == testY)/size(testY,1)];









end
[svm_acc lr_acc nn_acc bg_acc]
mean(svm_acc)
mean(lr_acc)
mean(nn_acc)
mean(bg_acc)
% [accuracy, Ypredicted, Ytest] = cross_validation(train_y_test, ytrainscores, 5, @svm_predict);
% mean(accuracy)
%%
% LogRmodel = train(train_y_test, sparse(ytrainscores), ['-s 0', 'col']);
% svmmodel = svmtrain(train_y_test, ytrainscores, '-t 2 -c 1');

% predict Yhat
yscores = [bag.yscores{1};bag.yscores{2};bag.yscores{3};bag.yscores{4};bag.yscores{5}];
test_y = [bag.test_y{1};bag.test_y{2};bag.test_y{3};bag.test_y{4};bag.test_y{5}];

[Yhat_lr, ~, YProb_lr] = predict(test_y, sparse(yscores), LogRmodel, ['-q', 'col']);
[Yhat_svm,~, Yprob_svm] = svmpredict(test_y, yscores, svmmodel);

sum(Yhat_lr == test_y)/size(test_y,1)
sum(Yhat_svm == test_y)/size(test_y,1)
%% Analysis of the raw outputs of 3 classifiers and the ground truth


load('data_fold1.mat', 'ypred_testy_fold1');
load('data_fold2.mat', 'ypred_testy_fold2');
load('data_fold3.mat', 'ypred_testy_fold3');
load('data_fold4.mat', 'ypred_testy_fold4');
load('data_fold5.mat', 'ypred_testy_fold5');

% --

nb_testy = [ypred_testy_fold1;ypred_testy_fold2;ypred_testy_fold3;ypred_testy_fold4;ypred_testy_fold5];
nb = nb_testy(:,[1:end-1]);
test_y = nb_testy(:, end);
datamat = [nb abs(nb(:,1) - nb(:,2)) nb(:,1) - nb(:,2)>0 test_y];
[n m] = size(datamat);
correct =datamat(datamat(:,5) == datamat(:,4),:);
incorrect =datamat(datamat(:,5) ~= datamat(:,4),:);


% We want to know the threshold that the classifier yields 95+% accuracy.
%   P(correct|abs(output)>thres) > 95%;
%   => N(correct, abs(output)>thres) /N(abs(output)>thres) > 0.95
P7 = [];
M4 = 0.005;
for i = linspace(0,M4,100)
    P7 = [P7;sum(correct(:,3)>i)/sum(datamat(:,3)>i)];
end
subplot(2,1,1);
plot(linspace(0,M4,100), P7);
title('Naive Bayes: P(correct | abs(output)>thres)')
% line([3;3],[min(P1);max(P1)]);
% We want to know the number of samples remained give the threshold
%   N(abs(output)>thres)/N(samples);

P8 = [];
for i = linspace(0, M4, 100)
    P8 = [P8; sum(datamat(:,3)>i)/n];
end
subplot(2,1,2);
plot(linspace(0, M4, 100), P8);
title('Naive Bayes:  P(abs(output)>thres)')
% line([3;3],[min(P2);max(P2)]);

P= []
for i = 1:11
prob = 0.89+i/100;
thres = sum(P7<prob)/size(P7,1) * M4;
proportion = P8(uint8(thres/M4*100));
P = [P;prob thres proportion];
end
disp(P)




%%
% load('ypred.mat', 'ypred');
% load('test_y.mat','test_y');

load('ypred_testy_fold1.mat','ypred_testy_fold1');
load('ypred_testy_fold2.mat','ypred_testy_fold2');
load('ypred_testy_fold3.mat','ypred_testy_fold3');
load('ypred_testy_fold4.mat','ypred_testy_fold4');
load('ypred_testy_fold5.mat','ypred_testy_fold5');


ypred_testy = [ypred_testy_fold1;ypred_testy_fold2;ypred_testy_fold3;ypred_testy_fold4;ypred_testy_fold5];
ypred = ypred_testy(:,[1:end-1]);
test_y = ypred_testy(:, end);

log = ypred(:, 1);
nn = ypred(:, [2 3]);
rf = ypred(:, 4);


% logistic regression
datamat = [log abs(log) log>0 test_y];
[n m] = size(datamat);
correct =datamat(datamat(:,3) == datamat(:,4),:);
incorrect =datamat(datamat(:,3) ~= datamat(:,4),:);
% We want to know the threshold that the classifier yields 95+% accuracy.
%   P(correct|abs(output)>thres) > 95%;
%   => N(correct, abs(output)>thres) /N(abs(output)>thres) > 0.95
P1 = [];
M1 = 10;
for i = linspace(0,M1,100)
    P1 = [P1;sum(correct(:,2)>i)/sum(datamat(:,2)>i)];
end
subplot(2,3,1);
plot(linspace(0,M1,100), P1);
title('Log Regression - P(correct | abs(output)>thres)')
line([3;3],[min(P1);max(P1)]);
% We want to know the number of samples remained give the threshold
%   N(abs(output)>thres)/N(samples);

P2 = [];

for i = linspace(0, M1, 100)
    P2 = [P2; sum(datamat(:,2)>i)/n];
end
subplot(2,3,4);
plot(linspace(0, M1, 100), P2);
title('Log Regression:  P(abs(output)>thres)')
line([3;3],[min(P2);max(P2)]);


% Neural network
datamat = [nn nn(:,1)-nn(:,2) abs(nn(:,1)-nn(:,2)) nn(:,1)>nn(:,2) test_y];
[n m] = size(datamat);
correct =datamat(datamat(:,5) == datamat(:,6),:);
incorrect =datamat(datamat(:,5) ~= datamat(:,6),:);
% We want to know the threshold that the classifier yields 95+% accuracy.
%   P(correct|abs(c1-c2)>thres) > 95%;
%   => N(correct, abs(c1-c2)>thres) /N(abs(c1-c2)>thres) > 0.95
P3 = [];
M2 = 1;
for i = linspace(0,M2,100)
    P3 = [P3;sum(correct(:,4)>i)/sum(datamat(:,4)>i)];
end
subplot(2,3,2);
plot(linspace(0,M2,100), P3);
title('Neural Net:  P(correct | abs(c1-c2)>thres)');
line([0.6;0.6],[min(P3);max(P3)]);


% We want to know the number of samples remained give the threshold
%   N(abs(c1-c2)>thres)/N(samples);

P4 = [];
for i = linspace(0, M2, 100)
    P4 = [P4; sum(datamat(:,4)>i)/n];
end
subplot(2,3,5);
plot(linspace(0, M2, 100), P4);
title('Neural Net:  P(abs(c1-c2)>thres)');
line([0.6;0.6],[min(P4);max(P4)]);

% Ensemble trees:
datamat = [rf abs(rf) rf<0 test_y];
[n m] = size(datamat);
correct =datamat(datamat(:,3) == datamat(:,4),:);
incorrect =datamat(datamat(:,3) ~= datamat(:,4),:);
% We want to know the threshold that the classifier yields 95+% accuracy.
%   P(correct|abs(output)>thres) > 95%;
%   => N(correct, abs(output)>thres) /N(abs(output)>thres) > 0.95
P5 = [];
M3 =10;
for i = linspace(0,M3,100)
    P5 = [P5;sum(correct(:,2)>i)/sum(datamat(:,2)>i)];
end
subplot(2,3,3);
plot(linspace(0,M3,100), P5);
title('Ensemble Trees:  P(correct | abs(output)>thres)');
line([2;2],[min(P5);max(P5)]);


% We want to know the number of samples remained give the threshold
%   N(abs(c1-c2)>thres)/N(samples);

P6 = [];
for i = linspace(0, M3, 100)
    P6 = [P6; sum(datamat(:,2)>i)/n];
end
subplot(2,3,6);
plot(linspace(0, M3, 100), P6);
title('Ensemble Trees:  P(abs(output)>thres)');
line([2;2],[min(P6);max(P6)]);

% Now we want to know 
% P(abs(log_output)>thres1 or abs(nn_c1-nn_c2)>thres2 or abs(rf_output)>thres3);
% P(correct | abs(log_output)>thres1 or abs(nn_c1-nn_c2)>thres2 or abs(rf_output)>thres3)
% = P(correct, abs(log_output)>thres1 or abs(nn_c1-nn_c2)>thres2 or abs(rf_output)>thres3 )/ P(abs(log_output)>thres1 or abs(nn_c1-nn_c2)>thres2 or abs(rf_output)>thres3);
% ~ P(correct, abs(log_output)>thres1 or abs(nn_c1-nn_c2)>thres2 or abs(rf_output)>thres3 )/ P(abs(log_output)>thres1 or abs(nn_c1-nn_c2)>thres2 or abs(rf_output)>thres3);
datalog = [log abs(log ) log>0 test_y];
datann = [nn nn(:,1)-nn(:,2) abs(nn(:,1)-nn(:,2)) nn(:,1)>nn(:,2) test_y];
datarf = [rf abs(rf) rf<0 test_y];


thres = [3, 0.6, 2];
log_s = (datalog(:,2) > thres(1));
nn_s = (datann(:,3) > thres(2));
rf_s = (datarf(:,2) > thres(3));



log_correct =datalog(datalog(:,3) == datalog(:,4),:);
nn_correct =datann(datann(:,5) == datann(:,6),:);
rf_correct =datarf(datarf(:,3) == datarf(:,4),:);



N95 = bsxfun(@or, bsxfun(@or, log_s, nn_s), rf_s);
p = sum(N95)/size(log_s,1);


prob = 0.91;
P2(uint8(sum(P1<prob)/size(P1,1) * 100));
P4(uint8(sum(P3<prob)/size(P3,1) * 100));
P6(uint8(sum(P5<prob)/size(P5,1) * 100));

thres = [sum(P1<prob)/size(P1,1)*M1;sum(P3<prob)/size(P3,1)*M2;sum(P5<prob)/size(P5,1)*M3];
thres
log_s = (datalog(:,2) > thres(1));
nn_s = (datann(:,3) > thres(2));
rf_s = (datarf(:,2) > thres(3));
N95 = bsxfun(@or, bsxfun(@or, log_s, nn_s), rf_s);
p = sum(N95)/size(log_s,1)

P = [];
probs= [];
thresholds = [];
for i = 1:11
prob = 0.89+i/100;
P2(uint8(sum(P1<prob)/size(P1,1) * 100));
P4(uint8(sum(P3<prob)/size(P3,1) * 100));
P6(uint8(sum(P5<prob)/size(P5,1) * 100));

thres = [sum(P1<prob)/size(P1,1)*M1;sum(P3<prob)/size(P3,1)*M2;sum(P5<prob)/size(P5,1)*M3];
log_s = (datalog(:,2) > thres(1));
nn_s = (datann(:,3) > thres(2));
rf_s = (datarf(:,2) > thres(3));
N95 = bsxfun(@or, bsxfun(@or, log_s, nn_s), rf_s);
p = sum(N95)/size(log_s,1);
P = [P;p];
prob;
thres;
probs = [probs;prob];
thresholds = [thresholds;thres'];
end
disp('  Probability  thres1   thres2   thres3   Proportion');
disp([probs thresholds P])
figure;plot(linspace(90,100,11), P);
line([91,91],[min(P),max(P)], 'Color','r');
title('The probability x to correctly predict y proportion of data with ensembled 3 classifiers');




%% Generate Submit.txt



tic
disp('Loading data..');
load('train/genders_train.mat', 'genders_train');
load('train/images_train.mat', 'images_train');
load('train/image_features_train.mat', 'image_features_train');
load('train/words_train.mat', 'words_train');
load('test/images_test.mat', 'images_test');
load('test/image_features_test.mat', 'image_features_test');
load('test/words_test.mat', 'words_test');

addpath('./liblinear');
addpath('./DL_toolbox/util','./DL_toolbox/NN','./DL_toolbox/DBN');
addpath('./libsvm');
toc

disp('Preparing data..');


% Separate the data into training set and testing set.
X = [words_train; words_train(1,:); words_train(2,:)];
Y = [genders_train; genders_train(1); genders_train(2,:)];
% train_x = X(~idx, :);
% train_y = Y(~idx);
% test_x = X(idx, :);
% test_y = Y(idx);

train_x = X;
train_y = Y;
test_x = words_test;
test_y = ones(size(words_test,1),1);
% test_y = genders_test;

% % Features selection 
% Use information gain to select the top features from BOTH word_features
% and image_features.
% The features selection is mainly for ensemble trees use.
Nfeatures = 1000;
disp('Training random forest with selected features..');
words_train_s = [words_train, image_features_train];
words_train_s = [words_train_s; words_train_s(1,:); words_train_s(2,:)];
words_test_s = [words_test, image_features_test];
genders_train_s = [genders_train; genders_train(1);genders_train(2)];
IG=calc_information_gain(genders_train,[words_train, image_features_train],[1:size([words_train, image_features_train],2)],10);
[top_igs, index]=sort(IG,'descend');

cols_sel=index(1:Nfeatures);
% prepare data for ensemble trees to train and test.
% train_x_fs = words_train_s(~idx, cols_sel);
% train_y_fs = genders_train_s(~idx);
% test_x_fs = words_train_s(idx, cols_sel);
% 

train_x_fs = words_train_s(:, cols_sel);
train_y_fs = genders_train_s(:);
test_x_fs = words_test_s(:, cols_sel);

cols_sel_knn = index(1:350);
% train_x_knn = words_train_s(~idx, cols_sel_knn);
% train_y_knn = genders_train_s(~idx); %?
% test_x_knn = words_train_s(idx, cols_sel_knn);
train_x_knn = words_train_s(:, cols_sel_knn);
train_y_knn = genders_train_s(:); %?
test_x_knn = words_test_s(:, cols_sel_knn);

% The first thing to do is to train a ensembler, currently we use logistic
% regression. To do that, we seperate the training set into 2 pieces:
% 1) The first piece to train the classifiers 
% 2) The second piece to train the ensembler,e.g. logistic regression.
% There we use $proportion for 1). and the rest for 2).
proportion = 0.8;
train_x_train=train_x(1:end*proportion,:);
train_y_train=train_y(1:end*proportion);
train_x_test = train_x(end*proportion+1:end,:);
train_y_test = train_y(end*proportion+1:end);

% Again, we have to split features selection data into two pieces.
train_x_fs_train = train_x_fs(1:end*proportion,:);
train_y_fs_train = train_y_fs(1:end*proportion);
train_x_fs_test = train_x_fs(end*proportion+1:end, :);

% knn
train_x_knn_train = train_x_knn(1:end*proportion,:);
train_y_knn_train = train_y_knn(1:end*proportion);
train_x_knn_test = train_x_knn(end*proportion+1:end, :);


toc









% **YOUR NEW CLASSIFIER GOES HERE**, please see other acc_{classifier}.m
% and follow the interface. If special data needed, please prepare the data
% first as above accordingly.
disp('Building ensemble..');
[~, yhat_log] = acc_logistic_regression(train_x_train, train_y_train, train_x_test, train_y_test);
[~, yhat_nn] = acc_neural_net(train_x_train, train_y_train, train_x_test, train_y_test);
[~, yhat_fs] = acc_ensemble_trees(train_x_fs_train, train_y_fs_train, train_x_fs_test, train_y_test);
% [~, yhat_nb] = predict_MNNB(train_x_knn_train, train_y_knn_train, train_x_knn_test, train_y_test);
% The probabilities produced by the classifiers
ypred = [yhat_log yhat_nn yhat_fs];

% Train a log_reg ensembler.
LogRens = train(train_y_test, sparse(ypred), ['-s 0', 'col']);
logRensemble = @(test_x) predict(test_y, sparse(test_x), LogRens, ['-q', 'col']);


toc

% Here, we re-train the classifiers using the whole training set (in order 
% to achieve better performance). And predict the probabilities on testing
% set

% **YOUR NEW CLASSIFIER GOES HERE**, please see other acc_{classifier}.m
% and follow the interface. If special data need, please prepare the data
% first as above accordingly.
disp('Generating real model and predicting Yhat..');
[~, yhat_log] = acc_logistic_regression(train_x, train_y, test_x, test_y);
% [~, yhat_nn] = acc_neural_net(train_x,train_y,test_x,test_y);
[~, yhat_nn] = nn_load_predict(train_x,train_y,test_x,test_y);
[~, yhat_fs] = acc_ensemble_trees(train_x_fs, train_y_fs, test_x_fs, test_y);
% [~, yhat_nb] = predict_MNNB(train_x_knn, train_y_knn, test_x_knn, test_y);
% Use trained ensembler to predict Yhat based on the probabilities
% generated from classifiers.
ypred = [yhat_log yhat_nn yhat_fs];


%  Fold 1 data, deprecated
%   Probability  thres1   thres2   thres3   Proportion
%     0.9000    0.2000    0.2100    0.3000    0.9910
%     0.9100    0.4000    0.2700    0.4000    0.9780
%     0.9200    1.0000    0.3200    0.5000    0.9580
%     0.9300    1.7000    0.4600    0.7000    0.9230
%     0.9400    2.4000    0.5000    0.9000    0.8880
%     0.9500    3.0000    0.6300    1.1000    0.8490
%     0.9600    4.6000    0.6700    1.3000    0.8020
%     0.9700    9.3000    0.7400    1.6000    0.7230
%     0.9800   10.0000    0.7500    2.0000    0.6550
%     0.9900   10.0000    0.7500    4.2000    0.4390
%     1.0000   10.0000    0.7500    5.8000    0.3800



% Fold 1-5 data:
%   Probability  thres1   thres2   thres3   Proportion
%     0.9000    0.5000    0.3100    0.3000    0.9786
%     0.9100    0.8000    0.4000    0.4000    0.9636
%     0.9200    1.4000    0.4700    0.5000    0.9406
%     0.9300    2.0000    0.5300    0.7000    0.9006
%     0.9400    2.6000    0.6100    0.8000    0.8718
%     0.9500    3.8000    0.6500    1.0000    0.8224
%     0.9600    4.6000    0.7200    1.3000    0.7508
%     0.9700    6.9000    0.7400    1.8000    0.6524
%     0.9800   10.0000    0.7500    2.8000    0.4900
%     0.9900   10.0000    0.7500    7.2000    0.2552
%     1.0000   10.0000    0.7500   10.0000    0.2446

% thres for NB
%   Probability  thres   proportion
%     0.9000    0.0019    0.6208
%     0.9100    0.0021    0.5660
%     0.9200    0.0024    0.5176
%     0.9300    0.0031    0.3707
%     0.9400    0.0040    0.2231
%     0.9500    0.0050    0.1066
%     0.9600    0.0050    0.1066
%     0.9700    0.0050    0.1066
%     0.9800    0.0050    0.1066
%     0.9900    0.0050    0.1066
%     1.0000    0.0050    0.1066


Yhat = acc_cascading(ypred, [4.6,  0.72,  1.3, 0.0024]);
Yuncertain = Yhat==-1;
Ycertain = Yhat~=-1;
Yhat_log = logRensemble(ypred);
Yhat = bsxfun(@times, Yhat, Ycertain)+bsxfun(@times, Yhat_log, Yuncertain);

Yhat = Yhat_log
YProb = ypred;
Ytest = test_y;

toc




%% analyze for the outputs of 6 classifiers:

% load('yy.mat', 'yy');
% [NB,KNN,LogR,NNet, RF, LinearR];
predY = yy(:,1:end-1);
testY = yy(:, end);
ycov = cov(predY);
HeatMap(ycov);
yycor = []
for i = 1:6
    for j = 1:i-1
%         for q = 1:j-1
            yycor = [yycor predY(:,i)*2+predY(:,j)];
%         end
    end
end

yycor = [predY];
correct= bsxfun(@minus, predY, testY) == 0;
[accuracy, Ypredicted, Ytest] = cross_validation(yycor, testY, 5, @rand_forest);
accuracy
mean(accuracy)

%% 5 folds cross-validation yields nice accuracy, see @majority_voting;

tic
% note that here we are calling cross_validation_idx; I leave data
% preparation to each classifier.
disp('Ensemble + cross-validation');
[accuracy, Ypredicted, Ytest] = cross_validation_idx(5000, 5, @majority_voting);
accuracy
mean(accuracy)
toc


%% Previous approach, deprecated. Please see the next section.

train_x = [words_train;words_train(1,:);words_train(2,:)];
train_y = [genders_train;genders_train(1,:);genders_train(2,:)];
test_x = words_test;
% test_y = 


addpath('./liblinear');
addpath('./DL_toolbox/util','./DL_toolbox/NN','./DL_toolbox/DBN');
addpath('./libsvm');

tic

proportion = 0.8;
train_x_train = train_x(1:end*proportion,:);
train_y_train = train_y(1:end*proportion);

train_x_test = train_x(end*proportion+1:end, :);
train_y_test = train_y(end*proportion+1:end, :);

train_x_all = train_x;
train_y_all = train_y;

train_x = train_x_train;
train_y = train_y_train;

% NavieBayes
% Conduct simple scaling on the data [0,1]
X = train_x;
Xcl = norml(X);

NBModel = fitNaiveBayes(Xcl,train_y);%'Distribution','mvmn');
NBPredict = @(test_x) sign(predict(NBModel,norml(test_x))-0.5);

KNNModel = fitcknn(train_x,train_y, 'NumNeighbors',11);
KNNPredict = @(test_x) sign(predict(KNNModel,test_x)-0.5);



% Linear Regression
X = train_x;
Y = train_y;
% X = X(:, :);
Wmap = inv(X'*X+eye(size(X,2))*1e-4) * (X')* Y;
LRpredict = @(test_x) sign(sigmf(test_x*Wmap, [2 0])-0.5);
% ---



% % logistc regression
X = train_x;
Y = train_y;
[n m] = size(X);
model = train(Y(:,:), sparse(X(:,:)), ['-s 0', 'col']);
LogRpredict = @(test_x) sign(predict(ones(size(test_x,1),1), sparse(test_x), model, ['-q', 'col']) - 0.5);

% % neural network
rand('state',0);
nn = nnsetup([size(X,2) 100 50 2]);
nn.learningRate = 5;
% nn.momentum    = 0;  
nn.activation_function = 'sigm';
nn.weightPenaltyL2 = 1e-2;  %  L2 weight decay
nn.scaling_learningRate = 0.9;
% nn.dropoutFraction     = 0.1;
% nn.nonSparsityPenalty = 0.001;
opts.numepochs = 100;        %  Number of full sweeps through data
opts.batchsize = 100;       %  Take a mean gradient step over this many samples

[nn loss] = nntrain(nn, train_x, [Y, ~Y], opts);
NNetPredict = @(test_x) sign(~(nnpredict(nn, test_x)-1) -0.5);


B = TreeBagger(95,train_x,train_y, 'Method', 'classification');
RFpredict = @(test_x) sign(str2double(B.predict(test_x)) - 0.5);



predictedY = [NBPredict(train_x_test),KNNPredict(train_x_test),LogRpredict(train_x_test),NNetPredict(train_x_test), RFpredict(train_x_test)];

ensembled = TreeBagger(95,predictedY,train_y_test, 'Method', 'classification');






% train again


train_x = train_x_all;
train_y = train_y_all;

% NavieBayes
% Conduct simple scaling on the data [0,1]
X = train_x;
Xcl = norml(X);

NBModel = fitNaiveBayes(Xcl,train_y);%'Distribution','mvmn');
NBPredict = @(test_x) sign(predict(NBModel,norml(test_x))-0.5);

KNNModel = fitcknn(train_x,train_y, 'NumNeighbors',11);
KNNPredict = @(test_x) sign(predict(KNNModel,test_x)-0.5);



% Linear Regression
X = train_x;
Y = train_y;
% X = X(:, 1:320);
Wmap = inv(X'*X+eye(size(X,2))*1e-4) * (X')* Y;
LRpredict = @(test_x) sign(sigmf(test_x*Wmap, [2 0])-0.5);
% ---



% % logistc regression
X = train_x;
Y = train_y;
[n m] = size(X);
model = train(Y(:,:), sparse(X(:,:)), ['-s 0', 'col']);
LogRpredict = @(test_x) sign(predict(ones(size(test_x,1),1), sparse(test_x), model, ['-q', 'col']) - 0.5);

% % neural network
rand('state',0);
nn = nnsetup([size(X,2) 100 50 2]);
nn.learningRate = 5;
% nn.momentum    = 0;  
nn.activation_function = 'sigm';
nn.weightPenaltyL2 = 1e-2;  %  L2 weight decay
nn.scaling_learningRate = 0.9;
% nn.dropoutFraction     = 0.1;
% nn.nonSparsityPenalty = 0.001;
opts.numepochs = 100;        %  Number of full sweeps through data
opts.batchsize = 100;       %  Take a mean gradient step over this many samples

[nn loss] = nntrain(nn, train_x, [Y, ~Y], opts);
NNetPredict = @(test_x) sign(~(nnpredict(nn, test_x)-1) -0.5);


B = TreeBagger(95,train_x,train_y, 'Method', 'classification');
RFpredict = @(test_x) sign(str2double(B.predict(test_x)) - 0.5);

    
predictedY_test = [NBPredict(test_x),KNNPredict(test_x),LogRpredict(test_x),NNetPredict(test_x), RFpredict(test_x)];

Yhat = str2double(ensembled.predict(predictedY_test));
toc



%% generate submit.txt, new benchmark. 90.11%




tic
disp('Loading data..');
% Load the data first, see prepare_data.
load('train/genders_train.mat', 'genders_train');
load('train/images_train.mat', 'images_train');
load('train/image_features_train.mat', 'image_features_train');
load('train/words_train.mat', 'words_train');
load('test/images_test.mat', 'images_test');
load('test/image_features_test.mat', 'image_features_test');
load('test/words_test.mat', 'words_test');
load('scores.mat', 'scores');

addpath('./liblinear');
addpath('./DL_toolbox/util','./DL_toolbox/NN','./DL_toolbox/DBN');
addpath('./libsvm');
toc

disp('Preparing data..');


proportion = 0.8;

X = [words_train; words_train(1,:); words_train(2,:)];
Y = [genders_train; genders_train(1); genders_train(2,:)];
% train_x = X(~idx, :);
% train_y = Y(~idx);
train_x = X;
train_y = Y;
% test_x = X(idx, :);
% test_y = Y(idx);



train_x_train=train_x(1:end*proportion,:);
train_y_train=train_y(1:end*proportion);
train_x_test = train_x(end*proportion+1:end,:);
train_y_test = train_y(end*proportion+1:end);

train_x = train_x_train;
train_y = train_y_train;

% % Logistic Regression
disp('Training logistic regression..');
LogRmodel = train(train_y, sparse(train_x), ['-s 0', 'col']);
% [predicted_label, accuracy, prob_estimates]
LogRpredict = @(test_x) sign(predict(ones(size(test_x,1),1), sparse(test_x), LogRmodel, ['-q', 'col']) - 0.5);



% % neural network
disp('Training neural network..');
X=train_x;
Y=train_y;
rand('state',0);
nn = nnsetup([size(X,2) 100 50 2]);
nn.learningRate = 5;
nn.activation_function = 'sigm';
nn.weightPenaltyL2 = 1e-2;  %  L2 weight decay
nn.scaling_learningRate = 0.9;
opts.numepochs = 100;        %  Number of full sweeps through data
opts.batchsize = 100;       %  Take a mean gradient step over this many samples
[nn loss] = nntrain(nn, train_x, [Y, ~Y], opts);
NNetPredict = @(test_x) sign(~(nnpredict(nn, test_x)-1) -0.5);
toc


% % Features selection + random forest
disp('Training random forest with selected features..');
words_train_s = [words_train, image_features_train];
words_train_s = [words_train_s; words_train_s(1,:); words_train_s(2,:)];
genders_train_s = [genders_train; genders_train(1);genders_train(2)];
IG=calc_information_gain(genders_train,[words_train, image_features_train],[1:size([words_train, image_features_train],2)],10);
[top_igs, index]=sort(IG,'descend');

cols_sel=index(1:1000);
% train_x_fs = words_train_s(~idx, cols_sel);
% train_y_fs = genders_train_s(~idx);
train_x_fs = words_train_s(:, cols_sel);
train_y_fs = genders_train_s;
% test_x_fs = words_train_s(idx, cols_sel);

train_x_fs_train = train_x_fs(1:end*proportion,:);
train_y_fs_train = train_y_fs(1:end*proportion);

train_x_fs_test = train_x_fs(end*proportion+1:end, :);

train_x_fs = train_x_fs_train;
train_y_fs = train_y_fs_train;


ens = fitensemble(train_x_fs,train_y_fs,'LogitBoost',200,'Tree' ); 
FSPredict = @(test_x) sign(predict(ens,test_x)-0.5);
toc

disp('Building ensemble..');



[predicted_label, accuracy, yhat_logr] = predict(train_y_test, sparse(train_x_test), LogRmodel, ['-q', 'col']);
[Yhat yhat_nn] = nnpredict_my(nn, train_x_test);
yhat_nn = yhat_nn(:,1)-yhat_nn(:,2);
[Yhat yhat_fs]= predict(ens,train_x_fs_test);

ypred = [yhat_logr yhat_nn yhat_fs];

LogRens = train(train_y_test, sparse(ypred), ['-s 0', 'col']);
% [predicted_label, accuracy, prob_estimates]
logRensemble = @(test_x) predict(ones(size(test_x,1),1), sparse(test_x), LogRens, ['-q', 'col']);

toc








disp('Generating real model..');




X = [words_train; words_train(1,:); words_train(2,:)];
Y = [genders_train; genders_train(1); genders_train(2,:)];
train_x = X;
train_y = Y;
% train_x = X(~idx, :);
% train_y = Y(~idx);
% test_x = X(idx, :);
% test_y = Y(idx);


% 
% train_x_train=train_x(1:end*proportion,:);
% train_y_train=train_y(1:end*proportion);
% train_x_test = train_x(end*proportion+1:end,:);
% train_y_test = train_y(end*proportion+1:end);
% 
% train_x = train_x_train;
% train_y = train_y_train;

% % Logistic Regression
disp('Training logistic regression..');
LogRmodel = train(train_y, sparse(train_x), ['-s 0', 'col']);
% [predicted_label, accuracy, prob_estimates]
LogRpredict = @(test_x) sign(predict(ones(size(test_x,1),1), sparse(test_x), LogRmodel, ['-q', 'col']) - 0.5);



% % neural network
disp('Training neural network..');
X=train_x;
Y=train_y;
rand('state',0);
nn = nnsetup([size(X,2) 100 50 2]);
nn.learningRate = 5;
nn.activation_function = 'sigm';
nn.weightPenaltyL2 = 1e-2;  %  L2 weight decay
nn.scaling_learningRate = 0.9;
opts.numepochs = 100;        %  Number of full sweeps through data
opts.batchsize = 100;       %  Take a mean gradient step over this many samples
[nn loss] = nntrain(nn, train_x, [Y, ~Y], opts);
NNetPredict = @(test_x) sign(~(nnpredict(nn, test_x)-1) -0.5);
toc


% % Features selection + random forest
disp('Training random forest with selected features..');
words_train_s = [words_train, image_features_train];
words_train_s = [words_train_s; words_train_s(1,:); words_train_s(2,:)];
genders_train_s = [genders_train; genders_train(1);genders_train(2)];
IG=calc_information_gain(genders_train,[words_train, image_features_train],[1:size([words_train, image_features_train],2)],10);
[top_igs, index]=sort(IG,'descend');

cols_sel=index(1:1000);
% train_x_fs = words_train_s(~idx, cols_sel);
% train_y_fs = genders_train_s(~idx);
train_x_fs = words_train_s(:, cols_sel);
train_y_fs = genders_train_s;
test_x_fs = words_train_s(:, cols_sel);



% train_x_fs_train = train_x_fs(1:end*proportion,:);
% train_y_fs_train = train_y_fs(1:end*proportion);
% 
% train_x_fs_test = train_x_fs(end*proportion+1, :);
% 
% train_x_fs = train_x_fs_train;
% train_y_fs = train_y_fs_train;

ens = fitensemble(train_x_fs,train_y_fs,'LogitBoost',200,'Tree' ); 
FSPredict = @(test_x) sign(predict(ens,test_x)-0.5);
toc



disp('Predicting Yhat..');


test_x = words_test;
test_x_fs = [words_test, image_features_test];
test_x_fs = test_x_fs(:, cols_sel);

[predicted_label, accuracy, yhat_logr] = predict(ones(size(test_x,1),1), sparse(test_x), LogRmodel, ['-q', 'col']);
[Yhat yhat_nn] = nnpredict_my(nn, test_x);
yhat_nn = yhat_nn(:,1)-yhat_nn(:,2);
[Yhat yhat_fs]= predict(ens,test_x_fs);

ypred = [yhat_logr yhat_nn yhat_fs];

% LogRens = train(train_y_test, ypred, ['-s 0', 'col']);
% [predicted_label, accuracy, prob_estimates]
% ensemble = @(test_x) predict(ones(size(test_x,1),1), sparse(test_x), LogRens, ['-q', 'col']);

Yhat = logRensemble(ypred);


