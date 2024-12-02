function varargout = force_biometrics(varargin)
%%%%% version 1 - 20230323 %%%%%%
% the basic function for grasping force recording in Huashan Hospital
% (based on Biometrics) 
%%%%%%%%%%%% @ CC %%%%%%%%%%%%%%%
% FORCE_BIOMETRICS MATLAB code for force_biometrics.fig
%      FORCE_BIOMETRICS, by itself, creates a new FORCE_BIOMETRICS or raises the existing
%      singleton*.
%
%      H = FORCE_BIOMETRICS returns the handle to a new FORCE_BIOMETRICS or the handle to
%      the existing singleton*.
%
%      FORCE_BIOMETRICS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FORCE_BIOMETRICS.M with the given input arguments.
%
%      FORCE_BIOMETRICS('Property','Value',...) creates a new FORCE_BIOMETRICS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before force_biometrics_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to force_biometrics_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help force_biometrics

% Last Modified by GUIDE v2.5 21-Nov-2023 08:56:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @force_biometrics_OpeningFcn, ...
                   'gui_OutputFcn',  @force_biometrics_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before force_biometrics is made visible.
function force_biometrics_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to force_biometrics (see VARARGIN)

% Choose default command line output for force_biometrics
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes force_biometrics wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = force_biometrics_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_Configuration.
function pushbutton_Configuration_Callback(hObject, eventdata, handles)
% configuration for biometric
% addpath('C:\Users\Lenovo\Documents\MATLAB64'); % will need to be changed
if ~libisloaded('OnLineInterface64')  % only load if not already loaded
    [notfound,warnings]=loadlibrary('OnLineInterface64.dll', 'OnLineInterface.h');
end
% libfunctionsview('OnLineInterface64')	% Open a window to show the functions available in the library
feature('COM_SafeArraySingleDim', 1);   % only use single dimension SafeArrays
feature('COM_PassSafeArrayByRef', 1);
int32 ch;
ch = 18;
handles.ch = ch;	% will need to be changed to match the sensor channel
handles.values = libstruct('tagSAFEARRAY');
handles.fsamp = double(getSampleRate(ch));


