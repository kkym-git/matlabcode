% clear;
% close all;

fsampu = 1000; % 采样率
data = importdata(['iEMG_S1_M1_level2_trial2_24-06-21_UUS_new.eaf']); % 读取eaf文件
muNum = max(data.data(:,2)); % MU的个数
iPulses = {};
for mu = 1:muNum
    % iPulses就是这个eaf文件里分解得到的spike train，每个cell表示一个MU，里面的数字是该MU每次放电的时刻
    iPulses{mu} = round(data.data(find(data.data(:,2)==mu),1)'*fsampu); 
end


