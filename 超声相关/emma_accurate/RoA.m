function [r,Lag] = RoA(Ind1,Ind2,Lim,dIPI)
% -- revised on 2023-4-4 -- optimze the selection when more than one sample
% point owning the maximum common spikes: previous-the lowest lag,
% current-the point where there are maximum common spike within the dIPI
% -- Created by CC -- Email: cedric_c@126.com %

xcor = zeros(2*Lim+1,1);
for k = -Lim:Lim
    xcor(k+Lim+1) = length(intersect(Ind1,Ind2+k));
end 
a = find(xcor == max(xcor));
if length(a)>1
    %%%%% revised on 2023-4-4 %%%%%
    tmpCom = zeros(1,length(a));
    for i = 1:length(a)
        tmpCom(i) = sum(xcor(max(1,a(i)-dIPI):min(a(i)+dIPI,length(xcor))));
    end
    [~,tmpind] = max(tmpCom);
    a = a(tmpind);
    %%%%% revised on 2023-4-4 %%%%%

%     tmp = abs(a-Lim);
%     [~,tmpind] = min(tmp);
%     a = a(tmpind);

end
A = sum(xcor(max(1,a-dIPI):min(a+dIPI,length(xcor))));
if A>min(length(Ind1),length(Ind2))
    A = min(length(Ind1),length(Ind2));
end
Lag = a-Lim;
r = A/(length(Ind1)+length(Ind2)-A);
end