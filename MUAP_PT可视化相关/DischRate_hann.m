function DR = DischRate_hann(Pulses,fsamp,timelen,draw,order)
% -- Created by CC -- Email: cedric_c@126.com %
% This function calculates the discharge rate curve of each MUAPt from
% input data Pulses.
% INPUT
% Pulses: pulse index train of each MU, each cell represents one MU
% fsamp: sampling rate
% OUTPUT
% DR: discharge rate curve of each MU, each cell represents one MU
% % %change by GRY in 2023-5-6
% %% debug
% Pulses = newPulsesAll(1:5);
% fsamp = 2048;
% timlen = [0,20];
% draw = 1;
lw = 1;
if nargin<5
    order = 0;
end
munum = length(Pulses); % MU number
if order==1% 将mu按第一次放电的时间前后排序
    seq = zeros(1,munum);
    for i = 1:munum
        seq(1,i) = Pulses{i}(1);
    end
    [~,I] = sort(seq);
    Pulses = Pulses(I);
end
MUAPt = cell(1,munum);
for i = 1:munum
    MUAPt{i} = zeros(1,timelen(2)*fsamp);
    if isempty(Pulses{i})
        continue;
    end
    % MUAPt{i}(Pulses{i}) = 1; % change this command into the following
    % % loop in 2020-8-9, to adapt to the condition of simultaneous
    % % discharges
    for p = Pulses{i}
        if p<=timelen(2)*fsamp && p>=timelen(1)*fsamp %change by GRY in 2023-5-6
            MUAPt{i}(p) = MUAPt{i}(p)+1;
        end
    end
    MUAPt{i} = MUAPt{i}(1+timelen(1)*fsamp:timelen(2)*fsamp);
end
DR = cell(1,munum);
winlen = 0.4;
% winlen = 2;
N =round(winlen*fsamp);
win = hanning(N)';
for i = 1:munum
    tmpPT = MUAPt{i};
    DR{i} = conv(tmpPT,win,'same')/winlen*2;
    % DR{i} = DR{i}(round(N/2)+1:timelen(2)*fsamp+round(N/2));
    % for j = 1:timlen(2)*fsamp
    % if j<=N2
    % DR{i}(j) = sum(tmpPT(1:j+N2).*win(end-j-N2+1:end));
    % elseif j>=timlen(2)*fsamp-N2
    % DR{i}(j) = sum(tmpPT(j-N2:end).*win(1:timlen(2)*fsamp-j+N2+1));
    % else
    % DR{i}(j) = sum(tmpPT(j-N2:j+N2).*win);
    % end
    % end
    % DR{i} = DR{i}/winlen;
    % DR{i}([1:floor(N/2),end-floor(N/2)+1:end]) = [];
    % DR{i}([1:ceil(N/2),end-ceil(N/2)+2:end]) = [];
end
if draw
    % dc = parula(munum);
    dc = hsv(munum);
    for i = 1:munum
        if munum == 1
            % line([1:timelen(2)*fsamp]/fsamp,DR{i},'LineWidth',2,'Color',[0.2,0.2,0.2])
            plot([1:timelen(2)*fsamp]/fsamp,DR{i},'LineWidth',lw)
        else
            line([1:timelen(2)*fsamp]/fsamp,DR{i},'LineWidth',lw,'Color',dc(i,:))
            hold on
        end
    end
    xlabel('Time(s)'),ylabel('Pulses per second')
    xlim(timelen);
    filepath=pwd;
    % mkdir image
    % cd ./image
    % saveas(gcf,'DR' ,'jpg');
    % cd(filepath)
end