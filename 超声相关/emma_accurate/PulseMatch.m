function [MatchResult,MatchResult_raw] = PulseMatch(Pulses1,Pulses2,thresh,fsamp)
% -- Created by CC -- Email: cedric_c@126.com %
% This function calculates the matching results between two pulse groups.
% INPUT
%   Pulses1: a cell containing pulse trains of group 1 (usually the decoded pulses)
%   Pulses2: a cell containing pulse trains of group 2 (usually the true pulses)
%   thresh: the threshold set for the matching sensitivity with the default value of 0.3
% OUTPUT
%   MatchResult: a table containing matching results
% 
% frist created on 2019-1-23 by CC

% dIPI = round(0.0005*fsamp);

% dIPI = round(0.0005*fsamp);
if nargin<3
    thresh = 0.3;
    fsamp = 2048;
end
dIPI = round(0.002*fsamp);
lim = round(0.05*fsamp);

MatchResult_raw = [];

num1 = length(Pulses1);
% num2 = length(Pulses2);
for p1 = 1:num1
    tmpp1 = Pulses1{p1};
    [dS,dSen,dLag] = sortIPTcorr(Pulses2,tmpp1,dIPI,[],thresh);% {pPulse{Ind}} or pPulses(Ind) to ensure the input is a cell 
    tmpInd = find(dS==1);
    if isempty(tmpInd)
        continue;
    end
    for i = tmpInd'
        [rr,tmpLag] = RoA(tmpp1,Pulses2{i},lim,dIPI);
%         MatchResult_raw(end+1,:) = [p1,i,dSen(i),rr,dLag(i)];
        MatchResult_raw(end+1,:) = [p1,i,dSen(i),rr,tmpLag];
    end
end

if isempty(MatchResult_raw)
    MatchResult_raw = 0;
    MatchResult = 0;
    disp('No matched pulse trains have been found!');
    return;
end

MatchResult = MatchResult_raw;
for mu1 = 1:num1
    tmpInd = find(MatchResult(:,1)==mu1);
    if length(tmpInd)>1
        [~,tmpInd2] = max(MatchResult(tmpInd,4));
        deleteInd = setdiff(1:length(tmpInd),tmpInd2);
        MatchResult(tmpInd(deleteInd),:) = [];
    end
end
for mu2 = 1:length(Pulses2)
    tmpInd = find(MatchResult(:,2)==mu2);
    if length(tmpInd)>1
        [~,tmpInd2] = max(MatchResult(tmpInd,4));
        deleteInd = setdiff(1:length(tmpInd),tmpInd2);
        MatchResult(tmpInd(deleteInd),:) = [];
    end
end

% calculate the accuracy measurement
tmplen = size(MatchResult,2);
for i = 1:size(MatchResult,1)
    ST_decomp = Pulses1{MatchResult(i,1)};
    ST_true = Pulses2{MatchResult(i,2)};
    
    [Sen,FA,Pre,Spe,Acc] = accEvaluation(ST_decomp,ST_true,dIPI,lim);
    [rr,tmpLag] = RoA(ST_decomp,ST_true,lim,dIPI);
    
    MatchResult(i,tmplen+1:tmplen+5) = [Sen,FA,Pre,Spe,Acc];
end

MatchResult_raw = array2table(MatchResult_raw,'VariableNames',{'Pulses1','Pulses2','Sensitivity','RoA','Lag'});
MatchResult = array2table(MatchResult,'VariableNames',{'Pulses1','Pulses2','Sensitivity','RoA','Lag','Sensitivity_CC','FalseAlarm','Precision','Specificity','Acc'});

   
   