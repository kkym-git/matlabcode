function data = OpenOTBfilesBatch(filePath)
% -- Created by CC -- Email: cedric_c@126.com %
% Reads files of type OTB+, extrapolating the information on the signal,
% in turn uses the xml2struct function to read file.xml and allocate them in an easily readable Matlab structure.
% Isn't possible to read OTB files because the internal structure of these
% files is different.

% clear all
% close all
% fclose all
% clc
%
% FILTERSPEC = {'*.otb+','OTB+ files'; '*.otb','OTB file'; '*.zip', 'zip file'};
% [FILENAME, PATHNAME] = uigetfile(FILTERSPEC,'titolo');
%
mkdir('tempopen');
cd('tempopen');

untar(filePath);
% unzip([PATHNAME FILENAME]);
signals=dir('*.sig');
for nSig=1:length(signals)
    PowerSupply{nSig}=5;
    abstracts{nSig}=[signals(nSig).name(1:end-4) '.xml'];
    abs = xml2struct_OT(abstracts{nSig});
    for nAtt=1:length(abs.Device.Attributes)
        %         if strcmp(abs.Device.Attributes(nAtt).Name,'SampleFrequency')
        Fsample{nSig}=str2num(abs.Device.Attributes(nAtt).SampleFrequency);
        %         end
        %         if strcmp(abs.Device.Attributes(nAtt).Name,'Name')
        %             if (strcmp(abs.Device.Attributes(nAtt).Name,'EMG-USB'))
        %                 PowerSupply{nSig}=5;
        %             end
        %         end
        %         if strcmp(abs.Device.Attributes(nAtt).DeviceTotalChannels,'DeviceTotalChannels')
        if strfind(abs.Device.Attributes(nAtt).Name,'QUATTROCENTO')
            nChannel{nSig}=str2num(abs.Device.Attributes(nAtt).DeviceTotalChannels);
        else
            nChannel{nSig}=str2num(abs.Device.Attributes(nAtt).DeviceTotalChannels);
        end
        
        %         end
        %         if strcmp(abs.Device.Attributes(nAtt).ad_bits,'ad_bits')
        nADBit{nSig}=str2num(abs.Device.Attributes(nAtt).ad_bits);
        %         end
    end
    vett=zeros(1,nChannel{nSig});
    Gains{nSig}=vett;
    for nChild=1:length(abs.Device.Channels)
        %         if strcmp(abs.Children(nChild).Name,'Channels')
        Channels=abs.Device.Channels(nChild);
        for nChild2=1:length(Channels.Adapter)
            %                 if strcmp(Channels.Children(nChild2).Name,'Adapter')
            %                     Adapter=Channels.Adapter{nChild2};
            for nAtt2=1:length(Channels.Adapter{nChild2}.Attributes)
                %                        if strcmp(Adapter.Device.Attributes(nAtt2).Name,'Gain')
                localGain{nSig}=str2num(Channels.Adapter{nChild2}.Attributes(nAtt2).Gain);
                %                        end
                %                        if strcmp(Adapter.Device.Attributes(nAtt2).Name,'ChannelStartIndex')
                startIndex{nSig}=str2num(Channels.Adapter{nChild2}.Attributes(nAtt2).ChannelStartIndex);
                %                        end
            end
            if nChild2<=3
                for nChild3=1:length(Channels.Adapter{nChild2}.Channel)
                    %                         if strcmp(Adapter.Children(nChild3).Name,'Channel')
                    %                             for nAtt3=1:length(Adapter.Channel{nChild3}.Attributes)
                    %                                 if strcmp(Adapter.Children(nChild3).Device.Attributes(nAtt3).Name,'Index')
                    try
                        idx=str2num(Channels.Adapter{nChild2}.Channel{nChild3}.Attributes.Index);
                    catch
                        idx=str2num(Channels.Adapter{nChild2}.Channel(nChild3).Attributes.Index);
                    end
                    Gains{nSig}(startIndex{nSig}+idx+1)=localGain{nSig};
                end
            else
                idx=str2num(Channels.Adapter{nChild2}.Channel.Attributes.Index);
                Gains{nSig}(startIndex{nSig}+idx+1)=localGain{nSig};
            end
        end
        %                                 end
        %                             end
    end
    
    h=fopen(signals(nSig).name,'r');
    data=fread(h,[nChannel{nSig} Inf],'short');
    fclose(h);
    Data{nSig}=data;
    %     figs{nSig}=figure;
    for nCh=1:nChannel{nSig}
        data(nCh,:)=data(nCh,:)*PowerSupply{nSig}/(2^nADBit{nSig})*1000/Gains{nSig}(nCh);
    end
    %     MyPlotNormalized(figs{nSig},[1:length(data(1,:))]/Fsample{nSig},data);
    %     MyPlot(figure,[1:length(data(1,:))]/Fsample{nSig},data,0.5);
    
end


theFiles = dir;
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fprintf(1, 'Now deleting %s\n', baseFileName);
    delete(baseFileName);
end

cd ..;
rmdir('tempopen');

end

% function []=MyPlotNormalized(fig,x,y)
%     figure(fig);
%     maximus=max(max(abs(y)));
%     for ii=1:size(y,1)
%         plot(x,y(ii,:)/2/maximus-ii);
%         hold on
%     end
%
% end
%
%
% function []=MyPlot(fig,x,y,shift)
%     figure(fig);
%     maximus=max(max(abs(y)));
%     for ii=1:size(y,1)
%         plot(x,y(ii,:)-ii*shift);
%         hold on
%     end
%
% end


