function predictLabels = predictNN( input, architecture, theta, option )
%��������ǰ��׶Σ���ʵ��Ԥ��
% by ֣��ΰ Aewil 2016-04

startIndex = 1; % �洢�������±����
for i = 1:( length(architecture) - 1 )
    visibleSize = architecture( i );
    hiddenSize  = architecture( i + 1 );
    
    %% �Ƚ� theta ת��Ϊ (W, b) �ľ���/���� ��ʽ���Ա����������initializeParameters�ļ����Ӧ��
    endIndex = hiddenSize * visibleSize + startIndex - 1; % �洢�������±��յ�
    W = reshape( theta(startIndex : endIndex), hiddenSize, visibleSize);
    
    if strcmp( option.activation{i}, 'softmax' ) % softmax����Ҫƫ��b
        startIndex = endIndex + 1; % �洢�������±����
    else
        startIndex = endIndex + 1; % �洢�������±����
        endIndex = hiddenSize + startIndex - 1; % �洢�������±��յ�
        b = theta( startIndex : endIndex );
        startIndex = endIndex + 1;
    end
    
    %% feed forward �׶�
    activationFunc = str2func( option.activation{i} ); % �� ������� תΪ �����
    % �����ز�
    if strcmp( option.activation{i}, 'softmax' ) % softmax����Ҫƫ��b
        hiddenV = W * input; % ��� -> �յ��ֲ���V
    else
        hiddenV = bsxfun( @plus, W * input, b ); % ��� -> �յ��ֲ���V
    end
    hiddenX = activationFunc( hiddenV ); % �����
    
    clear input
    input = hiddenX;
end

predictLabels = input;

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