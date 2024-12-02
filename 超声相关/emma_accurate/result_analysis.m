function [final]=result_analysis(result)
%%
sbar=result.truesourse;
soursesave=result.soursesave;
w_sourse=result.w.w_sourse;
w=result.w.w;
PT=result.PT;
energy_ratio=result.record.energy_ratio;%%%可能需要全谱？
CoV=result.record.CoV;
mad_record=result.record.mad;
outrecord=result.record.outrecord;
lP=result.position;
%%
% for i=1:175
%     if ~isempty(soursesave{i})
%         for j=1:10
%             if ~isempty(soursesave{i})
idx=~cellfun('isempty', soursesave);
a_notempty=lP(idx); %取的roi的编号%%%%%%%%%%%%%%%%%需要保存，记录位置的
%%
a_record=cell(size(a_notempty));% 邻近的roi编号记录（树状）
a_flag=zeros(size(a_notempty));
for i=1:length(a_notempty)
    %%%%找是否周围的有源
    idxsave=zeros(size(a_notempty));
    a_flag(i)=1;
    findsurrounding=false;
    j=1;
    surr=around(a_notempty(i));
    idx=find(surr);
    surr=surr(idx);
    for k=1:length(surr)
        if find(a_notempty==surr(k))
            idxsave(j)=find(a_notempty==surr(k));%返回周围源的坐标
            j=j+1;
            findsurrounding=true;
        end
    end
    if findsurrounding
        while true
            j=j-1;
            if a_flag(idxsave(j)) ~= 0
                %把两个地方的源拿出来对比，得到综合的源
                idxsave(j)=[];
            else
                a_flag(idxsave(j))=1;
            end
            if j==1 break; end
        end
        idxsave=idxsave(find(idxsave));%%%%%%%%
        a_record{i}=idxsave;
    end
end
%% 得到非空的源
allsourse=cell(3,length(a_notempty));
for i=1:length(a_notempty)
    idx=~cellfun('isempty', soursesave{a_notempty(i)});
    allsourse{1,i}=sbar{a_notempty(i)}(idx);%非空的源
    allsourse{2,i}=a_notempty(i);%对应的roi坐标
    allsourse{3,i}=find(idx);%对应的循环次数
    allsourse{4,i}=PT{a_notempty(i)}(idx);
    allsourse{5,i}=zeros(size(find(idx)));
    allsourse{6,i}=CoV{a_notempty(i)}(idx);
    allsourse{7,i}=length(find(idx));
    %     allsourse{7,i}=energy_ratio{a_notempty(i)}(idx);
    % if isempty(a_record)
end
%%
matchidx=1;
for i=1:length(a_notempty)
    if ~isempty(a_record{i})
        for k=1:length(a_record{i})%配对的roi的索引
            for j=1:allsourse{7,i}%roi共有几个源
                for l=1:allsourse{7,a_record{i}(k) }%配对的roi有几个源
                    [R,~]=xcorr(allsourse{1,i}{j},allsourse{1,a_record{i}(k)}{l},'coeff');
                    match(1,matchidx)=max(R);
                    match(2,matchidx)=i;% 配对1的roi在all_sourse中的索引
                    match(3,matchidx)=j;% 配对1在all_sourse{i}中的索引
                    match(4,matchidx)=a_record{i}(k);
                    match(5,matchidx)=l;
                    matchidx=matchidx+1;
                end
            end
        end
    end
end
%%
same_idx=(find(match(1,:)>0.3));
for i=1:length(same_idx)
    first=match(2:3,same_idx(i));
    second=match(4:5,same_idx(i));
    cov_compare(1)=allsourse{6,first(1)}{first(2)};
    cov_compare(2)=allsourse{6,second(1)}{second(2)};
    if cov_compare(1)>cov_compare(2)
        allsourse{5,first(1)}(first(2))=1;
    else
        allsourse{5,second(1)}(second(2))=1;
    end
end
%%
num_mu=0;
for i=1:length(a_notempty)
    for j=1:allsourse{7,i}
        if(~allsourse{5,i}(j))
            num_mu=num_mu+1;
            final.PT{num_mu}=allsourse{4,i}{j};
            final.CoV(num_mu)=allsourse{6,i}{j};
            final.Roi(num_mu)=allsourse{2,i};
            final.sourse{num_mu}=allsourse{1,i}{j};
        end
    end
end
final.num_mu=num_mu;
end
%%

% final_num=1;
% for i=1:length(a_notempty)
%     if isempty(a_record{i})%没有交界的源
%         j=1;
%         while true
%             finalsourse{1,final_num}=allsourse{1,i}{j};
%             finalsourse{2,final_num}=allsourse{2,i};
%             final_num=final_num+1;
%             j=j+1;
%             if j>length(allsourse{1,i})
%                 break
%             end
%         end
%     else
%         num_sourse=length(allsourse{1,i});
%         for j=1:length(a_record{i})
%             overlap_idx=a_record{i}(j);
%             for k=1:length(allsourse{1,overlap_idx})
%                 %%%%%%%%%%%%比较两个，留Cov小的
%
%             end
%         end
%     end
% end
