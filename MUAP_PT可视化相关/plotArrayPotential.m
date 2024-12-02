function [filterArray,maxAmp,maxPP,pos] = plotArrayPotential(arrayData,mode,draw,axe,para)
% -- Created by CC on 2021/9/23 -- Email: cedric_c@126.com %
% this function plots the action potential with the multiple electrode
% array in a single axes. The orginial function plots in mulitple sub-axes.
% Input
%   arrayData:the action potential in cell format
%   mode: represents different spatial filters.
%       mode = 1, monopolar filter (raw signals)
%       mode = 2, bipolar filter between near raws
%   para: parameters including the color and width of lines, and others
% OUTPUT
%   filterArray: spatial-filtered array potentials
%   maxAmp: the maximum amplitudes
%   maxPP: the maximum peak-to-peak values
%   pos: the position of maxPP ([r,c])

if ~exist('para','var')
    para.color = 'k';
    para.linewidth = 1;
else
    if ~isfield(para,'color')
        para.color = 'k';
    end
    if ~isfield(para,'linewidth')
        para.linewidth = 1;
    end
end
if draw
    if ~exist('axe','var')
        axe = axes;
    end
end
[rn,cn] = size(arrayData);

% spatial filter
switch mode
    case 1
        arrayData2 = arrayData;
    case 2
        for r = 2:rn
            for c = 1:cn
                if isempty(arrayData{r,c}) || isempty(arrayData{r-1,c})
                    continue;
                end
                arrayData2{r-1,c} = arrayData{r,c}-arrayData{r-1,c};
            end
        end
end
filterArray = arrayData2;
[rn2,cn2] = size(arrayData2);
N_ch = [];%arrayData2的cell长度
amp = [];%绝对值最大值（峰值）
pp = [];
for r = 1:rn2
    for c = 1:cn2
        if ~isempty(arrayData2{r,c})
            N_ch(r,c) = length(arrayData2{r,c});
            amp(r,c) = max(abs(arrayData2{r,c}));
            pp(r,c) = max(arrayData2{r,c})-min(arrayData2{r,c});
        end
    end
end


maxN = max(max(N_ch));
maxAmp = max(max(amp));
%max对于矩阵取每一列的最大值组成新的行向量

%找pp中的最大值以及索引
[tmp,ia] = max(pp);
[~,pos(2)] = max(tmp);
pos(1) = ia(pos(2));

maxPP = max(max(pp));
if draw
    
    if isfield(para,'maxPP')
        scale = para.maxPP;
    else
        scale = maxPP;
    end
    width = 0.8;
    hold(axe,'on');
    for r = 1:rn2
        for c = 1:cn2
            if ~isempty(arrayData2{r,c})
%                 plot(axe,[1:N_ch(r,c)]/N_ch(r,c)*width+c-width/2,rn+1-r+arrayData2{r,c}/scale,'color',para.color,'linewidth',para.linewidth);
                plot(axe,[1:N_ch(r,c)]/maxN*width+c-width/2,rn+1-r+arrayData2{r,c}/scale,'color',para.color,'linewidth',para.linewidth);
            end
        end
    end
    axis(axe,'off','tight');
    hold off
end