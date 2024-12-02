addpath(genpath('C:\Users\Administrator\AppData\Roaming\MathWorks\MATLAB Add-Ons\Functions\Save MAT files more quickly'))
activate
clear all
filename = 'MatFiles/L11-5vFlash_Trigger_800hz_20s';
VSX
trial_num = '5';
Motion_num = '4';
Date_time = '24-01-24';
RFdata = RcvData{1};
savefast(['D:/YZT/Vantage-4.7.6-2206101100/Data/Experiment/' Date_time '/phantom/RFData_16000_phantom_Motion_' Motion_num '_trial' trial_num '_' Date_time '.mat'],'RFdata');
clear all