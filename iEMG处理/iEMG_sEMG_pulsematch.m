% clear;

path_semg = 'Z:\Result\24-08-29iEMG-US-sEMG联合采集_程瑞佳\829_xEMG_CKC_decomp_filtfilt_20-500.mat' ;
load(path_semg)
% fsampu = 10240; % iEMG、sEMG采样率
%%
% for motion=1:2
motion = 2;
for level = 1:1
    for trial = 1:1
        % if level==1&&trial==4
        %     trial=5;
        % end
        path_eaf = ['Z:\data\24-08-29iEMG-US-sEMG联合采集_程瑞佳\eaf\M' num2str(motion) 'L' num2str(level) 'T' num2str(trial) '.eaf'];
        %%

        iPulses = eaf2pulse(path_eaf,2048); 
        Pulses = CKCdecomp{level,trial}.MUPulses;%CKC
        Pulses = MUPulses
        % Pulses=CBSSdecomp{level,trial};%CBSS

        matchtable{level,trial}=PulseMatch(Pulses,iPulses,0.3,2048);
    end
end

% %% 查看RoA
% 
% k=1;
% RoA={};
% for i=1:1:1
%     for j=1:1:10
%         if  size(matchtable{i,j},2)==1
%             continue
%         end
%         RoA(:,k)=table2cell( matchtable{i,j}(:,4));
%         k=k+1;
%     end
% end
%% 查看具体情况
% idx=1;%表面肌电
% idx_i=2;
% plusecompare{1}=Pluses{idx};
% plusecompare{2}=iPluses{idx_i};
% draw_PluseTime(plusecompare,10240);
% ylabel(['表面肌电','肌内肌电']);