%% read otb data - batch
clear;
close all;

filePath = 'Z:\data\24-08-29iEMG-US-sEMG联合采集_程瑞佳';
cd(filePath);
fileNames = dir('*.otb+');
for i = 1:length(fileNames)
    tmpName = fileNames(i).name;
    fullPath = [fileNames(i).folder '/' fileNames(i).name];
    data = OpenOTBfilesBatch(fullPath);
    
    %     figure; plotsig_cc(data,10240);
    % if contains(tmpName,'M1')
    %     trigger = data(11,:);
    % else
    %     trigger=data(75,:);
    % end
    
    %trigger
    trigger=data(82,:);
    tmpInd = find(trigger>3400);
    tmpInd(find(diff(tmpInd)<=5)+1) = [];
    if contains(tmpName,'M1')
        chInd = 9;
    else 
        chInd = [9,17:80];
    end
    
    %保存
    data_EMG = data(chInd,tmpInd(1):tmpInd(2));
    %         figure; plotsig_cc(data_EMG,10240);
    save([fullPath(1:end-5) '.mat'],'data_EMG');
    % end
end