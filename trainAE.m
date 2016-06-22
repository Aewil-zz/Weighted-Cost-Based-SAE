function [optTheta, cost] = trainAE( input, theta, architecture, countAE, option4AE )
%ѵ��AE����
% by ֣��ΰ Aewil 2016-04

% ���� calcAEBatch ���Ը��ݵ�ǰ����� cost �� gradient�����ǲ�����ȷ��
% �������Mark Schmidt�İ����Ż����� ����������l-BFGS
% Mark Schmidt (http://www.di.ens.fr/~mschmidt/Software/minFunc.html) [����ѧ��]
addpath minFunc/
options.Method = 'lbfgs';
options.maxIter = 100;	  % L-BFGS ������������
options.display = 'off';
% options.TolX = 1e-3;

% �жϸ� countAE�� AE�Ƿ���Ҫ���noise �� ʹ��denoising����
[ isDenoising, inputCorrupted ] = denoisingSwitch( input, countAE, option4AE );
if isDenoising
	[optTheta, cost] = minFunc( @(x) calcAEBatch( input, x, architecture, option4AE, inputCorrupted ), ...
            theta, options);
else
	[optTheta, cost] = minFunc( @(x) calcAEBatch( input, x, architecture, option4AE ), ...
            theta, options);
end

end

function [ isDenoising, inputCorrupted ] = denoisingSwitch( input, countAE, option4AE )
%�жϸò�AE�Ƿ���Ҫ���noise��ʹ��denoising����
% ���� �Ƿ�isDenoising�ı�־ �� ����

% isDenoising��	�Ƿ�ʹ�� denoising ����
% noiseLayer��	AE����������Ĳ㣺'firstLayer' or 'allLayers'
% noiseRate��	ÿһλ��������ĸ���
% noiseMode��	���������ģʽ��'OnOff' or 'Guass'
% noiseMean��	��˹ģʽ����ֵ
% noiseSigma��	��˹ģʽ����׼��

    isDenoising    = 0;
    inputCorrupted = [];
    if option4AE.isDenoising
        switch option4AE.noiseLayer
            case 'firstLayer'
                if countAE == 1
                    isDenoising = 1;
                end
            case 'allLayers'
                isDenoising = 1;
            otherwise
                error( '�����AE����������' );
        end
        if isDenoising
            inputCorrupted = input;
            indexCorrupted = rand( size(input) ) < option4AE.noiseRate;
            switch option4AE.noiseMode
                case 'Guass'
                    % ��ֵΪ noiseMean����׼��Ϊ noiseSigma �ĸ�˹����
                    noise = option4AE.noiseMean + ...
                        randn( size(input) ) * option4AE.noiseSigma;
                    noise( ~indexCorrupted ) = 0;
                    inputCorrupted = inputCorrupted + noise;
                case 'OnOff'
                    inputCorrupted( indexCorrupted ) = 0;
            end
        end
    end
end

