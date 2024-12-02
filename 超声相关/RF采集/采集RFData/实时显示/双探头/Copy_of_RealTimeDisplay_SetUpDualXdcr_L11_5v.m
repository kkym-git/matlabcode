% Notice:
%   This file is provided by Verasonics to end users as a programming
%   example for the Verasonics Vantage Research Ultrasound System.
%   Verasonics makes no claims as to the functionality or intended
%   application of this program and the user assumes all responsibility
%   for its use.
%
% File name SetUpLDualXdcr_HVMux.m: Example script to illustrate the use of
% two separate transducers imaging simultaneously on Vantage-256 system.
% For this example, an L12-3v HVMux transducer is connected to the left
% connector and an L11-5v to the right connector.  This script is a
% combination of the "L12-3vFlash" and "L11-5vFlash" example scripts, with
% both of them running in parallel but independently of each other in the
% same script.  To accomplish this, we define separate structures for
% PData, Recon, and ImageDisplay for each transducer.  The script requires
% a single Trans structure, however, defined as if it were a single 256
% element transducer using both connectors- but within that shared
% structure elements 1:192 represent the L12-3v and elements 193:320
% represent the L11-5v.  The TX and Receive .Apod arrays for each
% transducer will have zeros in the channel positions representing the
% other transducer.  Note however that since both transducers are sharing a
% single Trans structure, they must also share the same receive acquisition
% and processing sample rate as set by Trans.frequency.  For this example
% we are using 47.57 MHz, a reasonable compromise for the L12-3v and
% L11-5v. Note also that the GUI controls will generally modify settings
% for the L12-3v only, since it is indexed first in the relevant
% structures. Additional GUI control object(s) can be created to switch
% between probes.
%
% Note that the Vantage system can only support control of HVMux switches
% within one probe at a time, and for the UTA 260-D with both connectors
% selected, the HVMux probe must be at connector 1.  It is not possible to
% create a dual-probe script where both probes are using HVMux chips.
%
% Two separate TPC profiles are used, to allow independent control of the
% transmit voltage for each transducer using P1 and P2 HV sliders.
%
% Throught this script, comments starting with: % ***Dual Xdcr***
% have been inserted to illustrate the changes made for the dual-imaging
% example
%
% Last update:
% 05/06/2020 - Update to SW 4.3 format for new user UIControls and External function definitions (VTS 1691).
%   More info:(?/Example_Scripts/Vantage_Features/New UI Scheme/SetUpL11_5vFlash_NewUI)
% 6-10-2019 - Modified for use with 4.1 software, and modified to use
%   Verasonics L12-3v and L11-5v probes

clear all

% --- Commonly Changed User Parammeters -------------------------
numRFFrames = 10;           % RF Data frames %~ 采集的帧数
frameRateFactor = 5;        % Factor for converting sequenceRate to frameRate.
Fc = 7.7;                   % This is the compromise shared %~ 两个探头共同的中心频率
% frequency to be used by both  L11-5v (7.7 MHz)
% ---------------------------------------------------------------

% Specify TPC structure.
P.HV = 30;          % preset voltage %~ 默认的电压大小
TPC(1).hv = P.HV;

% Specify system parameters.
Resource.Parameters.numTransmit = 256; % ***Dual Xdcr*** number of transmit channels.
Resource.Parameters.simulateMode = 0; 
%  Resource.Parameters.simulateMode = 1 forces simulate mode, even if hardware is present.
%  Resource.Parameters.simulateMode = 2 stops sequence and processes RcvData continuously.

% ***Dual Xdcr*** We must explicitly specify a Connector array
% value of [1 2], to inform the system that both connectors will be used to
% support an overall "transducer" with 192 elements
Resource.Parameters.Connector = [1 2]; %~ 表示使用两个探头
% ***Dual Xdcr*** Also set the 'fakeScanhead' parameter, to allow this
% script to run on the HW system with no transducer actually connected and
% avoid confusion when the two distinct transducers are present.
Resource.Parameters.fakeScanhead = 1;

% Specify Trans structure array.
% ***Dual Xdcr*** First we will use computeTrans to define two separate
% Trans1 and Trans2 structures, and then we will use parameters from
% both of those to create the shared Trans structure that will actually be
% used by the script.

