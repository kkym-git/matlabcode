%% 初始化
addpath(genpath('C:\Users\Administrator\AppData\Roaming\MathWorks\MATLAB Add-Ons\Functions\Save MAT files more quickly'))
activate
clear all
aqc_time = 15;%采集时长（s）
filename = ['MatFiles/L11-5vFlash_Trigger_Dual_' num2str(aqc_time) 's_1000'];
VSX
%% 修改参数
subject_num = 'PIG';
Motion_num = '1';
level_num = '1';
trial_num = '1';
Date_time = '24-04-10';
aqc_time = 15;%采集时长（s）
%% 执行
folder_name = ['D:/YZT/Vantage-4.7.6-2206101100/Data/Experiment/' Date_time];
if exist(folder_name)==0
    mkdir(folder_name);
end
RFdata = RcvData{1};
savefast(['./Data/Experiment/' Date_time '/RFData_' num2str(aqc_time*2000) '_S' subject_num '_M' Motion_num '_level' level_num '_trial' trial_num '_Dual_' Date_time '.mat'],'RFdata');
clear all