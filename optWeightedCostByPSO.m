function [ optTheta, bestGlobal, bestGlobalFit ] = optWeightedCostByPSO( runSAEOnce, ...
    architecture, option4PSO )
%���� ����Ⱥ�㷨PSO �Ż�fun����

%% ��ʼ������
% ��ʼ�� ������Ⱥ�� individualSize * population
individualSize = sum( architecture(1:(end-2)) );
individuals    = rand(  individualSize, option4PSO.population ) * 2; % [0,2]֮��
bestSelf       = zeros( individualSize, option4PSO.population ); % ����ÿ�������������ʷ���Ž�
bestGlobal     = zeros( individualSize, 1 ); % ������Ⱥ����ʷ���Ž�
% ��ʼ����Ӧ�ȣ�Խ��Խ��
bestSelfFit    = zeros( 1, option4PSO.population );
bestGlobalFit  = 0;
bestGlobalFit  = 0;
% bestNowGlobalFit = 0;
% ��ʼ���ٶ�
velocity = zeros( individualSize, option4PSO.population );
% ��ʼ��һЩ����
wMax = 1; wMin = 0.6; % �������ӷ�Χ
c1 = 1; c2 = 1; % c1,c2Ϊ�� ������ʷ���� �� ȫ����ʷ���� ǰ���ļ������ӣ������϶��㷨Ӱ�첻�󣨽⣬�����ٶȻ�Ӱ�죩
% r1 = 0; r2 = 0; % ������c1,c2����ڵ�������ӣ��������������

%% PSO��������
for iter = 1:option4PSO.iteration
    % PSO���ۣ�����e �������������С�����ȣ���������������exploration��exploitation
    % e = ( 1-w ) / [ (c1*r1 + c2*r2) * sqrt(2w + 2 - c1*r1 - c2*r2) ]
    % ����ǰ��w���Դ�����С�������������Χ�����ۣ����廹�ǵ��Σ�
    w = wMax - iter * ( wMax - wMin ) / option4PSO.iteration; % ��������
    
    % ����Ⱥ�ĸ�����Ӧ�ȣ��� ������Ⱥ����
    for pop = 1:option4PSO.population
        [ ~, accuracy ]  = runSAEOnce( individuals( :, pop ) );
        
        % �Ƿ��Ǹ����������ʷ���Ž�
        if accuracy > bestSelfFit( 1, pop )
			bestSelfFit( 1, pop ) = accuracy;
            bestSelf( :, pop )    = individuals( :, pop );
            % �Ƿ���ȫ�����Ž�
            if accuracy > bestGlobalFit
                bestGlobal    = individuals( :, pop );
                bestGlobalFit = accuracy;
            end
        end
    end
    
    % disp( ['ȫ�����Ž�Ϊ��' num2str(bestGlobalFit * 100) '%'] );
    
    r1 = rand(); r2 = rand();
    velocity = w * velocity + ... % ���Գɷ�
        c1 * r1 * ( bestSelf - individuals ) + ... % �ֲ������ɷ�
        c2 * r2 * bsxfun( @plus, - individuals, bestGlobal ); % ȫ�������ɷ�
    individuals = individuals + velocity;
end

[ optTheta, bestGlobalFit ]  = runSAEOnce( bestGlobal );

end