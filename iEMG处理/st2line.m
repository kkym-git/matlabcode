function Lines = st2line(STs,startInd,stopInd)
% -- Created by CC -- Email: cedric_c@126.com %
% this function transfers the spike trains into the line migntvector which could be
% used for plot 
if ~iscell(STs)
    tmpST = STs(find(STs>=startInd));
    tmpx = repmat(tmpST,3,1);
    tmpx = reshape(tmpx,1,numel(tmpx));
    
    tmpy = repmat([0.1,0.9,0.1],1,length(tmpST));
    Lines.x = [startInd,tmpx,stopInd];
    Lines.y = [0.1,tmpy,0.1];
else
    Lines = cell(1,length(STs));
    for mu = 1:length(STs)
        tmpST = STs{mu}(find(STs{mu}>=startInd));
        tmpx = repmat(tmpST,3,1);
        tmpx = reshape(tmpx,1,numel(tmpx));
        tmpy = repmat([0.1,0.9,0.1],1,length(tmpST));
        Lines{mu}.x = [startInd,tmpx,stopInd];
        Lines{mu}.y = [0.1,tmpy,0.1];
    end
end
    