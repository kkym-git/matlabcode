%% initialization
clear;
close all;
% Load DataLog interface library
% If already loaded, unload first: unloadlibrary OnLineInterface;
%unloadlibrary OnLineInterface64;
% addpath('C:\Users\BBL-EMG\Documents\MATLAB64'); % will need to be changed
clear;  % just in case library has outstanding objects.
if ~libisloaded('OnLineInterface64')  % only load if not already loaded
    [notfound,warnings]=loadlibrary('OnLineInterface64.dll', 'OnLineInterface.h');
end
libfunctionsview('OnLineInterface64')	% Open a window to show the functions available in the library
feature('COM_SafeArraySingleDim', 1);   % only use single dimension SafeArrays
feature('COM_PassSafeArrayByRef', 1);

%% recording

int32 ch;
ch = 18;	% will need to be changed to match the sensor channel
values = libstruct('tagSAFEARRAY');

fsamp = getSampleRate(ch);
winN = fsamp*0.1;

h = figure('color',[1,1,1]);
winData = zeros(1,2*fsamp);
numberOfValues = getData(ch, getSampleRate(ch), 50000, values);

pause(1)
for i = 1:10000
    numberOfValues = getData(ch, fsamp, winN, values);
%     values.pvData
    winData = [winData(numberOfValues+1:end),abs(double(values.pvData)+2540)];
    plot(winData);
    pause(0.01);
end

% if (numberOfValues > 0)
%     plot(values.pvData);
% else
%     str = ['getData returned ', num2str(numberOfValues),' from channel ', num2str(ch)];
%     disp(str);
% end

%% 
% clear;
% close all;
% 
% data = OpenOTBfilesBatch('test.otb+');
% 
% trigger = data(65,:);
% figure;plotsig_cc(trigger,2000);
% 
% triggerInd = find(trigger<500);
% triggerInd(find(diff(triggerInd)==1)+1) = [];
% diff(triggerInd)/2000

