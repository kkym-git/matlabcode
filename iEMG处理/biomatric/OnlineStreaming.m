
%% Input
clear all
close all
clc

MVC=[800 600]; 
offset=-2540; 
offset2=-3133;
 
task  =5  %1-4 60s; 5-8 120s; 9-12 120s
level =10  %MVC:10 30 
trial =1;

sub="test";
D={"finger_12"      "finger_34"      "wrist_flexion"    "wrist_extension"...
    "wrist_flex_finger12"   "wrist_flex_finger34" "wrist_ext_finger12"    "wrist_ext_finger34"...
    "wrist_flex_finger12"   "wrist_flex_finger34" "wrist_ext_finger12"    "wrist_ext_finger34"};

%% Biometrics Channel 1 :P200
int32 ch;
ch = 18;
values = libstruct('tagSAFEARRAY');
numberOfValues = getData(ch, getSampleRate(ch), 50000, values);
Force=[];Force=[Force values.pvData-offset];

%s=serialport("COM3",9600);
%delete(s)
%% Biometrics Channel 2 :S1000
int32 ch2
ch2=18;
values2 = libstruct('tagSAFEARRAY');
numberOfValues2 = getData(ch2, getSampleRate(ch2), 50000, values2);
Force2=[];Force2=[Force2 values2.pvData-offset2];

%% experTrack
clf
h=plot(nan,nan,nan,nan);ax=gca; 
%set(gcf, 'Position',  [3841 -664 1920 962]);
set(gcf, 'Position',  [1285 642.3333 1.2773e+03 714.6667]);

x2=double(1:numberOfValues);
y2=double(values.pvData-offset);
xoffset=numberOfValues;

b=double(max(x2))/double(getSampleRate(ch));
lag=b;

%b=expertrack(b,task,level,MVC{task},double(getSampleRate(ch))) %expertrack(b,2,3,[1500 300],200); 
b=expertrack1(b,task,double(getSampleRate(ch)));ylabel('%MVC');
totaltime=b;
xlim([0 (totaltime+lag+2)*double(getSampleRate(ch))]);xlabel('Time')

%% Start acquiring
tic
%s=serialport("COM3",9600);
%delete(s)
tag=0;

for i=1:65*(totaltime+lag)
    %channel 1
    numberOfValues = getData(ch, getSampleRate(ch), 200, values);
    yvec=double(values.pvData-offset)./MVC(1)*100;
    xvec=double((xoffset+1):(xoffset+length(values.pvData)));

    set(h(1),'XData',xvec,'YData',yvec,'Color','r','Linewidth',15);
    title([num2str(toc) ' s'])

    xoffset=xoffset+length(values.pvData);
    Force=[Force values.pvData-offset];

    % %channel 2
    numberOfValues2 = getData(ch2, getSampleRate(ch2), 200, values2);
    xvec2=double((xoffset+1):(xoffset+length(values2.pvData)));
    yvec2=-abs(double(values2.pvData-offset2)./MVC(2)*100);

    set(h(2),'XData',xvec2,'YData',yvec2,'Color','g','Linewidth',15);
    Force2=[Force2 values2.pvData-offset2];


    if length(values.pvData)==0
        tag=tag+1;
    else
        tag=0;
    end

    if tag>5
        break
    end
    pause(0.01)
end
% ax.XLim=[0 toc*double(getSampleRate(ch))];
%s=serialport("COM3",9600);
%delete(s)
tag
numberOfValues = getData(ch, getSampleRate(ch), 50000, values);

%% save Data
filename="rawData_sub"+sub+"_"+D{task}+"_"+level+"%mvc_trial"+trial;

disp(filename)
save(filename,"Force","Force2","MVC","lag",'-v7.3')
%rawData=readOTB('rawData_subxmj_testing_3%mvc_trial1.otb+','D:\MU\experiment\20230609\');
figure;plot(Force);hold on;plot(Force2); set(gcf, 'Position',  [3841 -664 1920 300]);title("rawData_sub"+sub+"_"+D{task}+"_"+level+"%mvc_trial"+trial)
