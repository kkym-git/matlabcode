clear all
addpath(genpath('C:\Users\Administrator\AppData\Roaming\MathWorks\MATLAB Add-Ons\Functions\Save MAT files more quickly\'));
%% 导入数据
file_date = '24-02-27\';
RFData_Raw_folder = ['D:\YZT\Vantage-4.7.6-2206101100\Data\Experiment\' file_date];
fileList = dir(fullfile(RFData_Raw_folder, '*.mat'));
na = 1000; %~ 1个大帧包含的小帧数目
ax_dots = 2304; %~ 轴向（深度方向）的实际采样点数

folderName = ['D:\YZT\Vantage-4.7.6-2206101100\Data\code\RF2TVI\RFData\' file_date];
if exist(folderName)==0
    mkdir(folderName);
end

%% 循环读取处理
for i = 1:numel(fileList)
    % 探头1
    filename = fullfile(RFData_Raw_folder, fileList(i).name);
    load(filename);
    rcvdata = RFdata(1:na*ax_dots,1:128,:);
    % 数据重排，采集的时候数据叠加到一起传输，例如100个小帧组成了一个大帧
    rcv_Transfer = pagetranspose(rcvdata); %~ 按每一个大帧转置
    RFData_Transfer = reshape(rcv_Transfer,size(rcvdata,2),ax_dots,[]);%~ 每帧采集的深度为4000采样点，通道数不变为128，剩下的维度即总的采样帧，[]表示自适应
    RFData_reshape = pagetranspose(RFData_Transfer);
    % 补0，应用于verasonics自带的IQ2TVI程序，如果是用自编代码，这部分要注释掉！！！23-02-15
    add_zeros = zeros(4000-2304,128);
    parfor j = 1:size(RFData_reshape,3)
        RFData(:,:,j) = [RFData_reshape(:,:,j); add_zeros];
    end
    savefast([folderName '\' fileList(i).name(1:end-4) '_1.mat'], 'RFData');
    clear rcvdata rcv_Transfer RFData_Transfer RFData_reshape RFData
    
    % 探头2
    rcvdata = RFdata(1:na*ax_dots,129:256,:);
    % 数据重排，采集的时候数据叠加到一起传输，例如100个小帧组成了一个大帧
    rcv_Transfer = pagetranspose(rcvdata); %~ 按每一个大帧转置
    RFData_Transfer = reshape(rcv_Transfer,size(rcvdata,2),ax_dots,[]);%~ 每帧采集的深度为4000采样点，通道数不变为128，剩下的维度即总的采样帧，[]表示自适应
    RFData_reshape = pagetranspose(RFData_Transfer);
    % 补0，应用于verasonics自带的IQ2TVI程序，如果是用自编代码，这部分要注释掉！！！23-02-15
    add_zeros = zeros(4000-2304,128);
    parfor j = 1:size(RFData_reshape,3)
        RFData(:,:,j) = [RFData_reshape(:,:,j); add_zeros];
    end
    savefast([folderName '\' fileList(i).name(1:end-4) '_2.mat'], 'RFData');
    clear rcvdata RFdata rcv_Transfer RFData_Transfer RFData_reshape RFData
end

