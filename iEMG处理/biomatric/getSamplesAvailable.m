function samplesAvailable = getSamplesAvailable(ch)
% Find how many samples are available on a channel
% First initialise return value from OnLineGetData within DLL
pstatus = libpointer('int32Ptr', 0);
calllib('OnLineInterface64', 'OnLineStatus', ch, OLI.ONLINE_GETSAMPLES, pstatus);
samplesAvailable = pstatus.Value;
