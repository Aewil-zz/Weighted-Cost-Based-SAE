function option4BPNN = getBPNNOption( preOption4BPNN )
%����BP�Ĳ���
% by ֣��ΰ Aewil 2016-04
% ���� BP�����ѡ�� preOption4BPNN
% ���أ�
% AE�����ѡ� option4BPNN
% decayLambda��  Ȩ��˥��ϵ�������������Ȩ�أ�
% activation��   ��������ͣ�

% isBatchNorm��  �Ƿ�ʹ�� Batch Normalization �� speed-upѧϰ�ٶȣ�

% isDenoising��  �Ƿ�ʹ�� denoising ����
% noiseLayer��  	AE����������Ĳ㣺'firstLayer' or 'allLayers'
% noiseRate��    ÿһλ��������ĸ���
% noiseMode��   	���������ģʽ��'OnOff' or 'Guass'
% noiseMean��   	��˹ģʽ����ֵ
% noiseSigma��  	��˹ģʽ����׼��

if isfield( preOption4BPNN, 'decayLambda' )
	option4BPNN.decayLambda = preOption4BPNN.decayLambda;
else
	option4BPNN.decayLambda = 0.001;
end

if isfield( preOption4BPNN, 'activation' )
	option4BPNN.activation = preOption4BPNN.activation;
else
	error( '������б���������Լ�������' );
end

% batchNorm
if isfield( preOption4BPNN, 'isBatchNorm' )
	option4BPNN.isBatchNorm = preOption4BPNN.isBatchNorm;
else
	option4BPNN.isBatchNorm = 0;
end

% denoising
if isfield( option4BPNN, 'isDenoising' )
    option4BPNN.isDenoising = option4BPNN.isDenoising;
    if option4BPNN.isDenoising
        % denoisingÿһ�� �� ֻ��һ�������
        if isfield( option4BPNN, 'noiseLayer' )
            option4BPNN.noiseLayer = option4BPNN.noiseLayer;
        else
            option4BPNN.noiseLayer = 'firstLayer';
        end
        % ��������
        if isfield( option4BPNN, 'noiseRate' )
            option4BPNN.noiseRate = option4BPNN.noiseRate;
        else
            option4BPNN.noiseRate = 0.1;
        end
        % ����ģʽ����˹ �� ����
        if isfield( option4BPNN, 'noiseMode' )
            option4BPNN.noiseMode = option4BPNN.noiseMode;
        else
            option4BPNN.noiseMode = 'OnOff';
        end
        switch option4BPNN.noiseMode
            case 'Guass'
                if isfield( option4BPNN, 'noiseMean' )
                    option4BPNN.noiseMean = option4BPNN.noiseMean;
                else
                    option4BPNN.noiseMean = 0;
                end
                if isfield( option4BPNN, 'noiseSigma' )
                    option4BPNN.noiseSigma = option4BPNN.noiseSigma;
                else
                    option4BPNN.noiseSigma = 0.01;
                end
        end
    end
else
    option4BPNN.isDenoising = 0;
end

end