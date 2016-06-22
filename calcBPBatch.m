function [cost,grad] = calcBPBatch( input, output, theta, architecture, option )
%���� BPNN ���ݶȱ仯�����
% by ֣��ΰ Aewil 2016-04
% input��       ѵ����������ÿһ�д���һ��������
% theta��       Ȩֵ��������[ W1(:); b1(:); W2(:); b2(:); ... ]��
% architecture: ����ṹ��ÿ�������ɵ�������
% �ṹ�� option
% decayLambda��      Ȩ��˥��ϵ�������������Ȩ�أ�
% activation��  ��������ͣ�

% isBatchNorm��   �Ƿ�ʹ�� Batch Normalization �� speed-upѧϰ�ٶȣ�

% isDenoising��   �Ƿ�ʹ�� denoising ����

% ����ȷʹ��BP�Ĺ���
% option.isBatchNorm���ù���Ŀǰ��û��
% option.isDenoising���ù���Ŀǰ��û��

m                = size( input, 2 ); % ������
layers           = length( architecture ); % �������
% ��ʼ��һЩ����
layerHiddenV     = cell( 1, layers - 1 ); % ����ʢװÿһ����������յ��ֲ�������
layerHiddenX     = cell( 1, layers );     % ����ʢװÿһ������������/��������
layerHiddenX{1}  = input;
cost.costRegul   = 0; % ������ķ�����
cost.costError   = 0; % cost function
grad             = zeros( size(theta) );
%% feed-forward�׶�
startIndex = 1; % �洢�������±����
for i = 1:( layers - 1 )
    visibleSize = architecture( i );
    hiddenSize  = architecture( i + 1 );
    
    activationFunc = str2func( option.activation{i} ); % �� ������� תΪ �����
    
    % �Ƚ� theta ת��Ϊ (W, b) �ľ���/���� ��ʽ���Ա����������initializeParameters�ļ����Ӧ��
    endIndex   = hiddenSize * visibleSize + startIndex - 1; % �洢�������±��յ�
    W          = reshape( theta(startIndex : endIndex), hiddenSize, visibleSize);
    
    if strcmp( option.activation{i}, 'softmax' ) % softmax��һ�㲻��ƫ��b
        startIndex = endIndex + 1; % �洢�������±����
        
        hiddenV = W * input;% ��� -> �õ��յ��ֲ��� V
    else
        startIndex = endIndex + 1; % �洢�������±����
        endIndex   = hiddenSize + startIndex - 1; % �洢�������±��յ�
        b          = theta( startIndex : endIndex );
        startIndex = endIndex + 1;
        
        hiddenV = bsxfun( @plus, W * input, b ); % ��� -> �õ��յ��ֲ��� V
    end
    hiddenX = activationFunc( hiddenV ); % �����
    % ����������ķ�����
    cost.costRegul = cost.costRegul + 0.5 * option.decayLambda * sum(sum(W .^ 2));
    
    clear input
    input = hiddenX;
    
    layerHiddenV{ i }     = hiddenV; % ����ʢװÿһ����������յ��ֲ�������
    layerHiddenX{ i + 1 } = input;   % ����ʢװÿһ������������/��������
end
% ��cost function + regularization
if strcmp( option.activation{layers-1}, 'softmax' ) % ��ǩ��cost
    % softmax��cost�����Ҳ�û������������Ҽ���1. ����ģ��׼ȷ��
    indexRow = output';
    indexCol = 1:m;
    index    = (indexCol - 1) .* architecture( end ) + indexRow;
    % cost.costError = sum( 1 - layerHiddenX{layers}(index) ) / m; 
	cost.costError = - sum( log(layerHiddenX{layers}(index)) ) / m; 
else % ʵֵ��cost
    cost.costError = sum( sum((output - layerHiddenX{layers}).^2 ./ 2) ) / m;
end

cost.cost      = cost.costError + cost.costRegul;
cost           = cost.cost;


