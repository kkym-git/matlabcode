function ChannelHandles = multiChanPlotGeneration(chanNum,axe)
% -- Created by CC -- Email: cedric_c@126.com %
% generate the plot handles of each channel


% switch 'color'
dc = hsv(chanNum);
ChannelHandles = cell(1,chanNum);
for i = 1:chanNum
    if exist('axe','var')
        ChannelHandles{i} = line(axe,0,0,'Color',dc(i,:),'linewidth',1);
    else
        ChannelHandles{i} = line(0,0,'Color',dc(i,:),'linewidth',1);
    end

end