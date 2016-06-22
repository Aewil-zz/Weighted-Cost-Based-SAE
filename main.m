% by ֣��ΰ Aewil 2016-04
clc;clear
%% ��ȡ image �� label
[ images4Train0, labels4Train0 ] = loadMNISTData( 'dataSet/train-images.idx3-ubyte',...
    'dataSet/train-labels.idx1-ubyte', 'MinMaxScaler', 0 );
images4Train = images4Train0( :, 1:6000 );
labels4Train = labels4Train0( 1:6000, 1 );
[ images4Test, labels4Test ] = loadMNISTData( 'dataSet/t10k-images.idx3-ubyte',...
    'dataSet/t10k-labels.idx1-ubyte', 'MinMaxScaler', 0 );
	
%% ���� SAEѵ��ʱ ����
architecture = [ 784 400 200 10 ]; % SAE����Ľṹ
% ���� AE��Ԥѡ���� �� BP��Ԥѡ����
preOption4SAE.option4AE.activation     = { 'reLU' };
preOption4SAE.option4AE.isSparse       = 1;
preOption4SAE.option4AE.sparseRho      = 0.01;
preOption4SAE.option4AE.sparseBeta     = 0.3;
preOption4SAE.option4AE.isDenoising    = 1;
preOption4SAE.option4AE.noiseRate      = 0.15;
preOption4SAE.option4AE.isWeightedCost = 1;

preOption4SAE.option4BP.activation  = { 'softmax' };
% �õ�SAE��Ԥѡ����
option4SAE = getSAEOption( preOption4SAE );
%% ���� SAEԤ��ʱ �Ĳ���
preOption4BPNN.activation = { 'reLU'; 'reLU'; 'softmax' };
option4BPNN = getBPNNOption( preOption4BPNN );


%% ���SAE����
if option4SAE.option4AE.isWeightedCost % ��PSO�Ż� Weighted Cost
    isDispNetwork = 0; % ��չʾ����
    isDispInfo    = 0; % ��չʾ��Ϣ
    fun = @(x) runSAEOnce( images4Train, labels4Train, ...
        images4Test, labels4Test, ... % ����
        architecture, ...
        option4SAE, option4BPNN, ...
        isDispNetwork, isDispInfo, x );
    % ����PSO��������Ⱥ��С �� ��������
    option4PSO.population = 1;
    option4PSO.iteration  = 1;
    % ��ʼʹ��PSO�Ż�SAE����
    [ optTheta, bestGlobal, bestGlobalFit ] = optWeightedCostByPSO( fun, architecture, option4PSO );
	
	disp( ['MNIST���Լ� SAE(΢�� + weighted Cost��׼ȷ��Ϊ�� ', num2str(bestGlobalFit * 100), '%'] );
    % ������������ Weighted Cost
    option4SAE.option4AE.weightedCost = bestGlobal;
else % ֱ�����SAE����
	%% ����SAEһ��
    isDispNetwork = 0; % ��չʾ����
    isDispInfo    = 1; % չʾ��Ϣ
	[ optTheta, accuracy ] = runSAEOnce( images4Train, labels4Train, ...
		images4Test, labels4Test, ... % ����
		architecture, ...
		option4SAE, option4BPNN, ...
		isDispNetwork, isDispInfo );
	
    % ��Ϊ������ isDispInfo = 1�����ԾͲ�����չʾ��
% 	disp( ['MNIST���Լ� SAE(΢����׼ȷ��Ϊ�� ', num2str(accuracy * 100), '%'] );
end

%% ��SAE����Ԥ�� ���� ��Ϊ runSAEOnce���Ѿ�Ԥ����һ�Σ���������ע�͵�
% predictLabels = predictNN( images4Test, architecture, optTheta, option4BPNN );
% accuracy = getAccuracyRate( predictLabels, labels4Test );

if exist( 'bestGlobalFit', 'var' )
    save result optTheta bestGlobalFit bestGlobal
    mail2Me( 'Finished', ['���Ϊ��' num2str(bestGlobalFit)], 'result.mat' )
else
    save result optTheta accuracy
    mail2Me( 'Finished', ['���Ϊ��' num2str(accuracy)], 'result.mat' );
end