handles.BIAS = 0;
handles.FileCounter = 0;
handles.FileCounter_mvc = 0;
handles.MVCnum=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.sessionnum = input('Which session is this experiment? (0/1), input 0 if just for test!\');
handles.comnum=3;
handles.val=0;
handles.subtrial=10;
% handles.order = [ones(1,handles.subtrial),ones(1,handles.subtrial)*2,ones(1,handles.subtrial)*3,ones(1,handles.subtrial)*4];
handles.order = [1];
handles.trialnum = 1;
handles.trialnummax = length(handles.order);

handles.RefreshRate = 0.1; % s
handles.T = 15; % s force screen time

handles.force = plot(handles.axes_force,0,0);
hold on;
handles.force_ref = plot(handles.axes_force,0,0,'linewidth',2,'Color','r');
handles.axes_force.XLim = [0,handles.T];
% set(handles.axes_force,'xlim',[0,handles.T]);
p = get(0,'monitorpositions');

set(handles.fig_sub,'visible','off');
handles.axes_sub = axes;
hold on;
handles.force_sub = plot(handles.axes_sub,0,0);
handles.force_ref_sub = plot(handles.axes_sub,0,0,'linewidth',5,'Color','r');
axis off;
guidata(hObject,handles);

% hObject    handle to pushbutton_Configuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_MVCTest.
function pushbutton_MVCTest_Callback(hObject, eventdata, handles)

set(handles.pushbutton_MVCTest,'BackgroundColor',[1,0,0]);
global para
para.flag_record = 1;

plotData = [];
numberOfValues = getData(handles.ch, getSampleRate(handles.ch), 50000, handles.values);
pause(0.05)
% numberOfValues = getData(handles.ch, handles.fsamp, 1000, handles.values)
% handles.values.pvData
handles.edit_MVCvalue.String = '-inf';
while para.flag_record
    numberOfValues = getData(handles.ch, handles.fsamp, 1000, handles.values);
    tmpData = -double(handles.values.pvData);
    mean(tmpData)
    if mean(tmpData)>str2double(handles.edit_MVCvalue.String)
        handles.edit_MVCvalue.String = num2str(round(mean(tmpData)));
    end
%     values.pvData
    plotData = [plotData,tmpData];
    set(handles.force,'xdata',[1:length(plotData)]/handles.fsamp,'ydata',plotData,'linewidth',2,'color','k');
    handles.mvcData = plotData;
    numT = ceil(length(plotData)/handles.fsamp/handles.T);
    set(handles.axes_force,'xlim',(numT-1)*handles.T+[0,handles.T],'ylim',[-3600,max(plotData)*1.2]);
    guidata(hObject,handles);
    pause(0.1);
end


% hObject    handle to pushbutton_MVCTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_MVCvalue_Callback(hObject, eventdata, handles)
% hObject    handle to edit_MVCvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_MVCvalue as text
%        str2double(get(hObject,'String')) returns contents of edit_MVCvalue as a double


% --- Executes during object creation, after setting all properties.
function edit_MVCvalue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_MVCvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_protocol.
function popupmenu_protocol_Callback(hObject, eventdata, handles)
switch handles.popupmenu_protocol.Value
    case 1
        handles.order = [ones(1,handles.subtrial),ones(1,handles.subtrial)*2,ones(1,handles.subtrial)*3,ones(1,handles.subtrial)*4];
        handles.order = handles.order(randperm(length(handles.order)));
        handles.trapx = cell(1,length(handles.order));
        handles.trapy = cell(1,length(handles.order));
        handles.taskover = zeros(1,length(handles.order));
        handles.trialL = handles.T*ones(1,length(handles.order));
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
        set(handles.force_ref,'xdata',handles.trapx{handles.trialnum},'ydata',handles.trapy{handles.trialnum});
        set(handles.axes_force,'xlim',[0,handles.T],'ylim',[-10,70],'ygrid','on'); 
        set(handles.force_ref_sub,'xdata',handles.trapx{handles.trialnum},'ydata',handles.trapy{handles.trialnum});
        set(handles.axes_sub,'xlim',[0,handles.T],'ylim',[-10,70],'ygrid','on'); 

        forceOrder = handles.order;
        forceRef{1} = handles.trapx;
        forceRef{2} = handles.trapy;
        save(['forceProtocol_' num2str(handles.FileCounter) '.mat'],"forceOrder","forceRef");
    case 2
        tmp = str2num(handles.edit_level.String);
        handles.trapx{1} = [0 5 10 20 25 30];
        handles.trapy{1} = [0 0 tmp tmp 0 0];
        set(handles.force_ref,'xdata',handles.trapx{handles.trialnum},'ydata',handles.trapy{handles.trialnum});
        set(handles.axes_force,'xlim',[0,handles.T],'ylim',[-10,tmp+10],'ygrid','on'); 
        set(handles.force_ref_sub,'xdata',handles.trapx{handles.trialnum},'ydata',handles.trapy{handles.trialnum});
        set(handles.axes_sub,'xlim',[0,handles.T],'ylim',[-10,tmp+10],'ygrid','on'); 
    case 3
        tmp = str2num(handles.edit_level.String);
        handles.trapx{1} = [0 2.5 5 15 17.5 20];
        handles.trapy{1} = [0 0 tmp tmp 0 0];
        set(handles.force_ref,'xdata',handles.trapx{handles.trialnum},'ydata',handles.trapy{handles.trialnum});
        set(handles.axes_force,'xlim',[0,handles.T],'ylim',[-10,tmp+10],'ygrid','on'); 
        set(handles.force_ref_sub,'xdata',handles.trapx{handles.trialnum},'ydata',handles.trapy{handles.trialnum});
        set(handles.axes_sub,'xlim',[0,handles.T],'ylim',[-10,tmp+10],'ygrid','on'); 
    case 4
        handles.trialnummax = 100;
        handles.trapx = cell(1,handles.trialnummax);
        handles.trapy = cell(1,handles.trialnummax);
        % tmp = str2num(handles.edit_level.String);
        % tmpind = handles.popupmenu_level.Value;
        % tmp = str2num(handles.popupmenu_level.String{tmpind});
        tmp = str2num(handles.edit_level.String);
        handles.trapx{1} = [0 handles.T];
        handles.trapy{1} = [tmp tmp];
        set(handles.force_ref,'xdata',handles.trapx{handles.trialnum},'ydata',handles.trapy{handles.trialnum});
        set(handles.axes_force,'xlim',[0,handles.T],'ylim',[-10,tmp+10],'ygrid','on'); 
        set(handles.force_ref_sub,'xdata',handles.trapx{handles.trialnum},'ydata',handles.trapy{handles.trialnum});
        set(handles.axes_sub,'xlim',[0,handles.T],'ylim',[-10,tmp+10],'ygrid','on'); 
        handles.trapx(2:end) = handles.trapx(1);
        handles.trapy(2:end) = handles.trapy(1);
end
guidata(hObject,handles);
% hObject    handle to popupmenu_protocol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_protocol contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_protocol


% --- Executes during object creation, after setting all properties.
function popupmenu_protocol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_protocol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_Start.
function pushbutton_Start_Callback(hObject, eventdata, handles)
set(handles.pushbutton_Start,'BackgroundColor',[1,0,0]);
global para
para.flag_record = 1;

handles.forceData = [];
numberOfValues = getData(handles.ch, getSampleRate(handles.ch), 50000, handles.values);
pause(0.01)
% tic;
numT = 1;
set(handles.axes_force,'xlim',(numT-1)*handles.T+[0,handles.T]);
set(handles.force_ref,'xdata',handles.trapx{numT}+(numT-1)*handles.T,'ydata',handles.trapy{numT});
if handles.pushbutton_Trigger.BackgroundColor == [0,1,0]
    write(handles.serialport,'1','char');
end
while para.flag_record
    numberOfValues = getData(handles.ch, handles.fsamp, 1000, handles.values);
    tmpData = -double(handles.values.pvData);
    handles.forceData = [handles.forceData,tmpData];
    tmpForce = (mean(tmpData)-handles.forceBias)/(handles.mvcPoint-handles.forceBias)*100;
%     values.pvData
%     set(handles.force,'xdata',length(handles.forceData)/handles.fsamp,'ydata',tmpForce,'MarkerFaceColor','k','MarkerEdgecolor','k','Marker','O','Markersize',20);
%     handles.mvcData = plotData;
    currentT = length(handles.forceData)/handles.fsamp;
    if ceil(currentT/handles.T)>numT
        numT = ceil(currentT/handles.T);
        % if handles.pushbutton_Trigger.BackgroundColor == [0,1,0]
        %     write(handles.serialport,'1','char');
        % end
        if numT>handles.trialnummax
            if handles.pushbutton_Trigger.BackgroundColor == [0,1,0]
                write(handles.serialport,'1','char');
            end                      
            forceData_raw = handles.forceData;
            forceData = (forceData_raw-handles.forceBias)/(handles.mvcPoint-handles.forceBias)*100;            
            fsamp = handles.fsamp;
            handles.FileCounter = handles.FileCounter+1;
            save(['forceData_' num2str(handles.FileCounter_mvc) '_' num2str(handles.FileCounter) '.mat'],"forceData","forceData_raw","fsamp");
            para.flag_record = 0;           
            handles.pushbutton_Start.BackgroundColor = [1,1,1];
            fprintf(['Session ' num2str(handles.FileCounter_mvc) ', force ' num2str(handles.FileCounter) ' completed!\n'])
            
            guidata(hObject,handles);
            break;
        end
        set(handles.force_ref,'xdata',handles.trapx{numT}+(numT-1)*handles.T,'ydata',handles.trapy{numT});
        set(handles.axes_force,'xlim',(numT-1)*handles.T+[0,handles.T]);
        set(handles.force_ref_sub,'xdata',handles.trapx{numT}+(numT-1)*handles.T,'ydata',handles.trapy{numT});
        set(handles.axes_sub,'xlim',(numT-1)*handles.T+[0,handles.T]);
    end
    set(handles.force,'xdata',currentT,'ydata',tmpForce,'MarkerFaceColor','k','MarkerEdgecolor','k','Marker','O','Markersize',20);
%     if rem(currentT,15)<handles.taskover(numT)+1
        set(handles.force_sub,'xdata',currentT,'ydata',tmpForce,'MarkerFaceColor','k','MarkerEdgecolor','k','Marker','O','Markersize',20);
%     else
%         set(handles.force,'xdata',currentT,'ydata',-10);
%         set(handles.force_sub,'xdata',currentT,'ydata',-20);
%     end
    guidata(hObject,handles);    
    pause(0.1);
end
% hObject    handle to pushbutton_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_Stop.
function pushbutton_Stop_Callback(hObject, eventdata, handles)
global para
para.flag_record = 0;
if handles.pushbutton_MVCTest.BackgroundColor == [1,0,0]
    mvcData = handles.mvcData;
    handles.FileCounter_mvc = handles.FileCounter_mvc+1;
    fsamp = handles.fsamp;
    save(['MVCdata_' num2str(handles.FileCounter_mvc) '.mat'],'mvcData',"fsamp");
    handles.pushbutton_MVCTest.BackgroundColor = [1,1,1];
    handles.mvcPoint = max(handles.mvcData);
    % handles.forceBias = min(handles.mvcData);  
    handles.forceBias = prctile(handles.mvcData,10);  
    handles.FileCounter = 0;
end
if handles.pushbutton_Start.BackgroundColor == [1,0,0]
    if handles.pushbutton_Trigger.BackgroundColor == [0,1,0]
        write(handles.serialport,'1','char');
    end
    forceData_raw = handles.forceData;
    fsamp = handles.fsamp;
    forceData = (forceData_raw-handles.forceBias)/(handles.mvcPoint-handles.forceBias)*100;    
    handles.FileCounter = handles.FileCounter+1;
    save(['forceData_' num2str(handles.FileCounter_mvc) '_'  num2str(handles.FileCounter) '.mat'],"forceData","forceData_raw","fsamp");
    handles.pushbutton_Start.BackgroundColor = [1,1,1];
    fprintf(['Session ' num2str(handles.FileCounter_mvc) ', force ' num2str(handles.FileCounter) ' stopped mannually!\n'])
    
end
guidata(hObject,handles);


% hObject    handle to pushbutton_Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_Trigger.
function pushbutton_Trigger_Callback(hObject, eventdata, handles)
if handles.pushbutton_Trigger.BackgroundColor == [1,1,1]
    handles.serialport = serialport(handles.edit_com.String,2000000);
    handles.pushbutton_Trigger.BackgroundColor = [0,1,0];
    fprintf('Serialport opened!\n')
else
    delete(handles.serialport);
    handles.pushbutton_Trigger.BackgroundColor = [1,1,1];
    fprintf('Serialport deleted!\n')
end
guidata(hObject,handles);

% hObject    handle to pushbutton_Trigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_com_Callback(hObject, eventdata, handles)
% hObject    handle to edit_com (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_com as text
%        str2double(get(hObject,'String')) returns contents of edit_com as a double


% --- Executes during object creation, after setting all properties.
function edit_com_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_com (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
try
    close(handles.fig_sub);
catch
end
try
    delete(handles.serialport);
catch
end
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_level_Callback(hObject, eventdata, handles)
popupmenu_protocol_Callback(hObject, eventdata, handles);
% hObject    handle to edit_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_level as text
%        str2double(get(hObject,'String')) returns contents of edit_level as a double


% --- Executes during object creation, after setting all properties.
function edit_level_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_level.
function popupmenu_level_Callback(hObject, eventdata, handles)
popupmenu_protocol_Callback(hObject, eventdata, handles);
% hObject    handle to popupmenu_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_level contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_level


% --- Executes during object creation, after setting all properties.
function popupmenu_level_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
