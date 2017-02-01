% Author: Max Lu
% Date: Nov 20



% note that the training and testing data are all from image;
function [Yhat] = conv_net(train_x, train_y, test_x, test_y)


% train_x = [images_train; images_train(1,:); images_train(2,:)];
% train_y = [genders_train; genders_train(1); genders_train(2)];
% test_x = images_test;

[train_r, train_g, train_b, train_grey] = convert_to_img(train_x);
[test_r, test_g, test_b, test_grey] = convert_to_img(test_x);


samples= 1:size(train_grey,3);
trainx = double(train_grey(:,:,samples));
testx = double(test_grey);
train_y_tmp = [train_y(samples), ~train_y(samples)];
trainy = double(train_y_tmp');
test_y_tmp = [test_y, ~test_y];
testy = double(test_y_tmp');

addpath('./DL_toolbox/util','./DL_toolbox/CNN');
% test_y = double(test_y');

rand('state',0)
cnn.layers = {
    struct('type', 'i') %input layer
    struct('type', 'c', 'outputmaps', 6, 'kernelsize', 5) %convolution layer
    struct('type', 's', 'scale', 2) %sub sampling layer
    struct('type', 'c', 'outputmaps', 6, 'kernelsize', 5) %convolution layer
    struct('type', 's', 'scale', 2) %subsampling layer
};
cnn = cnnsetup(cnn, trainx, trainy);

opts.alpha = 1;
opts.batchsize = 1000;
opts.numepochs = 2;

cnn = cnntrain(cnn, trainx, trainy, opts);

cnn = cnnff(cnn, test_grey);
[~, h] = max(cnn.o);
% [~, a] = max(y);

Yhat = ~(h'-1);
% for i=1:10
% cnn = cnntrain(cnn, trainx, trainy, opts);
% [er, bad] = cnntest(cnn, trainx, trainy);
% er
end