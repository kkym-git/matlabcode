function [muapArrays,muaps,exMUSTs] = muapExtraction(sig,pulses,N,method)
% -- Created by CC on 2021/9/18 -- Email: cedric_c@126.com %
% This function extracts the MUAP from EMG signals.
% Input
%   sig: the EMG signals in cell or matrix format. The dimension should be channels*samples if in matrix format.
%   pulses: the pulses in cell format or spike trains in matrix format
%   N：muap的长度（采样点数）
% Output
%   muap: the MUAPs in matrix format
%   muapArray: the MUAPs in cell format

%%% preprocess the data
if iscell(sig)
    [rn,cn] = size(sig);
    data = [];
    empInd = [];
    for c = 1:cn
        for r = 1:rn
            if ~isempty(sig{r,c})
                data((c-1)*rn+r,:) = sig{r,c};
            else
                empInd(end+1) = (c-1)*rn+r;
            end
        end
    end
    for r = 1:rn*cn
        if ~isempty(sig{r})
            len = length(sig{r});
            break;
        end
    end
else
    data = sig;
    len = length(sig);
end

switch method
    case 'LS'
        if iscell(pulses)
            MUSTs = pulse2spiketrain(pulses,len);
        else
            MUSTs = pulses;
        end
        %%% least square
        exMUSTs = extend(MUSTs,N);
        exMUSTs = exMUSTs(:,N/2+1:end-N/2+1)';
        % muaps = inv(exMUSTs'*exMUSTs)*exMUSTs'*data';
        muaps = inv(exMUSTs'*exMUSTs)*exMUSTs'*data';
        numMU = size(MUSTs,1);
    case 'STA'
        %%% spike-triggered averaging
        if iscell(pulses)
            MUSTs = pulses;
        else
            MUSTs = spiketrain2pulse(pulses);
        end
        numMU = length(MUSTs);
        numCh = size(data,1);
        muaps = zeros(numMU*N,numCh);
        for ch = 1:numCh % channel
            for mu = 1:numMU % MU
                tmpPulses = pulses{mu};
                sigave = zeros(1,N);
                k = 0;
                for s = 1:length(tmpPulses) % spike
                    if tmpPulses(s)>=N/2+1 && tmpPulses(s)<=len-N/2+1

                    sigave = sigave+data(ch,tmpPulses(s)-N/2:tmpPulses(s)+N/2-1);
                    % if tmpPulses(s)>=1 && tmpPulses(s)<=len-N+1
                        % sigave = sigave+data(ch,tmpPulses(s):tmpPulses(s)+N-1);
                        k = k+1;
                    end
                end
                sigave = sigave/k;
                muaps((mu-1)*N+1:mu*N,ch) = sigave;
            end
        end
end
if iscell(sig) % re-arrange the muap depending on the dimension of sig
    muapArrays = cell(1,numMU);
    for r = 1:rn
        for c = 1:cn
            for mu = 1:numMU
                if ismember((c-1)*rn+r,empInd)
                    muapArrays{mu}{r,c} = [];
                else
                    muapArrays{mu}{r,c} = muaps((mu-1)*N+1:mu*N,(c-1)*rn+r)';
                end
            end
        end
    end
else
    muapArrays = {};
end