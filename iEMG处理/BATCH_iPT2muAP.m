% 批量保存png&cell格式的ipt trigger的muap图
% KYM 24/11/28
clearvars -except CKCdecomp;close all;
fsamp=2048;
for motion=3
    for level=1:1
        for trial=1:4
            %% 数据输入
            eafpath=['Z:\Result\24-10-12iEMG-sEMG\M' num2str(motion) 'L' num2str(level) 'T' num2str(trial) '.eaf'];
            % eafpath = ['Z:\data\24-6-21iEMG-US-sEMG联合采集_康亦铭右肱二头\signal\iEMG_sEMG_US肌电后处理\iEMG_HDsEMG_S1_M' num2str(motion) '_level' num2str(level) '_trial' num2str(trial) '_24-06-21_UUS.eaf'];%iPT
            % eafpath = ['Z:\data\24-6-21iEMG-US-sEMG联合采集_康亦铭右肱二头\signal\iEMG_sEMG后处理\iEMG_HDsEMG_S1_M' num2str(motion) '_level' num2str(level) '_trial' num2str(trial) '_24-06-21.eaf'];%iPT

            % eafpath=['Z:\data\24-7-30iEMG-sEMG联合采集_陈晨右前臂肱桡肌\肌内肌电anneaf\xEMG-L' num2str(2.5*level) 'T' num2str(trial) '.eaf'];
            % eafpath=['Z:\Result\24-08-22iEMG-US-sEMG联合采集__胡康生右肱二头肌\M' num2str(motion) 'L' num2str(level) 'T' num2str(trial) '.eaf'];
            % eafpath=['Z:\Result\24-08-29iEMG-US-sEMG联合采集_程瑞佳\eaf\M' num2str(motion) 'L' num2str(level) 'T' num2str(trial) '.eaf'];
            iPT=eaf2pulse(eafpath,fsamp);
            

            % clf;
            % pic=draw_PluseTime(iPT,fsamp,1,30);
            % title(['iEMG-PT-M' num2str(motion) 'L' num2str(level) 'T' num2str(trial)])


         
            datafilt=CKCdecomp{motion,trial}.datafilt;
            
            % emgpath=['Z:\data\24-6-21iEMG-US-sEMG联合采集_康亦铭右肱二头\signal\iEMG_sEMG_US肌电后处理\HDsEMG_iEMG_S1_M' num2str(motion) '_level' num2str(level) '_trial' num2str(trial) '_24-06-21_UUS.mat'];
            % emgpath=['Z:\data\24-6-21iEMG-US-sEMG联合采集_康亦铭右肱二头\signal\iEMG_sEMG后处理\HDsEMG_iEMG_S1_M' num2str(motion) '_level' num2str(level) '_trial' num2str(trial) '_24-06-21.mat'];
            % 
            % load(emgpath);
            % datafilt=decompData;
            
            %% 计算muap
            [sigcell]=sig2cell(datafilt,6);%%%%%%%%%%%%  5*13-type4 8*8ot-type6
            [muaparray,~]=muapExtraction(sigcell,iPT,100,'STA');
            
            nummu=size(iPT,2);
            for which2show=1:nummu
               
                muap_recon=muap_pca(muaparray{which2show},0.95);

                %手动去除通道
                % muap_recon{7,3}=NaN;

                %绘图并保存
                % figure
                % plotArrayPotential(muap_recon,1,1);
                % title(['M' num2str(motion) 'L' num2str(level) 'T' num2str(trial) ' MUAP by iPT#' num2str(which2show) ])
                % savefile=['Z:\Result\24-10-12iEMG-sEMG\iPT2muAP'];
                % saveas(gcf,[savefile '\iMUAP M' num2str(motion) 'L' num2str(level) 'T' num2str(trial) '#' num2str(which2show) '.png'] )

                %保存成cell形式
                muaparray_cell{level,trial}{which2show}=muap_recon;
            end
        end
    end
end
close all