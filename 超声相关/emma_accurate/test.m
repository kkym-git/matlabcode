legend%%%%%%%%需要的输出：源信号，向量信号，PT，信号的能量占比（多少到多少赫兹）
% clearvars -except TVIData_interested ;
%%记得改File和存储路径
clear
close all
% 数据载入与滤波{2}（395（0.1mm）* 128(0.3mm)）
fsamp = 2000;
fsampu = 2000;
tviFile='D:\YZT\Vantage-4.7.6-2206101100\Data\code\RF2TVI\TVIData\24-02-27\TVI_Data_30000_SKYM_M1_level20_trial2_Dual_24-02-27';
tmp = load([tviFile '_1.mat']);
TVIData_raw{1} = cat(3,zeros(396,128,20),tmp.TVIData(:,:,4000:end));%%%%%%%%why20
tmp = load([tviFile '_2.mat']);
TVIData_raw{2} = cat(3,zeros(396,128,20),tmp.TVIData(:,:,4000:end));
%% 

TVIData_filter = TVIData_raw;
lowFre = 0.5/(7.7*4)*2;
[Be1,Ae1] = butter(4,lowFre,"low");
[Be2,Ae2] = butter(4,[5,100]/fsampu*2);
for gn = 1:2
    for i = 1:size(TVIData_filter{gn},3)
        %                                             [gn,i]
        tmp = TVIData_filter{gn}(:,:,i);
        tmp = filtfilt(Be1,Ae1,tmp);
        TVIData_filter{gn}(:,:,i) = tmp;
    end
    for r = 1:size(TVIData_filter{gn},1)
        for c = 1:size(TVIData_filter{gn},2)
            %                         [gn,r,c]
            tmp = TVIData_filter{gn}(r,c,:);
            tmp = reshape(tmp,1,size(TVIData_filter{gn},3));
            tmp = filtfilt(Be2,Ae2,tmp);
            TVIData_filter{gn}(r,c,:) = tmp;
        end
    end
end
TVIData_use=TVIData_filter;


% 下采样&取得上80像素部分

for gn=1:2
    idx=1;
    for i =3:3:size(TVIData_use{gn},1)
        TVIData_resample{gn}(idx,:,:)=mean(TVIData_use{gn}(i-2:i,:,:),1);
        idx=idx+1;
    end
    %     TVIData_interested{gn}=TVIData_resample{gn}(1:40,:,:);
    TVIData_interested{gn}=TVIData_resample{gn}(1:80,:,:);
    %取EMG可探测位置
end
clearvars -except TVIData_interested
% TVIData_interested=TVIData_resample(1:40,:,:);
%%
% sbar 才是需要的source
for gn=1:2
    n=size(TVIData_interested{gn},1:2);
    p = [1, 1]* 10; % size of dictionary atoms
    nA = prod(p); % number of Atoms
    np=nA;
    gap = 5; % control the overlapping
    I = [1:gap:n(1)-p(1), n(1)-p(1)+1];
    J = [1:gap:n(2)-p(2), n(2)-p(2)+1];
    nP = numel(I)* numel(J); % total number of patches
    lP = zeros(nP, 5); % location of each patch
    %%%% extracting the patches
    % X = zeros(np, nP);
    % mP = zeros(nP, 1);
    c = 1
    for j = 1:numel(J)
        range_j = J(j): J(j)+p(2) -1;
        for i=1:numel(I)
            range_i = I(i): I(i)+p(1)-1;

            lP(c, :) = [c, range_i(1), range_i(end), range_j(1), range_j(end)];

            [soursesave{c},sbar{c},w_sourse{c},PT{c},energy_ratio{c},w{c},CoV{c},mad_record{c},outrecord{c}]=ultrasound_conv_bss(TVIData_interested{gn}(range_i, range_j,:));

            %         patch_ = patch(:) - 1* mean(patch(:)); % remove the DC part
            %
            %         mP(c) = mean(patch(:)); % mean value of each patch is recorded for reconstruction
            %         X(:, c) = patch;

            c = c + 1
        end
    end

    result.truesourse=sbar;
    result.soursesave=soursesave;
    result.w.w_sourse=w_sourse;
    result.w.w=w;
    result.PT=PT;
    result.record.energy_ratio=energy_ratio;%%%可能需要全谱？
    result.record.CoV=CoV;
    result.record.mad=mad_record;
    result.record.outrecord=outrecord;
    result.position=lP;


%     resultfile=['D:\KYM\EMMA\result\KYM_0327_80_result_M1L1T1_' num2str(gn) '.mat'];
%     save(resultfile,'result')

    final{gn}=result_analysis(result,length(I),length(J));

end
finalfile=['D:\KYM\EMMA\result\KYM_0327_80_final_2_15s_M1L2T2.mat'];
save(finalfile,'final')
