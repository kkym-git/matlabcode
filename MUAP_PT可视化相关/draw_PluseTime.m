function [s]=draw_PluseTime(pluse_all,fsamp,ytick,size,linewidth,xtick)
%本函数用以绘制放电串图像，并返回图像的cell文件
%输入:
%pluse_all cell文件 每个放电串的放电时间
%fsamp 值 采样频率
%ytick MU序号编号间隔
%size 绘图时每次pluse的大小，默认15
%linewidth 绘图时每次pluse的宽度，默认1
%xtick 时间刻度，默认1
%
%输出：
%图像与图像文件cell文件

if nargin==2
    ytick=1;
    size=15;
    linewidth=1;
    xtick=1;
elseif nargin==3
    size=15;
    linewidth=1;
    xtick=1;
elseif  nargin==4
    linewidth=1;
    xtick=1;
end   
pluse_time = cellfun(@(x) x / fsamp, pluse_all, 'UniformOutput', false);
idx=cell(0);
maxtime=0;
for i=1:length(pluse_time)
    idx{i}=repmat(i, 1, length(pluse_time{i}));
    if ~isempty(pluse_time{i})    
    maxtime(i)=max(pluse_time{i});
    end
end

figure;hold on

colors = parula(length(idx));
% colors = viridis(length(idx));


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
xticks(0:xtick:xmax);

hold off
end