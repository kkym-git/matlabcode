function [iPulses] = eaf2pulse(path_eaf,fsamp)
%eaf2pulse 输入eaf文件得到其放电串采样点数的cell文件
%   24-09-02 by KYM
%%%%%
% input:
%   path_eaf:eaf文件的路径
%   fsamp：采样频率，一般需要低于实际采集时的频率。由于eaf文件中的放电是以时间记录，因此可以改变采样率获得不同的点数
% output:
%   iPulses: cell文件，记录放电串
eafdata = importdata(path_eaf); % 读取eaf文件
muNum = max(eafdata.data(:,2)); % MU的个数
iPulses = {};
for mu = 1:muNum
    % iPulses就是这个eaf文件里分解得到的spike train，每个cell表示一个MU，里面的数字是该MU每次放电的时刻
    iPulses{mu} = round(eafdata.data(find(eafdata.data(:,2)==mu),1)'*fsamp);
end
end