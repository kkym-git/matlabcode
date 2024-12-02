
for M=2:2
    for trial=1:10
        path_fold=['Z:\data\24-08-29iEMG-US-sEMG联合采集_程瑞佳'];
        path_semg=[path_fold '\M' num2str(M) 'L1T'  num2str(trial) '.mat'];
        load(path_semg);
        signal=data_EMG(1,:);
        fsamp=10240;
        LowFreq = 200;   % low frequency of passband
        HighFreq = 2000; % high frequency of passband
        % signalQuality = 5;  % frequency criterion

        % Bandpass filter the vector array Y, pass band LowFreq-HighFreq
        [Be,Ae] = butter(4,[LowFreq/fsamp*2 HighFreq/fsamp*2]); % EMG band pass filter

        % LowFreq = 2004;
        % HighFreq = 2006;
        % [Be,Ae] = butter(4,[LowFreq/fsamp*2 HighFreq/fsamp*2],'stop'); % EMG band pass filter

        sig=filtfilt(Be,Ae,signal);

        fo = 50; % power frequency
        q = 10;
        bw = (fo/(fsamp/2))/q;
        [Be,Ae] = iircomb(round(fsamp/fo),bw,'notch');%%%梳状滤波
        sig=filtfilt(Be,Ae,sig);
        
      
        data_EMG=sig;
        savepath=['Z:\Data\24-08-29iEMG-US-sEMG联合采集_程瑞佳\iEMG滤波\M' num2str(M) 'L1T'  num2str(trial) 'filt.mat'];
        save(savepath,"data_EMG")

    end
end