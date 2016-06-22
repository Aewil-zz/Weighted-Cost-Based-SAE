% %�����õ��ļ�
% % by ֣��ΰ Aewil 2016-04
% 
% %% ��֤AE�ݶȼ������ȷ��
% % diff = checkAE( images ); % �Ѿ���֤��������ʱ�䣬�����У������������
% % disp(diff); % diffӦ�ú�С
% 
% %% ���� sparse DAE��ѵ��һ�� sparse DAE�����ع�������ԭ���ݽ��жԱ� - DAEͨ��
% clc;clear
% % �õ� loadMNISTImages��getAEOption��initializeParameters��trainAE����
% [ input, labels ] = loadMNISTData( 'dataSet/train-images.idx3-ubyte',...
%     'dataSet/train-labels.idx1-ubyte', 'MinMaxScaler', 1 );
% architecture = [ 784 196 784 ];
% % ���� AE��Ԥѡ���� �� BP��Ԥѡ����
% preOption4SAE.option4AE.isSparse    = 1;
% preOption4SAE.option4AE.isDenoising = 1;
% preOption4SAE.option4AE.activation  = { 'reLU' };
% % �õ�SAE��Ԥѡ����
% option4SAE = getSAEOption( preOption4SAE );
% option4AE = option4SAE.option4AE;
% 
% countAE = 1;
% 
% theta = initializeParameters( architecture );
% [optTheta, cost] = trainAE( input, theta, architecture, countAE, option4AE );
% 
% % ��ѵ���õ�AE���ع�������ͼƬ�������ԭʼͼƬ���жԱ�
% option4AE.activation = { 'reLU'; 'reLU' };
% predict = predictNN( input, architecture, optTheta, option4AE );
% 
% imagesPredict = reshape( predict, sqrt(size(predict, 1)), sqrt(size(predict, 1)), size(predict, 2) );
% % �Ҷ�ͼ
% figure('NumberTitle', 'off', 'Name', 'MNIST��д����ͼƬ(�ع���');
% showImagesNum = 200;
% penal         = showImagesNum * 2 / 3;
% picMatCol     = ceil( 1.5 * sqrt(penal) );
% picMatRow     = ceil( showImagesNum / picMatCol );
% for i = 1:showImagesNum
%     subplot( picMatRow, picMatCol, i, 'align' );
%     imshow( imagesPredict(:, :, i) );
% end
% % ����ͼ jet
% figure('NumberTitle', 'off', 'Name', 'MNIST��д����ͼƬ(�ع���-����ͼ');
% for i = 1:showImagesNum
%     subplot( picMatRow, picMatCol, i, 'align' );
%     imagesc( imagesPredict(:, :, i) );
%     axis off;
% end
% % ����Ȩ������w����ʾ����

%% ����õ� weight �󣬲��Լ� weight ��׼ȷ��
% ��ȡ image �� label
[ images4Train0, labels4Train0 ] = loadMNISTData( 'dataSet/train-images.idx3-ubyte',...
    'dataSet/train-labels.idx1-ubyte', 'MinMaxScaler', 0 );
images4Train = images4Train0( :, 1:6000 );
labels4Train = labels4Train0( 1:6000, 1 );
[ images4Test, labels4Test ] = loadMNISTData( 'dataSet/t10k-images.idx3-ubyte',...
    'dataSet/t10k-labels.idx1-ubyte', 'MinMaxScaler', 0 );
% ���� SAEѵ��ʱ ����
architecture = [ 784 400 200 10 ]; % SAE����Ľṹ
% ���� AE��Ԥѡ���� �� BP��Ԥѡ����
preOption4SAE.option4AE.activation     = { 'reLU' };
preOption4SAE.option4AE.isSparse       = 1;
preOption4SAE.option4AE.sparseRho      = 0.01;
preOption4SAE.option4AE.sparseBeta     = 0.3;
preOption4SAE.option4AE.isDenoising    = 0;
preOption4SAE.option4AE.noiseRate      = 0.15;
preOption4SAE.option4AE.isWeightedCost = 1;

preOption4SAE.option4BP.activation  = { 'softmax' };
% �õ�SAE��Ԥѡ����
option4SAE = getSAEOption( preOption4SAE );
% ���� SAEԤ��ʱ �Ĳ���
preOption4BPNN.activation = { 'reLU'; 'reLU'; 'softmax' };
option4BPNN = getBPNNOption( preOption4BPNN );

isDispNetwork = 0; % ��չʾ����
isDispInfo    = 0; % ��չʾ��Ϣ
accuracy = zeros( 30, 1 );
for i = 1:30
    [ optTheta, accuracy(i, 1) ] = runSAEOnce( images4Train, labels4Train, ...
        images4Test, labels4Test, ... % ����
        architecture, ...
        option4SAE, option4BPNN, ...
        isDispNetwork, isDispInfo, bestGlobal );
    
    disp( ['��' num2str(i) '�ε���' ] );
end
meanAccuracy = mean( accuracy );
stdAccuracy  = sqrt( sum((accuracy - meanAccuracy) .^ 2) / (size(accuracy, 1) - 1) );
upBound      = meanAccuracy + 1.96 * stdAccuracy;
lowBound     = meanAccuracy - 1.96 * stdAccuracy;
disp( ['���Ŷ� 95% ������£�׼ȷ��Ϊ�� ['...
    num2str(lowBound) ',' num2str(upBound) ']'] );

