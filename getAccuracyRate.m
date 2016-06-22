function accuracy = getAccuracyRate( predictLabels, labels )
%����Ԥ��׼ȷ��
% by ֣��ΰ Aewil 2016-04

% ��Ԥ��ĸ��ʾ����У�ÿ�������ʵ�ֵ��1��������0
predictLabels = bsxfun( @eq, predictLabels, max( predictLabels ) );
% �ҳ���ȷlabel����Ӧ�����λ�ã�������Щλ�õ�ֵ���ֵ
indexRow = labels';
indexCol = 1:length(indexRow);
index    = (indexCol - 1) .* size( predictLabels, 1 ) + indexRow;
accuracy = sum( predictLabels(index) )/length(indexRow);

end