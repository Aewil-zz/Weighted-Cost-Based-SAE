clc, clear;

% ��������
[ images4Train, labels4Train ] = loadMNISTData( 'dataSet/train-images.idx3-ubyte',...
    'dataSet/train-labels.idx1-ubyte', 'MinMaxScaler', 0 );

% ��� ����AE�ݶȵ�׼ȷ��
[diff, numGradient, grad] = checkAE(images4Train);
fprintf(['AE�м����ݶȵķ�����������ֵ�����Ĳ����ԣ�'...
    num2str(mean(abs(numGradient - grad)))...
    ' �� ' num2str(diff) '\n']);

% ��� ����BP�ݶȵ�׼ȷ��
[diff, numGradient, grad] = checkBP(images4Train, labels4Train);
fprintf(['AE�м����ݶȵķ�����������ֵ�����Ĳ����ԣ�'...
    num2str(mean(abs(numGradient - grad)))...
    ' �� ' num2str(diff) '\n']);