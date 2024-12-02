% Load the library with the alias glovelib
[result, warnings] = loadlibrary('fglove64', 'fglove.h', 'alias', 'glovelib');

% Open the glove on device usb0 (this can be replaced with a com port eg. COM1)
glovePointer = calllib('glovelib', 'fdOpen', 'usb0');
% Check the number of sensors
numSensors = calllib('glovelib', 'fdGetNumSensors', glovePointer);
%% 
% libpointer
% for sensor = 1:18
% % Get the value of the first sensor
% sensorValue(sensor) = calllib('glovelib', 'fdGetSensorScaled', glovePointer, sensor-1);%从0到13
% 
% end
% pc=zeros(18,1);
% addr
% pd=uint16(pc);
% % pv = libpointer('uint16',pd);
% 
% calllib('glovelib', 'fdGetSensorScaled', glovePointer, addr(pd));
% 
% aa=calllib('glovelib', 'fdGetGesture', glovePointer);
