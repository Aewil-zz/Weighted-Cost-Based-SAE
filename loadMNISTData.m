function [ images, labels ] = loadMNISTData( imagesFile, labelsFile, preProcess, isShowImages, varargin )
%����MNIST���ݼ���images��labels
% by ֣��ΰ Aewil 2016-04

if exist( 'isShowImages', 'var' )
    images = loadMNISTImages(  imagesFile, preProcess, isShowImages );
else
    images = loadMNISTImages(  imagesFile );
end
labels = loadMNISTLabels( labelsFile );

end

function images = loadMNISTImages(  fileName, preProcess, isShowImages, varargin )
%����һ��  #���ص��� * #������ �ľ���

    %% ��ȡ raw MNIST images
    fp = fopen( fileName, 'rb' );
    assert( fp ~= -1, [ 'Could not open ', fileName, ' ' ] );  % �򲻿��򱨴�

    magic = fread( fp, 1, 'int32', 0, 'ieee-be' );
    assert( magic == 2051, [ 'Bad magic number in ', fileName, ' ' ] ); % �涨�� magic number������check�ļ��Ƿ���ȷ

    numImages = fread( fp, 1, 'int32', 0, 'ieee-be' ); % �����������������ļ��������Ե���
    numRows   = fread( fp, 1, 'int32', 0, 'ieee-be' );
    numCols   = fread( fp, 1, 'int32', 0, 'ieee-be' );

    images = fread( fp, inf, 'unsigned char' );
    images = reshape( images, numCols, numRows, numImages ); % �ļ������ǰ������еģ���matlab�ǰ������еġ�
    images = permute( images, [ 2 1 3 ] );

    fclose( fp );
    %% ��ʾ200��images
    if exist( 'isShowImages', 'var' ) &&  isShowImages == 1
        figure('NumberTitle', 'off', 'Name', 'MNIST��д����ͼƬ');
        showImagesNum = 200;
        penal         = showImagesNum * 2 / 3;
        picMatCol     = ceil( 1.5 * sqrt(penal) );
        picMatRow     = ceil( showImagesNum / picMatCol );
        for i = 1:showImagesNum
            subplot( picMatRow, picMatCol, i, 'align' );
            imshow( images(:, :, i) );
        end
    end

    %% �� images ���д���
    % ת��Ϊ #���ص��� * #������ ����
    images = reshape( images, size(images, 1) * size(images, 2), size(images, 3) );
    
    if strcmp( preProcess, 'MinMaxScaler' )
        % ��һ���� [0,1]
        images = double( images ) / 255; % �����ֵ��Ǹ�
    elseif strcmp( preProcess, 'ZScore' )
        % ��׼������
        images = zScore( images );% �����ֵ������ɸ�
    elseif strcmp( preProcess, 'Whitening' )
        % �׻�
        images = whitening( images ); % �����ֵ������ɸ�
    end
end

function data = zScore( data )
%�����ݽ��б�׼�����������������У�
% ȥ��ֵ��Ȼ�󷽲�����
    epsilon = 1e-8; % ��ֹ��0
    data = bsxfun( @minus, data, mean(data, 1) ); % ȥ��ֵ����������ȥ��ͼƬ���ȣ�
    data = bsxfun( @rdivide, data, sqrt(mean(data .^ 2, 1)) + epsilon ); % ȥ����
end
function data = whitening( data )
%�����ݽ��а׻����������������У�
% ȥ��ֵ��Ȼ��ȥ�����
    data = bsxfun( @minus, data, mean(data, 1) ); % ȥ��ֵ
    [ u, s, ~ ] = svd( data * data' / size(data, 2) ) ; % ��Э��������svd�ֽ�
    data = sqrt(s) \ u' * data; % �׻���ȥ����ԣ�Э����Ϊ1��
end

function labels = loadMNISTLabels( fileName )
%����һ�� #��ǩ�� * #1 ��������

    %% ��ȡ raw MNIST labels
    fp = fopen( fileName, 'rb' );
    assert( fp ~= -1, [ 'Could not open ', fileName, ' ' ] );

    magic = fread( fp, 1, 'int32', 0, 'ieee-be' );
    assert( magic == 2049, [ 'Bad magic number in ', fileName, ' ' ] );

    numLabels = fread( fp, 1, 'int32', 0, 'ieee-be' );
    labels = fread( fp, inf, 'unsigned char' );

    assert( size(labels, 1) == numLabels, 'Mismatch in label count' );
    fclose( fp );

    labels( labels == 0 ) = 10;

    % ���汾�뻯�ɾ�����ʽ�ģ�������softmax��û����
    % indexRow      = labels';
    % indexCol      = 1:numLabels;
    % index         = (indexCol - 1) .* 10 + indexRow;
    % labels        = zeros( 10, numLabels );
    % labels(index) = 1;
end



