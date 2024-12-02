function numberOfValues = getData(ch, sampleRate, numberOfValues, values)
% GETDATA Fill dataArray with the next block of data from Biometrics DataLog.
%	ch is the required channel.
%	sampleRate is the number of samples per second on the required channel.
%	numberOfValues is the maximum number of samples to get.
%	The data is returned in an array called 'values.pvData'.
%	The function returns the number of samples in this array.

% First initialise the return values from the DLL functions
pStatus = libpointer('int32Ptr', 0);
% Find how many samples are available
calllib('OnLineInterface64', 'OnLineStatus', ch, OLI.ONLINE_GETSAMPLES, pStatus);

if (pStatus.Value < 0)
    if (pStatus.Value == OLI.ONLINE_OVERRUN)
        error('The Biometrics Analysis buffer has overrun! More than 50000 samples not transferred by MATLAB so stop and re-start the recording.');
    else
        error('Is the DataLog switched on?');
    end;
end;

if (numberOfValues > pStatus.Value)
	numberOfValues = pStatus.Value;	% Never try to get more values than are available
end;

% initialise the return data array
Data = int16(1:numberOfValues);
% initialise the return value from OnLineGetData within DLL
pDataNum = libpointer('int32Ptr', 0);
% initialise structure for OnLineGetData within DLL
% ALWAYS get a fixed number of values from Datalog
% values = libstruct('tagSAFEARRAY');
values.cDims = int16(1);
values.cbElements = 2;	% 2-byte values
values.cLocks = 0;
values.rgsabound.cElements = numberOfValues;
values.rgsabound.lLbound = numberOfValues;
values.pvData = Data;

calllib('OnLineInterface64', 'OnLineGetData', ch, numberOfValues * 1000 / sampleRate, values, pDataNum);
numberOfValues = pDataNum.Value;

