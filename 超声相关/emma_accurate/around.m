function [surr]=around(a)%只考虑目前40*128
    surr=zeros(1,8);
    row=mod(a,7);
    column=(a-row)/7+1;
    location{1}=[row-1,column-1];% 从左上顺时针
    location{2}=[row-1,column];
    location{3}=[row-1,column+1];
    location{4}=[row,column+1];
    location{5}=[row+1,column+1];
    location{6}=[row+1,column];
    location{7}=[row+1,column-1];
    location{8}=[row,column-1];
    %1 2 3 column
    %8 x 4
    %7 6 5
    %row
    if(row-1<1) for i=1:3 location{i}=[]; end; end
    if(column-1<1) location{1}=[];location{7}=[];location{8}=[]; end
    if(row+1>7) for i=5:7 location{i}=[]; end; end
    if(column+1>25) for i=3:5 location{i}=[]; end; end
    
   for i=1:8
       if(~isempty(location{i}))
           surr(i)=location{i}(1)+7*(location{i}(2)-1);
       end
   end
end