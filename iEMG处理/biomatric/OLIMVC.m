%%%biomatrics 视觉引导 测力 
%1.打开bio系统，app中取消保存
%2.打开matlab，运行DataLogInit
%3.运行本脚本
%%% from xmj written by kym 24-04
clear all
close all
clc
%% 取MVC
offset=-2540;
int32 ch;
ch = 18;%取决于传感器的位置
values = libstruct('tagSAFEARRAY');
numberOfValues = getData(ch, getSampleRate(ch), 50000, values);
Force=[];Force=[Force values.pvData-offset];
% plot(Force)
MVC=prctile(Force,99);%不确定取法
%% 得到lag值，对图窗初始化
clf
h=plot(nan,nan,nan,nan);ax=gca; 
%set(gcf, 'Position',  [3841 -664 1920 962]);
% set(gcf, 'Position',  [1285 642.3333 1.2773e+03 714.6667]);

x2=double(1:numberOfValues);
y2=double(values.pvData-offset);
xoffset=numberOfValues;

b=double(max(x2))/double(getSampleRate(ch));
lag=b;

%% Start acquiring
tic
%s=serialport("COM3",9600);
%delete(s)
tag=0;
totaltime=1000;
xlim([0 (totaltime+lag+2)*double(getSampleRate(ch))]);xlabel('Time')
ylim([0,50]);ylabel('%MVC')%y轴只显示0-50%MVC

yline(10,'LineStyle','--')%10%MVC的虚线

for i=1:65*(totaltime+lag)
    %channel 1
    numberOfValues = getData(ch, getSampleRate(ch), 200, values);
    yvec=double(values.pvData-offset)./ double(MVC)*100;
    xvec=double((xoffset+1):(xoffset+length(values.pvData)));

    set(h(1),'XData',xvec,'YData',yvec,'Color','r','Linewidth',15);
    title([num2str(toc) ' s'])

    xoffset=xoffset+length(values.pvData);
    Force=[Force values.pvData-offset];

    % %channel 2
    % numberOfValues2 = getData(ch2, getSampleRate(ch2), 200, values2);
    % xvec2=double((xoffset+1):(xoffset+length(values2.pvData)));
    % yvec2=-abs(double(values2.pvData-offset2)./MVC(2)*100);
    % 
    % set(h(2),'XData',xvec2,'YData',yvec2,'Color','g','Linewidth',15);
    % Force2=[Force2 values2.pvData-offset2];


    if length(values.pvData)==0
        tag=tag+1;
    else
        tag=0;
    end

    if tag>5
        print('break');
        break
    end
    pause(0.01)
end
%% 
filename=[date 'forcedata4']
save(filename,"Force","MVC","lag")
plot(Force)