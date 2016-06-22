function displayNetwork( weight, figureName, ~ )
%��������Ȩ��(hiddenSize*inputSize)չʾ��������ȡ������ͼ
% ����ÿ�� hidden level 1 �� neuron ��ʾ����ȡ��һ�� feature
% �����ӵ� neuron A ��Ȩ������������ input vector ��ÿһλ�� feature A ����Ҫ�̶�
% ����Ȩ����������Ҫ�̶ȣ������ɹ���� input �� feature

% �� ÿ��inputλȨ�� ʵʩ��һ��
weightMin = min( weight, [], 2 );
weight    = bsxfun( @minus, weight, weightMin );
weightMax = max( weight, [], 2 );
weight    = bsxfun( @rdivide, weight, weightMax );

featureNum  = size( weight, 1 ); % feature������Ҳ��ͼƬ����
penal       = featureNum * 2 / 3;
picMatCol   = ceil( 1.5 * sqrt(penal) );
picMatRow   = ceil( featureNum / picMatCol );

images = reshape( weight', sqrt( size(weight, 2) ), sqrt( size(weight, 2) ), featureNum ); % ͼƬ
% չʾ����
% �Ҷ�ͼ
if exist( 'figureName', 'var' )
    figure('NumberTitle', 'off', 'Name', figureName );
else
    figure('NumberTitle', 'off', 'Name', 'MNIST��д��������ͼ');
end
for i = 1:featureNum
    subplot( picMatRow, picMatCol, i, 'align' );
    imshow( images(:, :, i) );
%     imagesc( images(:, :, i) );
%     axis off;
end

end