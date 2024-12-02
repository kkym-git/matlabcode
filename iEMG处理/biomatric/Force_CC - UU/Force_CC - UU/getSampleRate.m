function sampleRate = getSampleRate(ch)
% Find channel sampling rate
% First initialise return value from OnLineGetData within DLL
pStatus = libpointer('int32Ptr', 0);
calllib('OnLineInterface64', 'OnLineStatus', ch, OLI.ONLINE_GETRATE, pStatus);
sampleRate = pStatus.Value;
