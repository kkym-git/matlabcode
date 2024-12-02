%绘制MUAP的demo
%对每个PT绘制MUAP 
%需要输入M L T gn
% clc;clear;close all;
%% 输入信号
% sigloadfile=['E:\data\sEMG-UU联合采集-24-3-27\EMGdataprocessed\emgwizcomb\KYM_M' num2str(M) 'L' num2str(L) 'T' num2str(T) '_comb111Hz.mat'];
% load(sigloadfile);
% part1=data_sEMG(1:32,:);
% part2=data_sEMG(33:64,:);
% part3=data_sEMG(65:96,:);
% part4=data_sEMG(97:128,:);
% sig{1}=[part1; part3];
% sig{2}=[part4; part2];
%%% 信号位置
% [sigcell]=sig2cell(sig{gn},2);

[sigcell]=sig2cell(datafilt,4);%对5*13数据
%% 输入放电串
% pulsefile=['E:\Result\327\13一组24一组\CBSS\KYM_M' num2str(M) 'L' num2str(L) 'T' num2str(T) '_decomposed.mat'];
% pulse_all=load(pulsefile);
% pulses=pulse_all.decomps{gn}.MUPulses;%CKC
% pulses=pulse_all.pulses{gn};%CBSS
% pulses=final.PT;%US

pulses=old;


%% 得到MUAP
[muaparray,~]=muapExtraction(sigcell,pulses,50,'STA');

%% 画图

% numpulse=length(pulses);
% for i=1:numpulse
%     figure;
%     [filterArray{i},maxAmp{i},maxPP{i},pos{i}] = plotArrayPotential(muaparray{i},1,1);
% end