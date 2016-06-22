function [cost,grad] = calcAEBatch( input, theta, architecture, option4AE, inputCorrupted, ~ )
%����ϡ���Ա��������ݶȱ仯�����
% by ֣��ΰ Aewil 2016-04
% input��       ѵ����������ÿһ�д���һ��������
% theta��       Ȩֵ��������[ W1(:); b1(:); W2(:); b2(:); ... ]��
% architecture: ����ṹ��ÿ�������ɵ�������
% �ṹ�� option4AE
% decayLambda�� Ȩ��˥��ϵ�������������Ȩ�أ�
% activation��  ��������ͣ�

% isBatchNorm�� �Ƿ�ʹ�� Batch Normalization �� speed-upѧϰ�ٶȣ�

% isSparse��    �Ƿ�ʹ�� sparse hidden level �Ĺ���
% sparseRho��   ϡ������rho��һ�㸳ֵΪ 0.01��
% sparseBeta��  ϡ���Է���Ȩ�أ�

% isWeightedCost��	�Ƿ��ÿһλ���ݵ�cost���м�Ȩ�Դ�
% weightedCost��	��Ȩcost��Ȩ��

% inputCorrupted�� ʹ�� denoising ���� ���иò�������

% ����ȷʹ��AE�Ĺ���
% option4AE.isBatchNorm���ù���Ŀǰ��û��

visibleSize = architecture(1);
hiddenSize  = architecture(2);
% �Ƚ� theta ת��Ϊ (W1, W2, b1, b2) �ľ���/���� ��ʽ���Ա����������initializeParameters�ļ����Ӧ��
W1 = reshape( theta(1 : (hiddenSize * visibleSize)), ...
    hiddenSize, visibleSize);
b1 = theta( (hiddenSize * visibleSize + 1) : (hiddenSize * visibleSize + hiddenSize) );
W2 = reshape( theta((hiddenSize * visibleSize + hiddenSize + 1) : (2 * hiddenSize * visibleSize + hiddenSize)), ...
    visibleSize, hiddenSize);
b2 = theta( (2 * hiddenSize * visibleSize + hiddenSize + 1) : end );

m = size( input, 2 ); % ������

%% feed forward �׶�
activationFunc = str2func( option4AE.activation{:} ); % �� ������� תΪ �����
% �����ز�
if exist( 'inputCorrupted', 'var')
	hiddenV = bsxfun( @plus, W1 * inputCorrupted, b1 ); % ��� -> V
else
	hiddenV = bsxfun( @plus, W1 * input, b1 ); % ��� -> V
end
hiddenX = activationFunc( hiddenV ); % �����

% �������ز��ϡ�跣��
if option4AE.isSparse
    rhohat = sum( hiddenX, 2 ) / m;
    KL     = getKL( option4AE.sparseRho, rhohat );
    costSparse = option4AE.sparseBeta * sum( KL );
else
    costSparse = 0;
end

% �������
outputV = bsxfun( @plus, W2 * hiddenX, b2 ); % ��� -> V
outputX = activationFunc( outputV );   % �����
  
