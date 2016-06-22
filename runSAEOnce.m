function [ optTheta, accuracy ] = runSAEOnce( images4Train, labels4Train, ...
    images4Test, labels4Test, ... % ����
    architecture, ...
    option4SAE, option4BPNN, ...
    isDispNetwork, isDispInfo, weightedCost, ~ )
%����SAE���� �� ����һ�� SAE
% by ֣��ΰ Aewil 2016-04

if exist( 'weightedCost', 'var' )
    option4SAE.option4AE.weightedCost = weightedCost;
end
%% ѵ��SAE
theta4SAE = trainSAE( images4Train, labels4Train, architecture, option4SAE ); % ѵ��SAE
if isDispNetwork
    % չʾ�����м������ȡ��feature
    displayNetwork( reshape(theta4SAE(1 : 784 * 400), 400, 784) );
    displayNetwork( (reshape(theta4SAE(1 : 784 * 400), 400, 784)' * ...
        reshape(theta4SAE(784 * 400 + 1 : 784 * 400 + 400*200 ), 200, 400)')' );
end
if isDispInfo
    % �� δ΢����SAE���� ����Ԥ��
    predictLabels = predictNN( images4Train, architecture, theta4SAE, option4BPNN );
    accuracy = getAccuracyRate( predictLabels, labels4Train );
    disp( ['MNISTѵ���� SAE(δ΢����׼ȷ��Ϊ�� ', num2str(accuracy * 100), '%'] );
    
    predictLabels = predictNN( images4Test, architecture, theta4SAE, option4BPNN );
    accuracy = getAccuracyRate( predictLabels, labels4Test );
    disp( ['MNIST���Լ� SAE(δ΢����׼ȷ��Ϊ�� ', num2str(accuracy * 100), '%'] );
end

%% BP fine-tune
[ optTheta, ~ ] = trainBPNN( images4Train, labels4Train, theta4SAE, architecture, option4BPNN );
if isDispNetwork
    % չʾ�����м������ȡ��feature
    displayNetwork( reshape(optTheta(1 : 784 * 400), 400, 784) );
    displayNetwork( (reshape(optTheta(1 : 400 * 784), 400, 784)' * ...
        reshape(optTheta(784 * 400 + 1 : 784 * 400 + 400*200 ), 200, 400)')' );
end
%% �� fine-tune��SAE ����Ԥ��
if isDispInfo
    predictLabels = predictNN( images4Train, architecture, optTheta, option4BPNN );
    accuracy = getAccuracyRate( predictLabels, labels4Train );
    disp( ['MNISTѵ���� SAE(΢����׼ȷ��Ϊ�� ', num2str(accuracy * 100), '%'] );
end
predictLabels = predictNN( images4Test, architecture, optTheta, option4BPNN );
accuracy = getAccuracyRate( predictLabels, labels4Test );
disp( ['MNIST���Լ� SAE(΢����׼ȷ��Ϊ�� ', num2str(accuracy * 100), '%'] ); % pppppppppppppppppppppppppppppppppppppppp
if isDispInfo
    disp( ['MNIST���Լ� SAE(΢����׼ȷ��Ϊ�� ', num2str(accuracy * 100), '%'] );
end

end