%% Back Propagation �׶Σ���ʽ������
% �����һ��
activationFuncDeriv = str2func( [option.activation{layers-1}, 'Deriv'] );
if strcmp( option.activation{layers-1}, 'softmax' ) % softmax��һ������Ҫ����labels��Ϣ
    dError_dOutputV   = activationFuncDeriv( layerHiddenV{layers - 1}, output );
else
    % dError/dOutputV = dError/dOutputX * dOutputX/dOutputV
    dError_dOutputX   = -( output - layerHiddenX{layers} );
    dOutputX_dOutputV = activationFuncDeriv( layerHiddenV{layers - 1} );
    dError_dOutputV   = dError_dOutputX .* dOutputX_dOutputV;
end


% dError/dW = dError/dOutputV * dOutputV/dW
dOutputV_dW = layerHiddenX{ layers - 1 }';
dError_dW   = dError_dOutputV * dOutputV_dW;

if strcmp( option.activation{layers-1}, 'softmax' ) % softmax��һ�㲻��ƫ��b
    endIndex   = length( theta ); % �洢�������±��յ�
    startIndex = endIndex + 1; % �洢�������±����
else
    % �����ݶ� b
    endIndex   = length( theta ); % �洢�������±��յ�
    startIndex = endIndex - architecture( end )  + 1; % �洢�������±����
    dError_db  = sum( dError_dOutputV, 2 );
    grad( startIndex:endIndex ) = dError_db ./ m;
end
% �����ݶ� W
endIndex   = startIndex - 1; % �洢�������±��յ�
startIndex = endIndex - architecture( end - 1 ) * architecture( end )  + 1; % �洢�������±����
W          = reshape( theta(startIndex:endIndex), architecture( end ), architecture( end - 1 ) );
WGrad      = dError_dW ./ m + option.decayLambda * W;
grad( startIndex:endIndex ) = WGrad(:);

% ���ش� error back-propagation
for i = ( layers - 2 ):-1:1
    activationFuncDeriv = str2func( [option.activation{i}, 'Deriv'] );
    % dError/dHiddenV = dError/dHiddenX * dHiddenX/dHiddenV
    dError_dHiddenX   = W' * dError_dOutputV; % = dError/dOutputV * dOutputV/dHiddenX
    dHiddenX_dHiddenV = activationFuncDeriv( layerHiddenV{ i } );
    dError_dHiddenV   = dError_dHiddenX .* dHiddenX_dHiddenV;
    % dError/dW1 = dError/dHiddenV * dHiddenV/dW1
    dHiddenV_dW = layerHiddenX{ i }';
    dError_dW   = dError_dHiddenV * dHiddenV_dW;
    
    dError_db = sum( dError_dHiddenV, 2 );
    % �����ݶ� b
    endIndex   = startIndex - 1; % �洢�������±��յ�
    startIndex = endIndex - architecture( i + 1 )  + 1; % �洢�������±����
    % b          = theta( startIndex : endIndex );
    grad( startIndex:endIndex ) = dError_db ./ m;
    
    % �����ݶ� W
    endIndex   = startIndex - 1; % �洢�������±��յ�
    startIndex = endIndex - architecture( i ) * architecture( i + 1 )  + 1; % �洢�������±����
    W          = reshape( theta(startIndex:endIndex), architecture( i + 1 ), architecture( i ) );
    WGrad      = dError_dW ./ m + option.decayLambda * W;
    grad( startIndex:endIndex ) = WGrad(:);
    
    dError_dOutputV = dError_dHiddenV;
end

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
function soft = softmax(x)
    soft = exp(x);
    soft = bsxfun( @rdivide, soft, sum(soft, 1) );
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
function softDeriv = softmaxDeriv( x, labels )
    indexRow = labels';
    indexCol = 1:length(indexRow);
    index    = (indexCol - 1) .* max(labels) + indexRow;
    
%     softDeriv = softmax(x);
%     active   = zeros( size(x) );
%     active(index) = 1;
%     softDeriv = bsxfun( @times, softDeriv - active, softDeriv(index) );

    softDeriv = softmax(x);
    softDeriv(index) = softDeriv(index) - 1;  % �����ʹ��ԭʼcost function�ĵ���
end







