
%% get MVC
%MVC=mean(maxk(Force,20))-mean(min(Force,20))
%offset=3350+22.5+15+145-200;

%% INPUT!!!!!!!  
clear all
clc

MVC=1967;
offset=3380;

trial=4;
level=0.3; 
digit=9;

sub=4;
type=2;
totaltime=50;
W={"fix" "trapezoid" "triangle" "sinusoidal"};
D={"index" "middle" "ring" "little" "indexmiddle" "middlering" "3digits" "4digits" "fist"};

%% Check Duplicate
% filename="rawData_sub"+sub+"_"+D{digit}+"_"+level*100+"%mvc_"+W{type}+"_trial"+trial;
% if exist(filename+".mat", 'file')
%     a = input('Duplicate Name, Continue?');
% end
 %arduinoObj = serialport("COM3",9600);

%% Biometrics Device 
int32 ch;
ch = 0;
values = libstruct('tagSAFEARRAY');
numberOfValues = getData(ch, getSampleRate(ch), 50000, values);
%writeline(arduinoObj,'1')
Force=[];Force=[Force values.pvData+offset];


x2=double(1:numberOfValues);
y2=double(values.pvData+offset);
xoffset=numberOfValues;

clf
h=plot(nan,nan);ax=gca; 
set(gcf, 'Position',  [1930, 40, 1900, 950]);

b=0;
if level==0.1
    parameter=[5 2 15 2];
else
    parameter=[5 5 10 5];
end
%parameter=[5,1];
while b<totaltime
    hold on;
    [~,b]=drawTrack(b,level*MVC,parameter);
end

L=[];
tic
tag=0;
for i=1:1500*totaltime/25
    numberOfValues = getData(ch, getSampleRate(ch), 1000, values);
    yvec=double(values.pvData+offset);
    xvec=double((xoffset+1):(xoffset+length(values.pvData)));
   
    set(h,'XData',xvec,'YData',yvec,'Color','r','Linewidth',5);
    ax.XLim=[0 50*double(getSampleRate(ch))];
    ax.YLim=[-100 level*MVC+200];    
    title([num2str(toc) ' s'])

    xoffset=xoffset+length(values.pvData);
    Force=[Force values.pvData+offset];

%     if i==1
%         writeline(arduinoObj,'1')
%     end
   
    %L(end+1)=length(values.pvData); 
    if length(values.pvData)==0
        tag=tag+1;
    else
        tag=0;
    end

    if tag>5
        break
    end
    
    pause(0.01);
end
tag
%writeline(arduinoObj,'1')
numberOfValues = getData(ch, getSampleRate(ch), 50000, values);
filename="rawData_sub"+sub+"_"+D{digit}+"_"+level*100+"%mvc_"+W{type}+"_trial"+trial;

disp(filename)
% save(filename,"Force","MVC","parameter",'-v7.3')

%delete(arduinoObj)

%rawData=readOTB('rawData_sub2_fist_50%mvc_trapezoid_trial2.otb+','D:\MU\experiment\20221116xy\');
     
