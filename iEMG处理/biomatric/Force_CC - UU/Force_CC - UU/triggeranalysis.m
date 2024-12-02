% ind = find(Data{1}<3.7);
% ind(find(diff(ind)==1)) = [];
% (ind(end)-ind(1))/10240

%%
clear;
close all;

fsamp = 2048;
[file,path] = uigetfile('*.otb+');

[data,fsamp] = OpenOTBfilesBatch([path file]);
fsamp = fsamp{1};
data = data(1,:);
figure;plotsig_cc(data,fsamp);
ind = find(data<3000);
ind(find(diff(ind)<=5)+1) = [];
dua = (ind(end)-ind(1))/fsamp
dua_each = diff(ind)/fsamp
sum(dua_each)



