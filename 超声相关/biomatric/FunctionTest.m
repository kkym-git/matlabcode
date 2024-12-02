int32 ch;
ch = 18;	% will need to be changed to match the sensor channel
sampleRate = getSampleRate(ch);
str = ['Channel ', num2str(ch), ' has a sampling rate of ', num2str(sampleRate)];
disp(str);

samplesAvailable = getSamplesAvailable(ch);
str = ['Channel ', num2str(ch), ' has ', num2str(samplesAvailable), ' samples available.'];
disp(str);

pStatus = libpointer('int32Ptr', 0);
calllib('OnLineInterface64', 'OnLineStatus', ch, OLI.ONLINE_GETENABLE, pStatus);
enabled = pStatus.Value;
