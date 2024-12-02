function [sigcell]=sig2cell(sig,i)
switch(i)
    case 1 %第一列是1-8
        for i=1:8
            sigcell{i,1}=sig(i,:);
            sigcell{i,2}=sig(i+8,:);
            sigcell{i,3}=sig(i+16,:);
            sigcell{i,4}=sig(i+24,:);
            % sigcell{i,5}=NaN;%超声区域
            % sigcell{i,6}=NaN;%超声区域
            sigcell{i,5}=sig(i+32,:);
            % sigcell{i,4}=NaN;
            % sigcell{i,5}=NaN;
            sigcell{i,6}=sig(i+40,:);
            sigcell{i,7}=sig(i+48,:);
            sigcell{i,8}=sig(i+56,:);
        end
    case 2 %第一行是8-1
        for i=1:8
            n=9-i;
            sigcell{1,i}=sig(n,:);
            sigcell{2,i}=sig(n+8,:);
            sigcell{3,i}=sig(n+16,:);
            sigcell{4,i}=sig(n+24,:);
            sigcell{5,i}=NaN;%超声区域
            sigcell{6,i}=NaN;%超声区域
            sigcell{7,i}=sig(n+32,:);
            % sigcell{i,4}=NaN;
            % sigcell{i,5}=NaN;
            sigcell{8,i}=sig(n+40,:);
            sigcell{9,i}=sig(n+48,:);
            sigcell{10,i}=sig(n+56,:);
        end
    case 3 %5*13的grid，长边垂直于肌纤维
        for i=1:12
            sigcell{1,i}=sig(13-i,:);
        end
        sigcell{1,13}=NaN;
        for i=1:13
            k=13-i;
            sigcell{2,i}=sig(i+12,:);
            sigcell{3,i}=sig(k+26,:);
            sigcell{4,i}=sig(i+38,:);
            sigcell{5,i}=sig(k+52,:);
        end
    case 4%5*13的grid，长边平行于肌纤维
        for i=1:12
            sigcell{i+1,1}=sig(i,:);
        end
        % sigcell{1,1}=NaN;
        for i=1:13
            k=13-i;
            sigcell{i,2}=sig(k+13,:);
            sigcell{i,3}=sig(i+25,:);
            sigcell{i,4}=sig(k+39,:);
            sigcell{i,5}=sig(i+51,:);
        end
        % sigcell{7,2}=zeros(1,length(sigcell{1,2}));
    case 5%8*8grid,左上角64右下角1(设备：mouvi+pro)
        k=1;
        for j=8:-1:1
            for i=8:-1:1
                sigcell{i,j}=sig(k,:);
                k=k+1;
            end
        end
    case 6%8*8grid,左下角1右上角64(设备：紫ot)
        k=1;
        for j=1:1:8
            for i=8:-1:1
                sigcell{i,j}=sig(k,:);
                k=k+1;
            end
        end
end