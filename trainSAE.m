function theta4SAE = trainSAE( input, output, architecture, option )
%ѵ��Stacked AE
% by ֣��ΰ Aewil 2016-04

option4AE = option.option4AE; % �õ�AE��һЩԤѡ����
option4BP = option.option4BP; % �õ�BP��һЩԤѡ����

% ���� weighted cost Ȩ������
if option4AE.isWeightedCost
    weightedCost = option4AE.weightedCost;
end

% ��ʼ��������� theta4SAE�����ڴ洢�ѵ�����������Ĳ���
if strcmp( option4BP.activation, 'softmax' ) % softmax��һ�㲻��ƫ��b
    countW = architecture * [ architecture(2:end) 0 ]';
    countB = sum( architecture(2:(end - 1)) );
    theta4SAE = zeros( countW + countB, 1 );
else
    countW = architecture * [ architecture(2:end) 0 ]';
    countB = sum( architecture(2:end) );
    theta4SAE = zeros( countW + countB, 1 );
end

%% ���AE���� architecture ѵ��
startIndex = 1; % �洢�������±����
for countAE = 1 : ( length(architecture) - 2 ) % �����������BPѵ��
    % AE����Ľṹ: inputSize -> hiddenSize -> outputSize
    architecture4AE = ...
        [ architecture(countAE) ...
        architecture(countAE + 1) ...
        architecture(countAE) ];
    theta4AE  = initializeParameters( architecture4AE ); % ��������ṹ��ʼ���������
    % ���� weighted cost Ȩ������������ÿ������ṹ���޸�������С
    if option4AE.isWeightedCost
        if countAE == 1
            startWeight = 1;
            endWeight   = architecture( 1 );
            option4AE.weightedCost = weightedCost( startWeight:endWeight );
        else
            startWeight = endWeight + 1;
            endWeight   = endWeight + architecture( countAE );
            option4AE.weightedCost = weightedCost( startWeight:endWeight );
        end
    end
    
    [ optTheta, cost ] = trainAE( input, theta4AE, architecture4AE, countAE, option4AE );
%     if countAE == 1 % ���Ը���cost��������ж��Ƿ���Ҫ����ѵ��
%         [ optTheta, cost ] = trainAE( input, optTheta, architecture4AE, option4AE );
%     end
    
    disp( ['��' num2str(countAE) '��AE "' ...
        num2str(architecture4AE) '" ��ѵ������ǣ�'...
        num2str(cost)] );
    
    % �洢 AE��W1��b1 �� SAE ��
    endIndex = architecture(countAE) * architecture(countAE + 1) + ...
        architecture(countAE + 1) + startIndex - 1;% �洢�������±��յ�
    theta4SAE( startIndex : endIndex ) = optTheta( 1 : ...
        (architecture(countAE) * architecture(countAE + 1) + architecture(countAE + 1)) );
    
    % �޸�inputΪ��һ���output
    clear predict theta4AE optTheta cost
    predict = predictNN( input, architecture4AE(1:2),...
        theta4SAE( startIndex : endIndex ), option4AE );
    input = predict;
    
    startIndex = endIndex + 1;
end

%% BP��ѵ���������
architecture4BP = [ architecture(end-1) architecture(end) ]; % ���� BP ����ṹ
% ��������ṹ��ʼ�� BP�������
if strcmp( option4BP.activation, 'softmax' ) % softmax��һ�㲻��ƫ��b
    lastActiveIsSoftmax = 1;
    theta4BP = initializeParameters( architecture4BP, lastActiveIsSoftmax );
else
    theta4BP = initializeParameters( architecture4BP );
end

[ optTheta, cost ] = trainBPNN( input, output, theta4BP, architecture4BP, option4BP ); % ѵ��BP����
disp( ['���һ��BP "' num2str(architecture4BP) '" ��ѵ������ǣ�' num2str(cost)] );

theta4SAE( startIndex : end ) = optTheta;
    
end