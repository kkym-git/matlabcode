function [muap] = muap_interpolation(muap,pos)
% muap_interpolation 对muap有错误的地方进行插值
%   by KYM 24/11/28
x=pos(1);
y=pos(2);
muap{x,y}=(muap{x,y+1}+muap{x,y-1}+muap{x-1,y+1}+muap{x-1,y}+muap{x-1,y-1}+muap{x+1,y+1}+muap{x+1,y}+muap{x+1,y-1})/8;

end