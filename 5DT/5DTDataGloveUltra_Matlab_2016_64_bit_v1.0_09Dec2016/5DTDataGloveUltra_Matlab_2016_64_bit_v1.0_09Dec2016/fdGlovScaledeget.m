%用于采集四个手指的弯曲程度

clearvars data
for i = 1:10000

    for sensor = [5,8,11,14]
        % Get the value of the first sensor
        sensorValue(sensor) = calllib('glovelib', 'fdGetSensorScaled', glovePointer, sensor-1);%从0到13
        sensorRaw(sensor) = calllib('glovelib', 'fdGetSensorRaw', glovePointer, sensor-1);%从0到13
    end
    data.datascaled(i,:)=sensorValue;
    data.dataraw(i,:)=sensorRaw;
    
    %在线可视化
    bar(sensorValue);
    ylim([0,1]);

    pause(0.1);%采样率
end

