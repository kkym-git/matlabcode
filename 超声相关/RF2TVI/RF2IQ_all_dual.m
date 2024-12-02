clear all
activate
%% 数据路径
file_date = '24-02-27\';
folderName = ['D:\YZT\Vantage-4.7.6-2206101100\Data\code\RF2TVI\IQData\' file_date];
if exist(folderName)==0
    mkdir(folderName);
end
RF_IQ_SetUpL11_5vFlashAngles_IQall_CPWC1_15s
RFData_Raw_folder = ['D:\YZT\Vantage-4.7.6-2206101100\Data\code\RF2TVI\RFData\' file_date];
fileList = dir(fullfile(RFData_Raw_folder, '*.mat'));
%% 循环读取处理
while numel(fileList)~=0
    x = 1;
    RF_filename = fullfile(RFData_Raw_folder, fileList(x).name);
    load(RF_filename);
%     RcvData{1} = RFData(:,:,10001:50000);
    RcvData{1} = RFData;
    filename = 'MatFiles/RF_IQ_SetUpL11_5vFlashAngles_IQall_CPWC1_15s';
    VSX
    %把处理好的数据放到process_done文件夹内
    RFData_Raw_folder = ['D:\YZT\Vantage-4.7.6-2206101100\Data\code\RF2TVI\RFData\' file_date];
    fileList = dir(fullfile(RFData_Raw_folder, '*.mat'));
    x = 1;
    % 读取IData和QData，组成IQData
    a=IData{1}(:,:,1,1,:);
    a=a(:,:,:);
    a1=a(:,:,1);
    b=QData{1}(:,:,1,1,:);
    b=b(:,:,:);
    b1=b(:,:,1);
    IQData_40000_CPWC1 = complex(a,b);
    save(['D:\YZT\Vantage-4.7.6-2206101100\Data\code\RF2TVI\IQData\' file_date 'IQ' fileList(x).name(3:end-4) '.mat'],'IQData_40000_CPWC1');
   
    
    %% 移动已处理的数据，留下未处理的数据    
    source_path = fullfile(RFData_Raw_folder, fileList(x).name);
    destination_path = fullfile([RFData_Raw_folder 'processed_done\'], fileList(x).name);
    
    if exist([RFData_Raw_folder 'processed_done\'])==0 %%判断文件夹是否存在
        mkdir([RFData_Raw_folder 'processed_done\']);  %%不存在时候，创建文件夹
    end
    movefile(source_path, destination_path);
    
    fileList = dir(fullfile(RFData_Raw_folder, '*.mat'));
end
