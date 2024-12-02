clear all
%% 导入数据
% import_file_name = 'IQData_16000_800fps_phantom_23-09-21_trial1.mat';
import_file_name = 'IQData_30000_SKYM_M1_level20_trial1_Dual_24-02-27_2.mat';
% import_file_name = 'IQData_80000_level30_trial1_position1_23-06-21_1';
file_date = import_file_name(end-13:end-6);
load(['./IQData/24-02-27/' import_file_name])
%% 

param.PRF = 800; %~ 脉冲重复频率，对于平面波，应该等于采样帧率

% parpool(3);% 设置线程数量
param.M = 4; %~ z轴向ROI范围axial
param.N = 4; %~ 整体数据长度方向ROI范围（ensemble length） 

movie_flag = 1;

IQb = IQData_40000_CPWC1;

% IQb = IQData_80000_CPWC1(:,:,40001:80000);
% IQb = IQData_16000_CPWC1_phantom;
% IQb = IQData;

%% 超声探头和成像参数
param.fc = 7.7e6;%~ 探头中心频率
param.fs = 4*param.fc;%~ 回波采样频率，verasonics采集默认为4倍频
param.TXdelay = zeros(1,128);%~ 阵元发射波形的时间延迟，可以控制波形偏转
param.pitch = 3e-04; %~ 相邻两个阵元的中心距离
param.width = 2.7e-04; %~ 阵元宽度
param.kerf = param.pitch - param.width; %~ 相邻两个阵元之间的间隙
param.c = 1540;%~ 超声声速
param.fnumber = 0;%~ 平面波成像，fnumber = 0表示全孔径发射和接收
param.fdem = param.fc/param.fs; 
param.ts = 1/param.fs;%~ 采样点间隔时间
param.T = 1/param.PRF; %~ 采样帧的时间间隔



%% 组织速度图 TVI
%~ 默认ROI的参数
ROI_ax  = 1:1:size(IQb,1)-param.M; %~ 竖直方向（纵向/轴向），ROI窗滑动为1pixel
ROI_lat =  1:1:size(IQb,2); %~ 水平方向（横向，通道数），针对所有通道计算
ROI_fr  = 1:1:size(IQb,3)-param.N; %~ 整体数据长度“帧”方向，ROI窗滑动为1pixel

IQaxfrlat = permute(IQb, [1 3 2] ); %~ 将IQData的第二维和第三维调换，方便访问数据
%~ 释放一部分内存空间
clear IQData_40000_CPWC1 IQb
% clear IQData_16000_CPWC1_phantom IQb

TVIData = zeros(length(ROI_ax),length(ROI_lat),length(ROI_fr));


N = length(ROI_ax);
parfor_progress(N);
parfor ax_i = 1:N
    
    TVI_Temp = TVI_calc(param,ax_i,ROI_ax,ROI_lat,ROI_fr,IQaxfrlat);
    TVIData(ax_i,:,:) = TVI_Temp(ax_i,:,:);
    
    parfor_progress;
end
parfor_progress(0);
%%% 存储和绘制TVI图
% TVI_file = dir(fullfile(['./TVIData'],'*.mat'));
% if isempty(TVI_file)
    save(['D:\YZT\Vantage-4.7.6-2206101100\Data\code\RF2TVI\TVIData\24-02-27\TVI_Data_30000_SKYM_M1_level10_trial1_Dual_24-02-27_2.mat'],'TVIData');
% else
%     save(['./TVIData/TVI_Data_' file_date '_' num2str(size(TVI_file,1)+1) '.mat'],'TVIData');
% end

%% 绘制组织速度图TVI的某一帧或者某一段的合成
dx = 3e-4; %~ 单位：m，横向分辨率
dz = 1e-4; %~ 纵向分辨率
% [x,z] = meshgrid(-2e-2 + dx:dx:2e-2,dz:dz:4e-2);
[x,z] = meshgrid(-1.905e-2:dx:1.905e-2,dz:dz:4e-2);

% TVI1 = sum(TVI,3);
TVI1 = TVIData(:,:,1);
TVI1(isnan(TVI1)) = 0;

figure;
imagesc(x(1,:)*100,z(:,1)*100,TVI1)
colormap dopplermap
colorbar
caxis([-1 1]*max(abs(TVI1(:))))
title('Tissue Velocity map')
ylabel('[cm]')
axis equal ij tight
set(gca,'XColor','none','box','off')

%% 读取并将组织速度图保存成movie格式
if movie_flag
    mkdir(['./Movie/' date]);%~ 创建视频保存文件夹
    Movie_file = dir(fullfile(['./Movie/' date],'*.mp4'));
    if isempty(Movie_file)
        MoviePath = ['./Movie/' date '/TVI_Movie_' file_date '_1.mp4']; %~ 视频文件的名称
    else
        MoviePath = ['./Movie/' date '/TVI_Movie_' file_date '_' num2str(size(Movie_file,1)+1) '.mp4'];
    end

    profile = 'MPEG-4'; %~ 视频文件格式
    writerObj = VideoWriter(MoviePath,profile); %~ 创建视频文件
    open(writerObj); %~ 打开该视频文件

    tic
    for n = 1:size(TVIData,3)
        TVI_img = TVIData(:,:,n);
        TVI_img(isnan(TVI_img)) = 0;

        figure(10);
        imagesc(x(1,:)*100,z(:,1)*100,TVI_img)
        colormap dopplermap
    %     colormap(gray(256));
        colorbar
    %     caxis([-1 1]*max(abs(TVI_img(:))))
        caxis([-1 1]*max(max(max(TVIData))));
        title('Tissue Velocity map')
        ylabel('[cm]')
        axis equal ij tight
        set(gca,'XColor','none','box','off')
        frame = getframe; %~ 获取图像帧
        writeVideo(writerObj,frame); %~ 将帧写入视频文件中
    end
    toc
    close(writerObj); %~ 关闭视频文件句柄
end