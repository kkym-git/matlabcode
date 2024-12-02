


% path_fold='Z:\data\24-10-12iEMG-sEMG';
% % path_semg=[path_fold '\M2L' num2str(level) 'T'  num2str(trial) '.mat'];
% path_semg=[path_fold '\M' num2str(level) 'L1T'  num2str(trial) '.mat'];
% load(path_semg);

%%
data_sEMG{1}=double(Data{1}(:,1:64))';
data_sEMG{2}=double(Data{1}(:,65:128))';
data_sEMG{3}=double(Data{1}(:,129:192))';
data_sEMG{4}=double(Data{1}(:,193:256))';

fsamp = 2048;

decoderParameters.fsamp = fsamp;
decoderParameters.TimeDifference = 0;
decoderParameters.SpatialDifference = 0;
decoderParameters.ElectrodeType = 13;
%5-qt8*8 13-5*13; 18-mouvi8*8%%%需要注意电极片位置
decoderParameters.BandpassFilter = 1;%20-500Hz带通滤波
decoderParameters.LineFilter = 1;%50Hz梳状滤波
decoderParameters.ChannelFilter = 1;%去除不好的电极channel
decoderParameters.extendingFactor = 10;%论文里是10c
decoderParameters.costFcn = 3;
decoderParameters.iterationNumW = 45;%45
decoderParameters.iterationNumMU = 30;

for i=1:4
[decompData,~,datafilt,prohibitInd,~] = PreProcess4GUI_v2(data_sEMG{i},decoderParameters);
 datafilt_all{i}=datafilt;
 decompData_all{i}=decompData;
 prohibitInd_all{i}=prohibitInd;
end
%% RMS求取
for i=1:4
rmsresult=rmsmat(datafilt_all{i});
rms_all{i}=rmsresult;
end
% imagesc(sigcell)

function sigcell = rmsmat(datafilt)
RMS_result=rms(datafilt,2);
sig=RMS_result;
for i=1:12
    sigcell(i+1,1)=sig(i,:);
end
for i=1:13
    k=13-i;
    sigcell(i,2)=sig(k+13,:);
    sigcell(i,3)=sig(i+25,:);
    sigcell(i,4)=sig(k+39,:);
    sigcell(i,5)=sig(i+51,:);
end
end
%% 微调
% rms_all{1}(3,9)=rms_all{1}(3,9)



%% RMS绘图
% imagesc
