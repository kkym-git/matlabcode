function [maxAP,fig] = plotDecomps(pulses,muaps,fsamp,flag_feat,order,fig)
%% -- Created by CC on 2021/9/23 -- Email: cedric_c@126.com %
% This function plots the pulse trains, muaps and the (covISI, aveFre) in
% an individual axes.
% INPUT
%   pulses: pulse trains in cell or matrix format
%   muaps: muaps of each pulse trains. If empty, the function won't plot.
%   fsamp: sampling rate
%   flag_feat: whether to show the (covISI, aveFre)
%   order: whether to re-arrange the pulses depending on the recruitment
%   fig: the handle of figure to plot

if ~exist('fig','var')
    fig = figure('color',[1,1,1]);
end
if iscell(pulses)
    numMU = length(pulses);
else
    numMU = size(pulses,1);
    pulses = spiketrain2pulse(pulses);
end
if ~exist('muaps','var') || isempty(muaps)
    muaps = {};
end

lw = 1;
p1 = zeros(1,numMU);
p2 = zeros(1,numMU);
for mu = 1:numMU
    if ~isempty(pulses{mu})
        p1(mu) = pulses{mu}(1);
        p2(mu) = pulses{mu}(end);
    end
end
len = max(p2)/fsamp;
if order
    [~,ia] = sort(p1);
    pulses = pulses(ia);
    if ~isempty(muaps)
        muaps = muaps(ia);
    end
%     txt = txt(ia);
end

mustHandle = multiChanPlotGeneration(numMU);
mustHandle2 = multiChanPlotGeneration(numMU);
pulseLines = st2line(pulses,min(p1)-1,max(p2));


dc = hsv(numMU);
% dc = jet(numMU);
maxAP = {};
hold on;
for mu = 1:numMU
    if isempty(pulses{mu})
        continue;
    end
    set(mustHandle{mu},'xdata',pulseLines{mu}.x/fsamp,'ydata',pulseLines{mu}.y+mu-0.5,'color',dc(mu,:),'linewidth',lw);
    set(mustHandle2{mu},'xdata',[min(p1)-1,max(p2)]/fsamp,'ydata',[mu-0.4,mu-0.4],'color',[1,1,1],'linewidth',lw*1);

    if ~isempty(muaps)
        tmpMUAP = muaps{mu};
        if iscell(tmpMUAP)
            [~,~,~,pos] = plotArrayPotential(tmpMUAP,1,0);
            tmpMUAP = tmpMUAP{pos(1),pos(2)};
        end
        if order
            maxAP{ia(mu)} = tmpMUAP;
        else
            maxAP{mu} = tmpMUAP;
        end
        plot([1:length(tmpMUAP)]/length(tmpMUAP)*max(p2)/fsamp/20+len+0.5,tmpMUAP+mu,'color',dc(mu,:),'linewidth',1);
    end

%     tmpPulses = pulses{mu};

%     h(mu) = stem(tmpPulses/fsamp,ones(1,length(tmpPulses))*(mu+0.35),'MarkerEdgeColor','none');
%     h(mu).BaseValue = mu-0.35;
%     h(mu).BaseLine.Visible = 'off';
%     for i = 1:length(tmpPulses)
%         plot([tmpPulses(i),tmpPulses(i)]/fsamp,[-0.35,0.35]+mu,'color',dc(mu,:),'linewidth',1);
%     end
    
    if flag_feat
        tmpISI = diff(pulses{mu});
        tmpISI(find(tmpISI>1*fsamp)) = [];
        covISI = std(tmpISI)/mean(tmpISI);
        aveFre = fsamp/mean(tmpISI);
        if isempty(muaps)
            text(len+1,mu,['(' num2str(round(covISI,2)) ', ' num2str(round(aveFre,2)) ')'],'Fontsize',10,'FontName','Calibra');
        else
            text(len+2,mu,['(' num2str(round(covISI,2)) ', ' num2str(round(aveFre,2)) ')'],'Fontsize',10,'FontName','Calibra');
        end
    end
end
% axis off;
if flag_feat && ~isempty(muaps)
    axis([0,len+max(p2)/fsamp/20+1,0,numMU+1]);
elseif flag_feat
    axis([0,len+3,0,numMU+1]);
elseif ~isempty(muaps)
    axis([0,len+max(p2)/fsamp/20+1,0,numMU+1]);
else
    axis([0,len,0,numMU+1]);
end
% set(gca,'xtick',[0:5:len])
xlabel('Time (s)');
ylabel('MU number');
set(gca,'Fontsize',12,'FontName','Calibra','linewidth',1);
