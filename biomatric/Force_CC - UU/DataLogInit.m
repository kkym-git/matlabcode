% Load DataLog interface library
% If already loaded, unload first: unloadlibrary OnLineInterface;
%unloadlibrary OnLineInterface64;
addpath('C:\Users\kjs52\Documents\MATLAB'); % will need to be changed
clear;  % just in case library has outstanding objects.
if ~libisloaded('OnLineInterface64')  % only load if not already loaded
    [notfound,warnings]=loadlibrary('OnLineInterface64.dll', 'OnLineInterface.h');
end
libfunctionsview('OnLineInterface64')	% Open a window to show the functions available in the library
feature('COM_SafeArraySingleDim', 1);   % only use single dimension SafeArrays
feature('COM_PassSafeArrayByRef', 1);
