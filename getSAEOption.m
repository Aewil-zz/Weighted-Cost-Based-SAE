function option4SAE = getSAEOption( preOption4SAE, varargin )
%����SAE�Ĳ���
% by ֣��ΰ Aewil 2016-04
% ���룺SAE�����ѡ�� preOption4SAE
% ���أ�SAE�����ѡ�� option4SAE

if exist( 'preOption4SAE', 'var' )
    % �õ�AE��һЩԤѡ����
    if isfield( preOption4SAE, 'option4AE' )
        option4SAE.option4AE = getAEOption( preOption4SAE.option4AE ); 
    else
        option4SAE.option4AE = getAEOption( [] );
    end
    % �õ�BP��һЩԤѡ����
    if isfield( preOption4SAE, 'option4BP' )
        option4SAE.option4BP = getBPOption( preOption4SAE.option4BP );
    else
        option4SAE.option4BP = getBPOption( [] );
    end
else
    option4SAE.option4AE = getAEOption( [] ); % �õ�AE��һЩԤѡ����
    option4SAE.option4BP = getBPOption( [] ); % �õ�BP��һЩԤѡ����
end

end


function option4AE = getAEOption( preOption4AE )
%����AE�Ĳ���
% ���� AE�����ѡ�� preOption4AE
% ���أ�
% AE�����ѡ�option4AE
% decayLambda��		Ȩ��˥��ϵ�������������Ȩ�أ�
% activation��		��������ͣ�sigmoid��reLU��weaklyReLU��tanh��������ͣ�sigmoid��reLU��weaklyReLU��tanh
% slope��			�����ΪweaklyReLUʱ���������б�ʣ�Ĭ��0.2��

% isBatchNorm��		�Ƿ�ʹ�� Batch Normalization �� speed-upѧϰ�ٶȣ�

% isSparse��		�Ƿ�ʹ�� sparse hidden level �Ĺ���
% sparseRho��		ϡ������rho��
% sparseBeta��		ϡ���Է���Ȩ�أ�

% isDenoising��		�Ƿ�ʹ�� denoising ����
% noiseLayer��		AE����������Ĳ㣺'firstLayer' or 'allLayers'
% noiseRate��		ÿһλ��������ĸ���
% noiseMode��		���������ģʽ��'OnOff' or 'Guass'
% noiseMean��		��˹ģʽ����ֵ
% noiseSigma��		��˹ģʽ����׼��

% isWeightedCost��	�Ƿ��ÿһλ���ݵ�cost���м�Ȩ�Դ�
% weightedCost��	��Ȩcost��Ȩ��

    if isfield( preOption4AE, 'decayLambda' )
        option4AE.decayLambda = preOption4AE.decayLambda;
    else
        option4AE.decayLambda = 0.01;
    end
    if isfield( preOption4AE, 'activation' )
        option4AE.activation = preOption4AE.activation;
		if strcmp( option4AE.activation{:}, 'weaklyReLU' )
			if isfield( preOption4AE, 'slope' )
				option4AE.slope = preOption4AE.slope;
			else
				option4AE.slope = 0.2;
			end
		end
    else
        option4AE.activation = { 'sigmoid' };
    end

    % batchNorm
    if isfield( preOption4AE, 'isBatchNorm' )
        option4AE.isBatchNorm = preOption4AE.isBatchNorm;
    else
        option4AE.isBatchNorm = 0;
    end

    % sparse
    if isfield( preOption4AE, 'isSparse' )
        option4AE.isSparse = preOption4AE.isSparse;
    else
        option4AE.isSparse = 0;
    end
    if option4AE.isSparse
        if isfield( preOption4AE, 'sparseRho' )
            option4AE.sparseRho = preOption4AE.sparseRho;
        else
            option4AE.sparseRho = 0.1;
        end
        if isfield( preOption4AE, 'sparseBeta' )
            option4AE.sparseBeta = preOption4AE.sparseBeta;
        else
            option4AE.sparseBeta = 0.3;
        end
    end

    % denoising
    if isfield( preOption4AE, 'isDenoising' )
        option4AE.isDenoising = preOption4AE.isDenoising;
		if option4AE.isDenoising
			% denoisingÿһ�� �� ֻ��һ�������
			if isfield( preOption4AE, 'noiseLayer' )
				option4AE.noiseLayer = preOption4AE.noiseLayer;
			else
				option4AE.noiseLayer = 'firstLayer';
			end
			% ��������
			if isfield( preOption4AE, 'noiseRate' )
				option4AE.noiseRate = preOption4AE.noiseRate;
			else
				option4AE.noiseRate = 0.1;
			end
			% ����ģʽ����˹ �� ����
			if isfield( preOption4AE, 'noiseMode' )
				option4AE.noiseMode = preOption4AE.noiseMode;
			else
				option4AE.noiseMode = 'OnOff';
			end
			switch option4AE.noiseMode
				case 'Guass'
					if isfield( preOption4AE, 'noiseMean' )
						option4AE.noiseMean = preOption4AE.noiseMean;
					else
						option4AE.noiseMean = 0;
					end
					if isfield( preOption4AE, 'noiseSigma' )
						option4AE.noiseSigma = preOption4AE.noiseSigma;
					else
						option4AE.noiseSigma = 0.01;
					end
			end
		end
    else
        option4AE.isDenoising = 0;
    end

    % weightedCost
    if isfield( preOption4AE, 'isWeightedCost' )
        option4AE.isWeightedCost = preOption4AE.isWeightedCost;
    else
        option4AE.isWeightedCost = 0;
    end
    if option4AE.isWeightedCost
        if isfield( preOption4AE, 'weightedCost' )
            option4AE.weightedCost = preOption4AE.weightedCost;
