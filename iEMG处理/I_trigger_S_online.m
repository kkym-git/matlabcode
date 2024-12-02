%%%
%用iEMG的PT与sEMG的肌电信号得到分离向量，从而在线分解,得到Pulses_all{肌电trial，iEMG}
clear
CKCdecomp = importdata("Z:\Result\24-08-29iEMG-US-sEMG联合采集_程瑞佳\829_xEMG_CKC_decomp_filtfilt_20-500.mat");
%%
Pulses_all=cell(5,5);
for eaf_num=1:5
    decomp=CKCdecomp{eaf_num};
    EMG=decomp.datafilt;

    eafdata = importdata(['Z:\Result\24-08-29iEMG-US-sEMG联合采集_程瑞佳\eaf\M2L1T' num2str(eaf_num) '.eaf']);
    muNum = max(eafdata.data(:,2)); % MU的个数
    iPulses = {};
    must=zeros(muNum,size(EMG,2));
    for mu = 1:muNum
        % iPulses就是这个eaf文件里分解得到的spike train，每个cell表示一个MU，里面的数字是该MU每次放电的时刻
        iPulses{mu} = round(eafdata.data(find(eafdata.data(:,2)==mu),1)'*2048);
        must(iPulses{mu})=1;
    end

    exFactor=10;%muap的点数
    % exmuap = extend(sig,N);
    % exmuap = exmuap(:,N/2+1:end-N/2+1);
    % signew=reshape(sig,640,1);%应该是ctx?
    eSig = extend(EMG,exFactor);
    eSig = eSig(:,exFactor:end);
    CorrSig = eSig*eSig'/length(eSig);%??没有减去均值（白化）
    invCorrSig = pinv(CorrSig);%%%Cxx-1
    Csjx=(eSig*must')/length(eSig);%%%%%%%%%%%%%%%Csjx的定义
    W{eaf_num}=Csjx'*invCorrSig;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for trial=1:5
        decomp=CKCdecomp{trial};
        EMG=decomp.datafilt;
        eSig = extend(EMG,exFactor);
        eSig = eSig(:,exFactor:end);


        sbar=W{eaf_num}*eSig;%%%%%%CKC的估计值定义
        plot(sbar);title(sbar)
        testIPT=sbar;
        MUpulse_online={};
        for mu=1:size(testIPT,1)
            t_new = testIPT(mu,:);
            t_new([1:exFactor,end-exFactor+1:end]) = 0;
            tT = abs(t_new).*t_new;
            if  -min(t_new) > max(t_new)
                tT(find(t_new>0)) = 0;
            else
                tT(find(t_new<0)) = 0;
            end
            tT = abs(tT); plot(tT)
            edgepoint = 10*10;
            fsamp=2048;
            [compInd,spikeSIL,C] = spikeExtraction(tT(edgepoint+1:end-edgepoint)',fsamp);
            compInd = compInd+exFactor;
            compInd = remRepeatedInd(tT,compInd,round(fsamp/100));
            MUpulse_online{mu}=compInd;
        end
        Pulses_all{trial,eaf_num}=MUpulse_online;
    end
end