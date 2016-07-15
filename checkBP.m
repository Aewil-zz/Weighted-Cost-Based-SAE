function [diff, numGradient, grad] = checkBP(images, labels)
%���ڼ��sparseAutoencoderEpoch�������õ����ݶ�grad�Ƿ���Ч
% by ֣��ΰ Aewil 2016-04
% ��������ֵ�����ݶȵķ����õ��ݶ�numGradient����������
% ��sparseAutoencoderEpoch��������ѧ�����������õ����ݶȣ��ܿ죩���бȽ�
% �õ������ݶ�������ŷʽ�����С��Ӧ�÷ǳ�֮С�Ŷԣ�

image = images(:, 1:1);% ��Ϊ������������Բų�ȡһ�����������ͼ��theta��308308ά����
label = labels(1, 1);

architecture = [ 784 196 10 ]; % AE����Ľṹ: inputSize -> hiddenSize -> outputSize
lastActiveIsSoftmax = 1;
theta = initializeParameters(architecture,...
    lastActiveIsSoftmax); % ��������ṹ��ʼ���������

option.activation  = { 'sigmoid', 'softmax' };
option.isSparse    = 0;
option.sparseRho   = 0.01;
option.sparseBeta  = 3;
option.isDenoising = 0;
option.decayLambda = 1;
% option4AE.activation = { 'softmax' };
% option4AE.activation = { 'sigmoid'; 'sigmoid'; 'softmax' };


% ��������
[~, grad] = calcBPBatch(image, label, theta, architecture, option);

% ��ֵ���㷽��
numGradient = computeNumericalGradient( ...
    @(x) calcBPBatch(image, label, x, architecture, option ), theta );

% �Ƚ��ݶȵ�ŷʽ����
diff = norm( numGradient - grad ) / norm( numGradient + grad );

end






function numGradient = computeNumericalGradient( fun, theta )
%����ֵ�������� ����fun �� ��theta �����ݶ�
% fun��������theta�����ʵֵ�ĺ��� y = fun( theta )
% theta����������

    % ��ʼ�� numGradient
    numGradient = zeros( size(theta) );

    % ��΢�ֵ�ԭ���������ݶȣ�����һ��С�仯�󣬺���ֵ�ñ仯�̶�
    EPSILON   = 1e-4;
    upTheta   = theta;
    downTheta = theta;
    
    wait = waitbar(0, '��ǰ����');
    for i = 1: length( theta )
        % waitbar( i/length(theta), wait, ['��ǰ����', num2str(i/length(theta)),'%'] );
        waitbar( i/length(theta), wait);
        
        upTheta( i )    = theta( i ) + EPSILON;
        [ resultUp, ~ ] = fun( upTheta );
        
        downTheta( i )    = theta( i ) - EPSILON;
        [ resultDown, ~ ] = fun( downTheta );
        
        numGradient( i )  = ( resultUp - resultDown ) / ( 2 * EPSILON ); % d Vaule / d x
        
        upTheta( i )   = theta( i );
        downTheta( i ) = theta( i );
    end
    bar  = findall(get(get(wait, 'children'), 'children'), 'type', 'patch');
    set(bar, 'facecolor', 'g');
    close(wait);
end