% ***Dual Xdcr*** Create the Trans1 structure
Trans1.name = 'L11-5v';
Trans1.units = 'wavelengths';
Trans1.frequency = Fc; % use the shared Fc value for both probes, so wavelength units will be consistent
Trans1 = computeTrans(Trans1);    % L11-5v transducer is 'known' transducer so we can use computeTrans.
% ***Dual Xdcr*** Create the Trans2 structure
Trans2.name = 'L11-5v';
Trans2.units = 'wavelengths';
Trans2.frequency = Fc; % use the shared Fc value for both probes, so wavelength units will be consistent
Trans2 = computeTrans(Trans2);

% ***Dual Xdcr*** Now use Trans1 and Trans2 to create the shared Trans structure ***
Trans.name = 'custom';      % Must be 'custom' to prevent confusion from the two unique transducer ID's that will actually be connected
Trans.units = 'wavelengths';
Trans.id = Trans1.id; % use the L12-3v id since it is at connector 1
Trans.frequency = Trans1.frequency;      % ***Dual Xdcr*** This is the shared frequency to be used by both L12-3v and L11-5v
Trans.type = 0;             % 1D straight array geometry applies to both L12-3v and L11-5v
Trans.numelements = Trans1.numelements + Trans2.numelements;    % total over both connectors
% Concatenate the two element position and CinnectorES arrays
Trans.ElementPos = [Trans1.ElementPos; Trans2.ElementPos];
Trans.ConnectorES = [Trans1.ConnectorES; (128+Trans2.ConnectorES)]; % add 128 to get channel numbers for second connector
% Use a compromise average value for lens correction
Trans.lensCorrection = Trans1.lensCorrection;
% For the following parameters just copy the L12-3v values
Trans.spacing = Trans1.spacing;
Trans.elementWidth = Trans1.elementWidth;
Trans.ElementSens = Trans1.ElementSens;
% For the following use an appropriate shared value
Trans.impedance = 50;
Trans.maxHighVoltage = 50;  % set maximum high voltage limit for pulser supply.
Trans.connType = 1;
% Trans.HVMux = Trans1.HVMux;
% Trans.HVMux.ApertureES = [Trans1.HVMux.ApertureES;repmat((129:1:256)',1,size(Trans1.HVMux.ApertureES,2))];

% Specify TPC structures ... creates two TPC profiles and two HV control sliders. %~ UI部分的滑块，调节最大电压
TPC(1).name = 'L11-5v';
TPC(1).maxHighVoltage = 50;
TPC(2).name = 'L11-5v';
TPC(2).maxHighVoltage = 50;

% Specify PData(1) structure array for L12-3v
P(1).startDepth = 0;   % Acquisition depth in wavelengths
P(1).endDepth = 200;   % This should preferrably be a multiple of 128 samples.

PData(1).PDelta = [Trans1.spacing, 0, 0.5];
PData(1).Size(1) = ceil((P(1).endDepth-P(1).startDepth)/PData(1).PDelta(3)); % startDepth, endDepth and pdelta set PData(1).Size.
PData(1).Size(2) = ceil((Trans1.numelements*Trans1.spacing)/PData(1).PDelta(1));
PData(1).Size(3) = 1;      % single image page
PData(1).Origin = [-Trans1.spacing*(Trans1.numelements-1)/2,0,P(1).startDepth]; % x,y,z of upper lft crnr.

% Specify PData(1) structure array for L11-5v
P(2).startDepth = 0;   % Acquisition depth in wavelengths
P(2).endDepth = 200;   % This should preferrably be a multiple of 128 samples.
PData(2).PDelta = [Trans2.spacing, 0, 0.5];
PData(2).Size(1) = ceil((P(2).endDepth-P(2).startDepth)/PData(2).PDelta(3)); % startDepth, endDepth and pdelta set PData(2).Size.
PData(2).Size(2) = ceil((Trans2.numelements*Trans2.spacing)/PData(2).PDelta(1));
PData(2).Size(3) = 1;      % single image page
PData(2).Origin = [-Trans2.spacing*(Trans2.numelements-1)/2,0,P(2).startDepth]; % x,y,z of upper lft crnr.

% Specify Media object.
pt1;
Media.function = 'movePoints';


na = 1; 
% Specify Resources.
Resource.RcvBuffer(1).datatype = 'int16';
Resource.RcvBuffer(1).rowsPerFrame = na*2*4000; % ***Dual Xdcr*** doubles since there will be two acquisitions per frame, one for each xdcr
Resource.RcvBuffer(1).colsPerFrame = Resource.Parameters.numTransmit; %~ 总共发射的channel数目？
Resource.RcvBuffer(1).numFrames = 10;  % e.g., 10 frames used for RF cineloop. %~ 采样帧率2frames/s。总共采集（na*numFrames）帧的数据。na帧组成一个大数据帧。numFrames表示大帧的数目。
% ***Dual Xdcr***  define the first ImageBuffer and DisplayWindow as usual, for the
% L12-3v
% Resource.InterBuffer(1).datatype = 'double';
Resource.InterBuffer(1).numFrames = 1;  % one intermediate buffer needed.
Resource.ImageBuffer(1).datatype = 'double';
Resource.ImageBuffer(1).rowsPerFrame = PData(1).Size(1); % this is for maximum depth
Resource.ImageBuffer(1).colsPerFrame = PData(1).Size(2);
Resource.ImageBuffer(1).numFrames = 5;
Resource.DisplayWindow(1).Title = 'L11-5vFlash(1)';
Resource.DisplayWindow(1).pdelta = 0.35;
ScrnSize = get(0,'ScreenSize');
DwWidth = ceil(PData(1).Size(2)*PData(1).PDelta(1)/Resource.DisplayWindow(1).pdelta);
DwHeight = ceil(PData(1).Size(1)*PData(1).PDelta(3)/Resource.DisplayWindow(1).pdelta);
Resource.DisplayWindow(1).Position = [50,(ScrnSize(4)-(DwHeight+150))/2, ...  % lower left corner position
                                      DwWidth, DwHeight];
Resource.DisplayWindow(1).ReferencePt = [PData(1).Origin(1),0,PData(1).Origin(3)];   % 2D imaging is in the X,Z plane
Resource.DisplayWindow(1).Type = 'Verasonics';
Resource.DisplayWindow(1).numFrames = 20;
Resource.DisplayWindow(1).AxesUnits = 'mm';
Resource.DisplayWindow(1).Colormap = gray(256);

% ***Dual Xdcr*** Now define a second ImageBuffer and DisplayWindow for the
% L11-5v
Resource.InterBuffer(2).numFrames = 1;
Resource.ImageBuffer(2).datatype = 'double';
Resource.ImageBuffer(2).rowsPerFrame = PData(2).Size(1); % this is for maximum depth %~？？？？？？
Resource.ImageBuffer(2).colsPerFrame = PData(2).Size(2);
Resource.ImageBuffer(2).numFrames = 5;
Resource.DisplayWindow(2).Title = 'L11-5vFlash(2)';
Resource.DisplayWindow(2).pdelta = 0.35;
DwWidth = ceil(PData(2).Size(2)*PData(2).PDelta(1)/Resource.DisplayWindow(2).pdelta);
DwHeight = ceil(PData(2).Size(1)*PData(2).PDelta(3)/Resource.DisplayWindow(2).pdelta);
Resource.DisplayWindow(2).Position = [600,200, DwWidth, DwHeight];
Resource.DisplayWindow(2).ReferencePt = [PData(2).Origin(1),0,PData(2).Origin(3)];   % 2D imaging is in the X,Z plane
Resource.DisplayWindow(2).Type = 'Verasonics';
Resource.DisplayWindow(2).numFrames = 20;
Resource.DisplayWindow(2).AxesUnits = 'mm';
Resource.DisplayWindow(2).Colormap = gray(256);


% Specify Transmit waveform structure.
% ***Dual Xdcr***
TW(1).type = 'parametric';
TW(1).Parameters = [Trans1.frequency,.67,2,1];
TW(2).type = 'parametric';
TW(2).Parameters = [Trans2.frequency,.67,2,1];

% ***Dual Xdcr*** Specify TX structure array for the L12-3v.
TX(1).waveform = 1;            % use 1st TW structure.
% TX(1).aperture = 1;
TX(1).Origin = [0.0,0.0,0.0];  % flash transmit origin at (0,0,0).
TX(1).focus = 0;
TX(1).Steer = [0.0,0.0];       % theta, alpha = 0.
TX(1).Apod = [ones(1,128), zeros(1, 128)]; % ***Dual Xdcr*** L12-3v uses channels 1:128
TX(1).Delay = computeTXDelays(TX(1));

% TX(2) = TX(1);
% TX(2).aperture = 65;
% TX(2).Delay = computeTXDelays(TX(2));

% ***Dual Xdcr*** Separate TX structure for the L11-5v
TX(2).waveform = 2;
% TX(2).aperture = TX(2).aperture;
TX(2).Origin = [0,0,0];             % set origin to 0,0,0 for flat focus.
TX(2).focus = 0;  	% set focus to negative for concave TX.Delay profile.
TX(2).Steer = [0,0];
TX(2).Apod = [zeros(1, 128), ones(1,128)]; % ***Dual Xdcr*** L11-5v uses channels 129:256
TX(2).Delay = computeTXDelays(TX(2));


% Specify TGC Waveform structure.
TGC(1).CntrlPts = [0,300,444,552,606,747,870,920];
TGC(1).rangeMax = P(1).endDepth;
TGC(1).Waveform = computeTGCWaveform(TGC(1));
TGC(2).CntrlPts = [0,300,444,552,606,747,870,920];
TGC(2).rangeMax = P(2).endDepth;
TGC(2).Waveform = computeTGCWaveform(TGC(2));

% Specify Receive structure arrays -
%   endDepth - add additional acquisition depth to account for some channels
%              having longer path lengths.
%   InputFilter - The same coefficients are used for all channels. The
%              coefficients below give a broad bandwidth bandpass filter.
% ***Dual Xdcr*** For our simultaneous dual transducer acquisition scheme,
% we define two interleaved sets of Receive structures.  Each acquisition
% frame will consist of one L12-3vFlash acquisition followed by one L11-5vFlash
% acquisition.  This same concept can be easily extended to
% multi-acquisition formats such as FlashAngles, Doppler ensembles, or ray
% line imaging.
maxAcqLength1 = ceil(sqrt(P(1).endDepth^2 + ((Trans1.numelements-1)*Trans1.spacing)^2)); %~ 最大采样点数为2304
maxAcqLength2 = ceil(sqrt(P(2).endDepth^2 + ((Trans2.numelements-1)*Trans2.spacing)^2));
wlsPer128 = 128/(4*2); % wavelengths in 128 samples for 4 samplesPerWave
Receive = repmat(struct('Apod', zeros(1,256), ...
                        'startDepth', P(1).startDepth, ...
                        'endDepth', maxAcqLength1, ...
                        'TGC', 1, ...
                        'bufnum', 1, ...
                        'framenum', 1, ...
                        'acqNum', 1, ...
                        'sampleMode', 'NS200BW', ...
                        'mode', 0, ...
                        'callMediaFunc', 0),1, na*2*Resource.RcvBuffer(1).numFrames); % ***Dual Xdcr*** two Receive sturctures per frame

% ***Dual Xdcr***  - Set event-specific and transducer-specific Receive attributes. %~ 扩充Receive结构体的数目，和总的采集帧匹配上
for i = 1:Resource.RcvBuffer(1).numFrames 
    % ***Dual Xdcr*** 
    for j = 1:na
        % L11-5v(1) Receive
        Receive(na*(2*i-2)+2*j-1).framenum = i;
        Receive(na*(2*i-2)+2*j-1).Apod = [ones(1,128), zeros(1,128)]; % L11-5v uses elements 1:128
        Receive(na*(2*i-2)+2*j-1).demodFrequency = TW(1).Parameters(1);
        Receive(na*(2*i-2)+2*j-1).acqNum = 2*j-1;

        % L11-5v(2) Receive
        Receive(na*(2*i-2)+2*j).framenum = i;
        Receive(na*(2*i-2)+2*j).Apod = [zeros(1,128), ones(1,128)]; % P4-2v uses channels 129:192
        Receive(na*(2*i-2)+2*j).startDepth = P(2).startDepth;
        Receive(na*(2*i-2)+2*j).endDepth = maxAcqLength2;
        Receive(na*(2*i-2)+2*j).TGC = 2;
        Receive(na*(2*i-2)+2*j).acqNum = 2*j; % P4-2v is second acquisition in each frame
        Receive(na*(2*i-2)+2*j).demodFrequency = TW(2).Parameters(1);
        Receive(na*(2*i-2)+2*j).callMediaFunc = 0; % only move the media points once per frame
    end
end

% % - Set event specific Receive attributes. %~ 扩充Receive结构体的数目，和总的采集帧匹配上
% for i = 1:Resource.RcvBuffer(1).numFrames
%     %Receive(na*(i-1)+1).callMediaFunc = 1;
%     for j = 1:na
%         Receive(na*(i-1)+j).framenum = i;
%         Receive(na*(i-1)+j).acqNum = j;
%     end
% end


% Specify Recon structure for L12-3v.
Recon(1) = struct('senscutoff', 0.6, ...
               'pdatanum', 1, ...
               'rcvBufFrame', -1, ...
               'ImgBufDest', [1,-1], ...
               'RINums', 1);

% Define ReconInfo structure for L12-3v.
ReconInfo = repmat(struct('mode', 'replaceIntensity', ...  % replace IQ data.
                   'txnum', 1, ...
                   'rcvnum', 1, ...
                   'regionnum', 1), 1);
               
ReconInfo(2) = ReconInfo(1);
ReconInfo(2).txnum = 2;
ReconInfo(2).rcvnum = 2;

% Specify Recon structure for L11-5v.
% Copy Recon(1) and then modify values that are different
Recon(2) = Recon(1);
Recon(2).pdatanum = 2;
Recon(2).ImgBufDest = [2,-1];
Recon(2).RINums = 2;


% Specify Process structure array for the L12-3v.
pers = 20;
Process(1).classname = 'Image';
Process(1).method = 'imageDisplay';
Process(1).Parameters = {'imgbufnum',1,...   % number of buffer to process.
                         'framenum',-1,...   % (-1 => lastFrame)
                         'pdatanum',1,...    % number of PData structure to use
                         'pgain',1.0,...            % pgain is image processing gain
                         'reject',2,...      % reject level
                         'persistMethod','simple',...
                         'persistLevel',pers,...
                         'interpMethod','4pt',...
                         'grainRemoval','none',...
                         'processMethod','none',...
                         'averageMethod','none',...
                         'compressMethod','power',...
                         'compressFactor',40,...
                         'mappingMethod','full',...
                         'display',1,...      % display image after processing
                         'displayWindow',1};

% Specify separate Process structure array for the P6-3.
Process(2).classname = 'Image';
Process(2).method = 'imageDisplay';
Process(2).Parameters = {'imgbufnum',2,...   % number of buffer to process.
                         'framenum',-1,...   % (-1 => lastFrame)
                         'pdatanum',2,...    % number of PData structure to use
                         'pgain',1.0,...            % pgain is image processing gain
                         'reject',2,...      % reject level
                         'persistMethod','simple',...
                         'persistLevel',pers,...
                         'interpMethod','4pt',...
                         'grainRemoval','none',...
                         'processMethod','none',...
                         'averageMethod','none',...
                         'compressMethod','power',...
                         'compressFactor',40,...
                         'mappingMethod','full',...
                         'display',1,...      % display image after processing
                         'displayWindow',2};
                     
Process(3).classname = 'External';
Process(3).method = 'AutoQuit';
Process(3).Parameters = {};

% Specify SeqControl structure arrays.

% at the end, jump back and start over
SeqControl(1).command = 'jump';
SeqControl(1).argument = 1; % don't need to repeat the first to events that made initial TPC profile selection

% Set the frame interval using timeToNextAcq
SeqControl(2).command = 'timeToNextAcq';
SeqControl(2).argument = 500;  % 10000usec = 10msec (~ 100 fps)

% return to matlab for GUI updates every fifth frame
SeqControl(3).command = 'returnToMatlab';

SeqControl(4).command = 'triggerOut';

% % select TPC profile 2 for the L11-5v
% SeqControl(4).command = 'setTPCProfile';
% SeqControl(4).argument = 2;
% SeqControl(4).condition = 'next';
% 
% % select TPC profile 1 for the L12-3v
% SeqControl(5).command = 'setTPCProfile';
% SeqControl(5).argument = 1;
% SeqControl(5).condition = 'next';

nsc = 5; % nsc is index of next SeqControl object to be defined

% Specify the Event sequence
n = 1; % n is count of Events

Event(n).info = 'select TPC profile 1 at startup';
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = nsc; % set TPC profile command.
n = n+1;
   SeqControl(nsc).command = 'setTPCProfile';
   SeqControl(nsc).argument = 1;
   SeqControl(nsc).condition = 'immediate';
   nsc = nsc + 1;

Event(n).info = 'noop delay for initial profile selection';
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = nsc; % noop to allow time for TPC profile transition.
n = n+1;
   SeqControl(nsc).command = 'noop';
   SeqControl(nsc).argument = 100e3/.2; % 100 msec delay
   nsc = nsc + 1;

% ~ 发射Trigger，短时间内发射100次Trigger，才能被外部设备采集到脉冲。Trigger本身脉冲宽度为1us。
% for i = 1:100
%     Event(n).info = 'Trigger';
%     Event(n).tx = 1;
%     Event(n).rcv = 0;
%     Event(n).recon = 0;
%     Event(n).process = 0;
%     Event(n).seqControl = 4;
%     n = n+1;
% end

% Acquire all frames defined in RcvBuffer
for i = 1:Resource.RcvBuffer(1).numFrames
    
    for j = 1:na
        Event(n).info = 'acquisition for L11-5v';
        Event(n).tx = 1;         % use 1st TX structure.
        Event(n).rcv = 2*i-1;    % use 1st of the ith pair of Rcv structures.
        Event(n).recon = 0;      % no reconstruction.
        Event(n).process = 0;    % no processing
        Event(n).seqControl = 2; % time to next acq for frame rate
        n = n+1;

        Event(n).info = 'acquisition for L11-5v';
        Event(n).tx = 2;         % use 1st TX structure.
        Event(n).rcv = 2*i;      % use 2nd of the ith pair of Rcv structures.
        Event(n).recon = 0;      % no reconstruction.
        Event(n).process = 0;    % no processing
        Event(n).seqControl = 2; % use SeqControl struct defined below.
        n = n+1;
    end
    Event(n-1).seqControl = [2,nsc];
            SeqControl(nsc).command = 'transferToHost';
            nsc = nsc + 1;

    Event(n).info = 'Reconstruct & display L11-5v';
    Event(n).tx = 0;         % no transmit
    Event(n).rcv = 0;        % no rcv
    Event(n).recon = 1;      % separate reconstruction for each transducer
    Event(n).process = 1;    % separate image display processing for each transducer
    Event(n).seqControl = 0;
    n = n+1;

    Event(n).info = 'Reconstruct & display L11-5v';
    Event(n).tx = 0;         % no transmit
    Event(n).rcv = 0;        % no rcv
    Event(n).recon = 2;      % separate reconstruction for each transducer
    Event(n).process = 2;    % separate image display processing for each transducer
    Event(n).seqControl = 0;
    n = n+1;
end

%~ 发射Trigger
% for i = 1:100
%     Event(n).info = 'Trigger';
%     Event(n).tx = 1;
%     Event(n).rcv = 0;
%     Event(n).recon = 0;
%     Event(n).process = 0;
%     Event(n).seqControl = 4;
%     n = n+1;
% end

% Event(n).info = 'AutoQuit';
% Event(n).tx = 0;
% Event(n).rcv = 0;
% Event(n).recon = 0;
% Event(n).process = 3;
% Event(n).seqControl = 0;
% n = n+1;

Event(n).info = 'Jump back to third event to repeat the sequence';
Event(n).tx = 0;        % no TX
Event(n).rcv = 0;       % no Rcv
Event(n).recon = 0;     % no Recon
Event(n).process = 0;
Event(n).seqControl = 1; % jump command


%~ 调用外部函数
EF(1).Function = vsv.seq.function.ExFunctionDef('AutoQuit',@AutoQuit);

% Save all the structures to a .mat file.
save('MatFiles/Copy_of_RealTimeDisplay_DualXdcr_L11_5v');
return


%% Automatic VSX Execution:
% Uncomment the following line to automatically run VSX every time you run
% this SetUp script (note that if VSX finds the variable 'filename' in the
% Matlab workspace, it will load and run that file instead of prompting the
% user for the file to be used):

% filename = 'DualXdcr_HVMux';  VSX;

function AutoQuit(varargin)
% AutoQuit emulates closing the VSX control window to quit VSX
%
%   AutoQuit uses Matlab's 'findobj' to find the handle for the VSX control GUI window
%   and then closes that figure programmatically.
%
%  USAGE:  Simply invoke AutoQuit in an external function when it is not practical to manually close the control panel.

    hfig = findobj('Name','VSX Control');
    close(hfig)

    % NOTE: the following works to quit VSX, but leaves the GUI window open.
    % evalin ('base', 'vsExit=1;')
end