function diff = checkAE( images )
%���ڼ��sparseAutoencoderEpoch�������õ����ݶ�grad�Ƿ���Ч
% by ֣��ΰ Aewil 2016-04
% ��������ֵ�����ݶȵķ����õ��ݶ�numGradient����������
% ��sparseAutoencoderEpoch��������ѧ�����������õ����ݶȣ��ܿ죩���бȽ�
% �õ������ݶ�������ŷʽ�����С��Ӧ�÷ǳ�֮С�Ŷԣ�

image = images(:, 1:1);% ��Ϊ������������Բų�ȡһ�����������ͼ��theta��308308ά����

architecture = [ 784 196 784 ]; % AE����Ľṹ: inputSize -> hiddenSize -> outputSize
theta = initializeParameters( architecture ); % ��������ṹ��ʼ���������

preOption4AE.isSparse = 1;
option4AE = getAEOption( preOption4AE ); % �õ������Ĳ���

% ��������
[ ~,grad] = calcAEBatch( image, theta, architecture, option4AE );

% ��ֵ���㷽��
numGradient = computeNumericalGradient( ...
    @(x) calcAEBatch( image, x, architecture, option4AE ), theta );

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
    
    wait = waitbar( 0, ['��ǰ����', num2str(0),'%'] );
    for i = 1: length( theta )
        % waitbar( i/length(theta), wait, ['��ǰ����', num2str(i/length(theta)),'%'] );
        waitbar( i/length(theta), wait, '��ǰ����' )
        
        upTheta( i )    = theta( i ) + EPSILON;
        [ resultUp, ~ ] = fun( upTheta );
        
        downTheta( i )    = theta( i ) - EPSILON;
        [ resultDown, ~ ] = fun( downTheta );
        
        numGradient( i )  = ( resultUp - resultDown ) / ( 2 * EPSILON ); % d Vaule / d x
        
        upTheta( i )   = theta( i );
        downTheta( i ) = theta( i );
    end
end
