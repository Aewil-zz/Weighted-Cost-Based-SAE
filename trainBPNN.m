function [optTheta, cost] = trainBPNN( input, output, theta, architecture, option4BP )
%ѵ��BP����
% by ֣��ΰ Aewil 2016-04

% ���� calcBPBatch ���Ը��ݵ�ǰ����� cost �� gradient�����ǲ�����ȷ��
% �������Mark Schmidt�İ����Ż����� ����������l-BFGS
% Mark Schmidt (http://www.di.ens.fr/~mschmidt/Software/minFunc.html) [����ѧ��]
addpath minFunc/
options.Method = 'lbfgs'; 
options.maxIter = 100;	  % L-BFGS ������������
options.display = 'off';
% options.TolX = 1e-3;

[optTheta, cost] = minFunc( @(x) calcBPBatch( input, output, x, architecture, option4BP ), ...
    theta, options);


end