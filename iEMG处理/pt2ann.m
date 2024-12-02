function pt2ann(PT,fsamp_sEMG,filename)
%   此处显示详细说明
tmpdata=[];
for i=1:length(PT)
    tmpdata(i,1)=PT(i)/fsamp_sEMG;
    tmpdata(i,2)=1;
end

mat2ann(tmpdata,filename)

end