%         else
%             error( '��Ȩcostһ��Ҫ�Լ�����Ȩ��������' );
        end
    end
end


function option4BP = getBPOption( preOption4BP )
%����BP�Ĳ���
% ���� BP�����ѡ�� preOption4BP
% ���أ�
% AE�����ѡ�option4BP
% decayLambda��	Ȩ��˥��ϵ�������������Ȩ�أ�
% activation��	��������ͣ�

% isBatchNorm��	�Ƿ�ʹ�� Batch Normalization �� speed-upѧϰ�ٶȣ�

% isDenoising��	�Ƿ�ʹ�� denoising ����
% noiseLayer��	AE����������Ĳ㣺'firstLayer' or 'allLayers'
% noiseRate��	ÿһλ��������ĸ���
% noiseMode��	���������ģʽ��'OnOff' or 'Guass'
% noiseMean��	��˹ģʽ����ֵ
% noiseSigma��	��˹ģʽ����׼��

    if isfield( preOption4BP, 'decayLambda' )
        option4BP.decayLambda = preOption4BP.decayLambda;
    else
        option4BP.decayLambda = 0.001;
    end
    if isfield( preOption4BP, 'activation' )
        option4BP.activation = preOption4BP.activation;
    else
        option4BP.activation = { 'softmax' };
    end

    % batchNorm
    if isfield( preOption4BP, 'isBatchNorm' )
        option4BP.isBatchNorm = preOption4BP.isBatchNorm;
    else
        option4BP.isBatchNorm = 0;
    end

    % denoising
    if isfield( preOption4BP, 'isDenoising' )
        option4BP.isDenoising = preOption4BP.isDenoising;
		if option4BP.isDenoising
			% denoisingÿһ�� �� ֻ��һ�������
			if isfield( preOption4BP, 'noiseLayer' )
				option4BP.noiseLayer = preOption4BP.noiseLayer;
			else
				option4BP.noiseLayer = 'firstLayer';
			end
			% ��������
			if isfield( preOption4BP, 'noiseRate' )
				option4BP.noiseRate = preOption4BP.noiseRate;
			else
				option4BP.noiseRate = 0.1;
			end
			% ����ģʽ����˹ �� ����
			if isfield( preOption4BP, 'noiseMode' )
				option4BP.noiseMode = preOption4BP.noiseMode;
			else
				option4BP.noiseMode = 'OnOff';
			end
			switch option4BP.noiseMode
				case 'Guass'
					if isfield( preOption4BP, 'noiseMean' )
						option4BP.noiseMean = preOption4BP.noiseMean;
					else
						option4BP.noiseMean = 0;
					end
					if isfield( preOption4BP, 'noiseSigma' )
						option4BP.noiseSigma = preOption4BP.noiseSigma;
					else
						option4BP.noiseSigma = 0.01;
					end
			end
		end
    else
        option4BP.isDenoising = 0;
    end
end




