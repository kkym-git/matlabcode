function Force
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Original author Lin Yao                                                %
% Updated by Chen.C @ Force track                                        %
% updated by Guangye Li @2016.06.20 @SJTU @liguangye.hust@gmail.com      %
% update contents: make the code compatible in 64-bit Win System         %
% Under MATLAB R2015B                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;

global handles;

scrsz = get(0, 'ScreenSize');

handles.BIAS = 0;

handles.maximum = eps;

handles.minimum = eps;

%handles.Gain = Gain;

handles.fcinput = 5000;

handles.ForceChannel = 1;

handles.AccChannel = 1;

handles.c=0;

% handles.fbrange = 5;
%
% handles.fbwidth = 0.5;

handles.FileCounter = 0;

handles.IntrvlIndxSpec=0;

handles.MVCnum=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%handles.filetype = '.daq';
% handles.sessionnum =1;
handles.sessionnum = input('Which session is this experiment? (0/1), input 0 if just for test!\');
%%%%%%%%%% Check comport no in your PC %%%%%%%%%%%%%%%%%
comnum=3;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.val=0;
handles.subtrial=10;
handles.order = [ones(1,handles.subtrial),ones(1,handles.subtrial)*2,ones(1,handles.subtrial)*3,ones(1,handles.subtrial)*4];
handles.trialnum=1;
handles.trialnummax=length(handles.order);
% handles.order=handles.order(randperm(length(handles.order)));
% handles.trapx = cell(1,length(handles.order));
% handles.trapy = cell(1,length(handles.order));
% handles.taskover=zeros(1,length(handles.order));
% handles.trialL=15*ones(1,length(handles.order));
% for i = 1:length(handles.order)
%     if handles.order(i) == 1 % slow 20% MVC
%         tmp = 20;
%         handles.trapx{i} = [0 2 5 7.5 7.5];
%         handles.trapy{i} = [0 0 tmp tmp 0];
%         handles.taskover(i)=handles.trapx{i}(end);
% %         handles.trialL(i)= handles.taskover(i)+handles.restp(i);
%         
%     elseif handles.order(i) == 2 % slow 60% MVC
%         tmp = 60;
%         handles.trapx{i} =  [0 2 11 13.5 13.5];
%         handles.trapy{i} = [0 0 tmp tmp 0];
%         handles.taskover(i)=handles.trapx{i}(end);
% %         handles.trialL(i)= handles.taskover(i)+handles.restp(i);
%     elseif handles.order(i) == 3 % fast 20% MVC
%         tmp = 20;
%         handles.trapx{i} = [0 2 3 5.5 5.5];
%         handles.trapy{i} = [0 0 tmp tmp 0];
%         handles.taskover(i)=handles.trapx{i}(end);
% %         handles.trialL(i)= handles.taskover(i)+handles.restp(i);
%     elseif handles.order(i) == 4 % fast 60% MVC
%         tmp = 60;
%         handles.trapx{i} = [0 2 5 7.5 7.5];
%         handles.trapy{i} = [0 0 tmp tmp 0];
%         handles.taskover(i)=handles.trapx{i}(end);
% %         handles.trialL(i)= handles.taskover(i)+handles.restp(i);
%     end
% end
% if handles.sessionnum~=0
% Info.task_time=handles.taskover;
% Info.trial_length=handles.trialL;
% Info.Yaxis=handles.trapy;
% Info.Xaxis=handles.trapx;
% Info.rest_time=handles.restp;
% Info.Exp_Seq=handles.order;
% save(strcat('Trigger_Information_',num2str(handles.sessionnum),'.mat'),'Info');
% end
%%%%%%%%%%%%%%%%%%%%%%%%DAQ SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[handles.filename,handles.pathname] = uiputfile('Subject.daq','Save datafile');
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for NIDAQ IN 32-BIT
% handles.ai = analoginput('nidaq','Dev1');
% set(handles.ai,'InputType','SingleEnded');
% handles.chani=addchannel(handles.ai,0:1);

% handles.ai.Channel.InputRange = [-5 5];
% set(handles.ai,'SampleRate' , handles.fcinput);
% handles.ai.Channel.Units=['Volts'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for NIDAQ IN 64-BIT

handles.ai = daq.createSession('ni');
handles.chani=addAnalogInputChannel(handles.ai,'Dev1','ai1','Voltage');
handles.chani.InputType='SingleEnded';

handles.chani.Range = [-5 5];
handles.ai.Rate=handles.fcinput;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set(handles.ai,'SampleRate' , handles.fcinput);
% handles.ai.Channel.Units=['Volts'];
%handles.ai.Channel.UnitsRange=[-1000 1000];
%handles.ai.Channel.SensorRange=[-str2double(handles.GAINS{5}) str2double(handles.GAINS{5})];

handles.RefreshRate = 0.1; % s

handles.T = 15; % s force screen time
handles.TsEMG = 0.1; % s sEMG screen time

p = get(0,'monitorpositions');
handles.pos = p;
if size(p,1)==1
    p=[p;p];
end
p(2,3)=p(1,3);
p(1,4)=800;

%%%%%%%%%%%% for feedback screen  %%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.plot1=figure('Position',p(2,:),'ToolBar','none','MenuBar','none');
%set(handles.plot1,'ToolBar','none','MenuBar','none');
handles.up1=line('xdata', 0, 'ydata', 0);
handles.RAW1 = line([0],zeros(1,1),'MarkerFaceColor','k','MarkerEdgecolor','k','Marker','O','Markersize',20);
axis off
%%%%%%%%%%%%%%% for operator screen %%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Position',p(1,:)),
handles.Splot1=subplot(3,1,1);
handles.up2=line('xdata', 0, 'ydata', 0);
handles.RAW2 = line([0],zeros(1,1),'MarkerFaceColor','k','MarkerEdgecolor','k','Marker','O','Markersize',20);
handles.up3 = line('xdata',0,'ydata',0,'LineWidth',3,'LineStyle','--');
ylabel('MVC%');

handles.Splot2=subplot(3,1,2);
handles.Acc = line([0:handles.RefreshRate*handles.fcinput-1],zeros(1,handles.RefreshRate*handles.fcinput),'Color','k');

xlim(handles.Splot2, 'auto');      %new
ylim(handles.Splot2,'auto');

xlabel('Time (s)');
ylabel('Amplitude (AU)');

%%%%%%%% the positions of plots according to figure frame%%%%%%%%%%%%%%%
Splot1Pos = get(handles.Splot1,'Position');
Splot1Pos(1) =  Splot1Pos(1)-0.1;
Splot1Pos(3) =  Splot1Pos(3)+0.17;
set(handles.Splot1,'Position',Splot1Pos);

Splot2Pos = get(handles.Splot2,'Position');
Splot2Pos(1) =  Splot2Pos(1)-0.1;
Splot2Pos(3) =  Splot2Pos(3)+0.17;
set(handles.Splot2,'Position',Splot2Pos);


handles.RecordButton = uicontrol('Style', 'pushbutton', 'String', 'RECORD',...
    'Position', [(p(1,3)-p(1,3)/1920*150) (p(1,4)-p(1,4)/1080*890) 100 40],'Callback', @Record);

handles.StopButton = uicontrol('Style', 'pushbutton', 'String', 'STOP',...
    'Position', [(p(1,3)-p(1,3)/1920*150) (p(1,4)-p(1,4)/1080*940) 100 40],'Callback', @StopDAQ);

handles.MVCButton=uicontrol('Style', 'pushbutton', 'String', 'MVC',...
    'Position', [(p(1,3)-p(1,3)/1920*1600) (p(1,4)-p(1,4)/1080*940) 100 100],'Callback', @MVCdata);

handles.MVCvalue = uicontrol('Style','edit','String',num2str(handles.maximum),...
    'FontSize',12,'Position', [(p(1,3)-p(1,3)/1920*1480) (p(1,4)-p(1,4)/1080*940) 100 50]);

handles.MVCtext = uicontrol('Style','text','Position',[(p(1,3)-p(1,3)/1920*1480) (p(1,4)-p(1,4)/1080*880) 100 30],...
    'String','MVC','FontSize',12);

handles.Func = uicontrol('Style','popup','String','Trap',...
    'Position',[(p(1,3)-p(1,3)/1920*1200) (p(1,4)-p(1,4)/1080*950) 150 30]);
% handles.Func = uicontrol('Style','popup','String','Straight Line|Trap|Triang|Chirp',...
%     'Position',[(p(1,3)-p(1,3)/1920*1200) (p(1,4)-p(1,4)/1080*950) 150 30]);

handles.Amp = uicontrol('Style','edit','String','15',...
    'Position',[(p(1,3)-p(1,3)/1920*1100) (p(1,4)-p(1,4)/1080*900) 50 30]);

handles.MVCtext = uicontrol('Style','text','Position',[(p(1,3)-p(1,3)/1920*1200) (p(1,4)-p(1,4)/1080*900) 50 30],...
    'String','MVC %','FontSize',10);

handles.Gain = uicontrol('Style','edit','String','1',...
    'Position',[(p(1,3)-p(1,3)/1920*1100) (p(1,4)-p(1,4)/1080*850) 50 30]);

handles.MVCtext = uicontrol('Style','text','Position',[(p(1,3)-p(1,3)/1920*1200) (p(1,4)-p(1,4)/1080*850) 50 30],...
    'String','GAIN','FontSize',10);

handles.UpDate = uicontrol('Style', 'pushbutton', 'String', 'Update FBack',...
    'Position', [(p(1,3)-p(1,3)/1920*1000) (p(1,4)-p(1,4)/1080*900) 100 50],'Callback', @UpdateFb);

handles.Bias = uicontrol('Style','slider','Min',1,'Max',5,'Value',1,'SliderStep',[0.25 0.25],...
    'Position', [p(1,3)-p(1,3)/1920*1100 p(1,4)-p(1,4)/1080*800 80 20],'Callback', @BiasControl);

handles.Biastext = uicontrol('Style','text','Position',[p(1,3)-p(1,3)/1920*1200 p(1,4)-p(1,4)/1080*800 80 20],...
    'String','Change Bias','FontSize',10);

%%%%%%%%%%%%%%%%%% default feedback%%%%%%%%%%%%%%%%%%
handles.amp = str2double(get(handles.Amp,'String'));
set(handles.up1,'xdata', [0 handles.T], 'ydata', [handles.amp handles.amp],'Color','r','Linewidth',5.5);
set(handles.up3,'xdata',[0 handles.T],'ydata', [handles.amp-(handles.amp*15/100) handles.amp-(handles.amp*15/100)],'Color','r','LineWidth',3,'LineStyle','--');
set(handles.up2,'xdata', [0 handles.T], 'ydata', [handles.amp handles.amp],'Color','r','Linewidth',5.5);
fig1=get(handles.plot1,'Children');
set(fig1,'XLim',[0 (handles.T*handles.fcinput-1)/handles.fcinput],'YLim',[-10 100]);
axis(handles.Splot1, [0 (handles.T*handles.fcinput-1)/handles.fcinput -10 100]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handles.ITIME = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%32bit
% set(handles.ai,'SamplesPerTrigger' , inf);
% set(handles.ai,'SamplesAcquiredFcnCount', handles.RefreshRate*handles.fcinput);
% set(handles.ai,'SamplesAcquiredFcn',@AcqForce);
%set(handles.ai,'LoggingMode','Memory');
% set(handles.ai,'LoggingMode','Disk&Memory');
% set(handles.ai,'LogFileName',[handles.pathname,handles.filename]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%64bit
handles.ai.IsContinuous=true;
% handles.ai.NotifyWhenDataAvailableExceeds = handles.RefreshRate*handles.fcinput;
% handles.ih = addlistener(handles.ai,'DataAvailable', @(src,event)AcqForce(src,event,handles.fid1));
%%%%%%%%%%%
set(handles.Func,'Value',1); %5
allports=instrfind;
if ~isempty(allports)
    fclose(instrfind);
end
global SerialPort;
%% open serial comport
SerialPort=serial(strcat('COM',num2str(comnum)), 'BaudRate', 9600);
if handles.sessionnum~=0
fopen(SerialPort);
end

% function AcqForce(obj,event) % 32bit
function AcqForce(src,event,fid) %64 bit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is used to set the details of Force acquisiion and        %
% data storage                                                            %
% the method is different in 32bit and 64 bit by LGY                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global handles;
global SerialPort;
%32bit
% handles.data = 1*getdata(handles.ai,handles.RefreshRate*handles.fcinput);

handles.ITIME = handles.ITIME + handles.RefreshRate;
if handles.ITIME > handles.T
    if handles.sessionnum~=0
    fprintf(SerialPort, '1');
    end
    handles.ITIME = 0;
    handles.trialnum = handles.trialnum+1;
    if handles.trialnum == handles.trialnummax+1
        handles.trialnum = 1;      
        delete(handles.ih);
        stop(handles.ai);
        fclose(handles.fid1);%64bit
%         disp(handles.trialnummax)
        disp(handles.sessionnum)
        set(handles.RecordButton,'Visible','on');
        set(handles.RecordButton,'BackgroundColor',[0.941176 0.941176 0.941176]);
        set(handles.MVCButton,'BackgroundColor',[0.941176 0.941176 0.941176]); 
        
        if handles.sessionnum~=0
         handles.sessionnum=handles.sessionnum+1;
        end
        return
    elseif handles.val==1
        handles.t = handles.trapx{handles.trialnum};
        handles.y = handles.trapy{handles.trialnum};
%       disp(['Trapezoid:' num2str(handles.trialnum) ', Contraction level:' num2str(max(handles.y))])
        set(handles.up1,'xdata', handles.t, 'ydata', handles.y,'Color','r','Linewidth',5);
        set(handles.up2,'xdata', handles.t, 'ydata', handles.y,'Color','r','Linewidth',5);
        fig1 = get(handles.plot1,'Children');
        set(fig1,'XLim',[0 (handles.T*handles.fcinput-1)/handles.fcinput],'YLim',[-5 80]);        
        axis(handles.Splot1, [0 (handles.T*handles.fcinput-1)/handles.fcinput -5 80]);
    end
end

if handles.BIAS == 0,
    %     handles.BIAS = mean(handles.data(:,handles.ForceChannel));
    handles.BIAS = mean(event.Data);
end

TEMP = event.Data - handles.BIAS;

if get(handles.MVCButton,'BackgroundColor')==[1 0 0],
    if max(TEMP) > handles.maximum,
        handles.maximum = max(TEMP);
        set(handles.MVCvalue,'String',num2str(handles.maximum))
    end
    % if min(handles.data(:,handles.ForceChannel)) < handles.minimum,
    %   handles.minimum = min(handles.data(:,handles.ForceChannel));
    %set(handles.MVCvalue,'String',num2str(handles.maximum))
    % end
else
    
    handles.maximum = str2double(get(handles.MVCvalue,'String'));
    %    handles.data=((handles.data/str2double(get(handles.Gain,'String')))/handles.maximum)*100;
    TEMP=((TEMP/str2double(get(handles.Gain,'String')))/handles.maximum)*100;
    
%     handles.maximum
  
end

%set(handles.RAW1,'XData',handles.ITIME,'YData',handles.data(end,handles.ForceChannel)-handles.BIAS);
%set(handles.RAW2,'XData',handles.ITIME,'YData',handles.data(end,handles.ForceChannel)-handles.BIAS);

%set(handles.RAW1,'XData',handles.ITIME,'YData',mean(handles.data(:,handles.ForceChannel)-handles.BIAS));
%set(handles.RAW2,'XData',handles.ITIME,'YData',mean(handles.data(:,handles.ForceChannel)-handles.BIAS));

if handles.val==1 && handles.ITIME> handles.taskover(handles.trialnum)+1
set(handles.RAW1,'XData',handles.ITIME,'YData',-10);
set(handles.RAW2,'XData',handles.ITIME,'YData',-10);  
else  
set(handles.RAW1,'XData',handles.ITIME,'YData',mean(TEMP));
set(handles.RAW2,'XData',handles.ITIME,'YData',mean(TEMP));
end
set(handles.Acc,'XData', [0:(handles.RefreshRate*handles.fcinput-1)], 'YData', TEMP);
data=[event.TimeStamps,event.Data]';
fwrite(fid,data,'double');


function MVCdata(obj,event)
global handles;

set(handles.RecordButton,'Visible','off');
set(handles.MVCButton,'BackgroundColor',[1 0 0]);

handles.FileCounter = handles.FileCounter + 1;
handles.StrFileCount = num2str(handles.FileCounter);
handles.filename2 = [handles.filename(1:end-4),'-',num2str(handles.sessionnum),'-',handles.StrFileCount,'_MVC',handles.filename(end-3:end)];
% set(handles.ai,'LogFileName',[handles.pathname,handles.filename2]);
handles.logfilename=[handles.pathname,handles.filename2];
handles.fid1=fopen(handles.logfilename,'w');

handles.BIAS = 0;

% start([handles.ai]);% 32bit
handles.ih=addlistener(handles.ai,'DataAvailable', @(src,event)AcqForce(src,event,handles.fid1));
handles.ai.startBackground();
% delete(handles.ih);


function BiasControl(obj,event)
global handles;
if handles.val ==1 && handles.val==2 && handles.val==3 && handles.val==4 && handles.val == 5 && handles.val == 6 && handles.val == 7
    %bias slider
end

function UpdateFb(obj, event)
global handles;
handles.val = get(handles.Func,'Value');
handles.amp = str2double(get(handles.Amp,'String'));
handles.bias = get(handles.Bias,'Value');

SLOPE = 3.0;SLOPEramp=1.5;
DUR = 30;
%handles.maximum = str2double(get(handles.MVCvalue,'String'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.order = [ones(1,handles.subtrial),ones(1,handles.subtrial)*2,ones(1,handles.subtrial)*3,ones(1,handles.subtrial)*4];
handles.order=handles.order(randperm(length(handles.order)));
handles.trapx = cell(1,length(handles.order));
handles.trapy = cell(1,length(handles.order));
handles.taskover=zeros(1,length(handles.order));
handles.trialL=handles.T*ones(1,length(handles.order));
for i = 1:length(handles.order)
    if handles.order(i) == 1 % slow 20% MVC
        tmp = 20;
        handles.trapx{i} = [0 2 5 7.5 7.5];
        handles.trapy{i} = [0 0 tmp tmp 0];
        handles.taskover(i)=handles.trapx{i}(end);
%         handles.trialL(i)= handles.taskover(i)+handles.restp(i);
        
    elseif handles.order(i) == 2 % slow 60% MVC
        tmp = 60;
        handles.trapx{i} =  [0 2 11 13.5 13.5];
        handles.trapy{i} = [0 0 tmp tmp 0];
        handles.taskover(i)=handles.trapx{i}(end);
%         handles.trialL(i)= handles.taskover(i)+handles.restp(i);
    elseif handles.order(i) == 3 % fast 20% MVC
        tmp = 20;
        handles.trapx{i} = [0 2 3 5.5 5.5];
        handles.trapy{i} = [0 0 tmp tmp 0];
        handles.taskover(i)=handles.trapx{i}(end);
%         handles.trialL(i)= handles.taskover(i)+handles.restp(i);
    elseif handles.order(i) == 4 % fast 60% MVC
        tmp = 60;
        handles.trapx{i} = [0 2 5 7.5 7.5];
        handles.trapy{i} = [0 0 tmp tmp 0];
        handles.taskover(i)=handles.trapx{i}(end);
%         handles.trialL(i)= handles.taskover(i)+handles.restp(i);
    end
end
handles.trialnum=1;
handles.trialnummax=length(handles.order);
if handles.sessionnum~=0
Info.task_time=handles.taskover;
Info.trial_length=handles.trialL;
Info.Yaxis=handles.trapy;
Info.Xaxis=handles.trapx;
Info.Exp_Seq=handles.order;
save(strcat('Trigger_Information_',num2str(handles.sessionnum),'.mat'),'Info');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if handles.val == 1 %
    handles.t = handles.trapx{1};
    handles.y = handles.trapy{1};
    handles.ITIME = 0;
%     handles.T=handles.trialL(1);
    %     elseif handles.val == 2 %step ramp
    %         TEMP = [0 handles.amp/SLOPE handles.amp/SLOPE+10 2*handles.amp/SLOPE+10];
    %         handles.t=[0 TEMP+(handles.T-max(TEMP))/2 handles.T];
    %         handles.y=[0 0 handles.amp handles.amp 0 0];
    %         handles.ITIME = 0;
    %
    %     elseif handles.val == 3
    %         TEMP = [0 handles.amp/SLOPEramp 2*handles.amp/SLOPEramp];
    %         handles.t=[0 TEMP+(handles.T-max(TEMP))/2 handles.T];
    %         handles.y=[0 0 handles.amp 0 0];
    %         handles.ITIME = 0;
    %
    %     elseif handles.val == 4
    %         handles.t=[0:0.01:30];
    %         handles.y=handles.amp/2*chirp(handles.t,0,30,1)+handles.amp;
    %         handles.t=[0 15 handles.t+15 45 handles.T];
    %         handles.y=[0 0 handles.y 0 0];
    %         handles.ITIME = 0;
    
end
set(handles.up1,'xdata', handles.t, 'ydata', handles.y,'Color','r','Linewidth',5);
set(handles.up2,'xdata', handles.t, 'ydata', handles.y,'Color','r','Linewidth',5);
yraw1=get(handles.RAW1,'YData');
yraw2=get(handles.RAW2,'YData');
set(handles.RAW1,'XData',handles.ITIME,'YData',yraw1);
set(handles.RAW2,'XData',handles.ITIME,'YData',yraw2);
fig1=get(handles.plot1,'Children');
set(fig1,'XLim',[0 (handles.T*handles.fcinput-1)/handles.fcinput],'YLim',[-0.5 80]);
axis(handles.Splot1, [0 (handles.T*handles.fcinput-1)/handles.fcinput -0.5 80]);

function Record(obj,event)
global handles;
global SerialPort;
set(handles.RecordButton,'BackgroundColor',[1 0 0]);

handles.FileCounter = handles.FileCounter + 1;
handles.StrFileCount = num2str(handles.FileCounter);
handles.filename2 = [handles.filename(1:end-4),'-',num2str(handles.sessionnum),'-',handles.StrFileCount,handles.filename(end-3:end)];
% set(handles.ai,'LogFileName',[handles.pathname,handles.filename2]);%32bit
handles.logfilename=[handles.pathname,handles.filename2];
% if handles.sessionnum~=0
handles.fid1=fopen(handles.logfilename,'w');
% end
handles.ITIME = 0;
handles.BIAS = 0;
% start([handles.ai]);%32bit
handles.ih=addlistener(handles.ai,'DataAvailable', @(src,event)AcqForce(src,event,handles.fid1));
handles.ai.startBackground();
% delete(handles.ih);
if handles.sessionnum~=0
fprintf(SerialPort, '1');
end


function StopDAQ(obj,event)
global handles;
global SerialPort;
set(handles.RecordButton,'Visible','on');
set(handles.RecordButton,'BackgroundColor',[0.941176 0.941176 0.941176]);
set(handles.MVCButton,'BackgroundColor',[0.941176 0.941176 0.941176]);
delete(handles.ih);
stop(handles.ai);
fclose(handles.fid1);%64bit
disp(handles.trialnummax)
if handles.sessionnum~=0
% fprintf(SerialPort, '1');
end







