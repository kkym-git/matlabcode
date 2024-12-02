function [PT_draw] = draw_PT_1(pulse,fsamp,ytick,size,linewidth)
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明
time=100000;
if nargin<3
    ytick=1;
    size=15;
    linewidth=1;
end    
if nargin<4
    size=15;
    linewidth=1;
end   
if nargin<5
    size=15;
    linewidth=1;
end   


pluse_time = cellfun(@(x) x / fsamp, pluse_all, 'UniformOutput', false);
idx=cell(0);
maxtime=0;
for i=1:length(pluse_time)
    idx{i}=repmat(i, 1, length(pluse_time{i}));
    maxtime(i)=max(pluse_time{i});
end

figure;hold on

% colors = parula(length(idx));
colors = viridis(length(idx));


for i= 1:length(idx)
    s{i}=scatter(pluse_time{i},idx{i},size,colors(i,:),'|');

    % s{i}.CData=colors(i,:);
    % s{i}.Marker='|';
    % s{i}.SizeData=15;
    s{i}.LineWidth=linewidth;
end
xlabel('time(s)');
ylabel('#');

xmax=ceil(max(maxtime));
ylim([0,length(idx)+1]);
xlim([0,xmax]);
yticks(0:ytick:length(idx));
time=100000;
xticks(0:1:time);

end

