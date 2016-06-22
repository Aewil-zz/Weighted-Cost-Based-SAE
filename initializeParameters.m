function theta = initializeParameters( architecture, lastActiveIsSoftmax, varargin )
%����ÿһ����Ԫ�����������ʼ��������Ȩ�ز���
% by ֣��ΰ Aewil 2016-04
% architecture: ����ṹ��
% theta��Ȩֵ��������[ W1(:); b1(:); W2(:); b2(:); ... ]��

% û�д��� lastActiveIsSoftmax��Ĭ�ϲ��� softmax�����
if nargin == 1
    lastActiveIsSoftmax = 0;
end
% �������������W������b����������ʼ����
if lastActiveIsSoftmax % softmax��һ�㲻��ƫ��b
    countW = architecture * [ architecture(2:end) 0 ]';
    countB = sum( architecture(2:(end-1)) );
    theta = zeros( countW + countB, 1 );
else
    countW = architecture * [ architecture(2:end) 0 ]';
    countB = sum( architecture(2:end) );
    theta = zeros( countW + countB, 1 );
end

% ���� Hugo Larochelle���� ��ʼ��ÿ������� W
startIndex = 1; % ����ÿ������w���±����
for layer = 2:length( architecture )
    % ����ÿ������W���±��յ�
    endIndex = startIndex + ...
        architecture(layer)*architecture(layer -1) - 1;
    
    % Ȩ�س�ʼ����Χ��Hugo Larochelle����
    r = sqrt( 6 ) / sqrt( architecture(layer) + architecture(layer -1) );  
    
    % (layer -1)  -> layer, f( Wx + b )
    theta(startIndex:endIndex) = rand( architecture(layer) * architecture(layer -1), 1 ) * 2 * r - r;
    
    % ������һ������W���±���㣨����b��
    startIndex = endIndex + architecture(layer) + 1;
end

end