% ��cost function + regularization
if option4AE.isWeightedCost
    costError = sum( sum(option4AE.weightedCost' * (outputX - input).^2) ) / m / 2;
else
    costError = sum( sum((outputX - input).^2) ) / m / 2;
end
costRegul = 0.5 * option4AE.decayLambda * ( sum(sum(W1 .^ 2)) + sum(sum(W2 .^ 2)) );  

% ���ܵ�cost
cost = costError + costRegul + costSparse;


%% Back Propagation �׶�
activationFuncDeriv = str2func( [option4AE.activation{:}, 'Deriv'] );
% ��ʽ������
% dError/dOutputV = dError/dOutputX * dOutputX/dOutputV
if option4AE.isWeightedCost
    dError_dOutputX   = bsxfun( @times, -( input - outputX ), option4AE.weightedCost );
else
    dError_dOutputX   = -( input - outputX );
end
dOutputX_dOutputV = activationFuncDeriv( outputV );
dError_dOutputV   = dError_dOutputX .* dOutputX_dOutputV;
% dError/dW2 = dError/dOutputV * dOutputV/dW2
dOutputV_dW2 = hiddenX';
dError_dW2   = dError_dOutputV * dOutputV_dW2;

W2Grad       = dError_dW2 ./ m + option4AE.decayLambda * W2;
% dError/dHiddenV = ( dError/dHiddenX + dSparse/dHiddenX ) * dHiddenX/dHiddenV
dError_dHiddenX   = W2' * dError_dOutputV; % = dError/dOutputV * dOutputV/dHiddenX
dHiddenX_dHiddenV = activationFuncDeriv( hiddenV );
if option4AE.isSparse
    dSparse_dHiddenX = option4AE.sparseBeta .* getKLDeriv( option4AE.sparseRho, rhohat );
    dError_dHiddenV  = (dError_dHiddenX + repmat(dSparse_dHiddenX, 1, m)) .* dHiddenX_dHiddenV;
else
    dError_dHiddenV  = dError_dHiddenX .* dHiddenX_dHiddenV;
end
% dError/dW1 = dError/dHiddenV * dHiddenV/dW1
dHiddenV_dW1 = input';
dError_dW1   = dError_dHiddenV * dHiddenV_dW1;

W1Grad       = dError_dW1 ./ m + option4AE.decayLambda * W1;


% ���ڽ����ݶ���ʧ������������
% disp( '�ݶ���ʧ' );
% disp( [ 'W2�ݶȾ���ֵ��ֵ��', num2str(mean(mean(abs(W2Grad)))), ...
%     ' -> ','W1�ݶȾ���ֵ��ֵ��', num2str(mean(mean(abs(W1Grad)))) ] );
% disp( [ 'W2�ݶ����ֵ��', num2str(max(mean(W2Grad))), ...
%     ' -> ','W1�ݶ����ֵ��', num2str(max(mean(W1Grad))) ] );


% ��ƫ�õĵ���
dError_db2 = sum( dError_dOutputV, 2 );
b2Grad     = dError_db2 ./ m;
dError_db1 = sum( dError_dHiddenV, 2 );  
b1Grad     = dError_db1 ./ m;

grad = [ W1Grad(:); b1Grad(:); W2Grad(:); b2Grad(:) ];

end  


%% �����
function sigm = sigmoid(x)
    sigm = 1 ./ (1 + exp(-x));  
end
% tanh���Դ�����
function x = reLU(x)
    x(x < 0) = 0;
end
function x = almostReLU(x)
    x(x < 0) = x(x < 0) * 0.2;
end
%% ���������
function sigmDeriv = sigmoidDeriv(x)
    sigmDeriv = sigmoid(x).*(1-sigmoid(x));  
end
function tanDeriv = tanhDeriv(x)
    tanDeriv = 1 ./ cosh(x).^2; % tanh�ĵ���
end
function x = reLUDeriv(x)
    x(x < 0) = 0;
    x(x > 0) = 1;
end
function x = almostReLUDeriv(x)
    x(x < 0) = 0.2;
    x(x > 0) = 1;
end

%% KLɢ�Ⱥ���������
function KL = getKL(sparseRho,rhohat)
%KL-ɢ�Ⱥ���
    EPSILON = 1e-8; %��ֹ��0
    KL = sparseRho .* log( sparseRho ./ (rhohat + EPSILON) ) + ...
        ( 1 - sparseRho ) .* log( (1 - sparseRho) ./ (1 - rhohat + EPSILON) );  
end

function KLDeriv = getKLDeriv(sparseRho,rhohat)
%KL-ɢ�Ⱥ����ĵ���
    EPSILON = 1e-8; %��ֹ��0
    KLDeriv = ( -sparseRho ) ./ ( rhohat + EPSILON ) + ...
        ( 1 - sparseRho ) ./ ( 1 - rhohat + EPSILON );  
end