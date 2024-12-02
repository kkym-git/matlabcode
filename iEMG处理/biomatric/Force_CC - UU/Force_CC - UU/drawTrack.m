%para:[rest ascent flat descent]
%para:[rest Hz] for sine wave
%[d,e]=drawTrack(0,15%*MVC,[5 15%/5% 10 15%/5%],1)
%
function [datatoplot,endtime] = drawTrack(starttime,force,para,p)
if nargin<4
    p=1;
end
%para=[5,5,10,5];
fs=1000;
datatoplot=[];

if length(para)==4
    rest=para(1);
    asc=para(2);
    flat=para(3);
    desc=para(4);
    datatoplot=[starttime*fs 0;...
        (starttime+rest)*fs 0;...
        (starttime+rest+asc)*fs force;...
        (starttime+rest+asc+flat)*fs force;...
        (starttime+rest+asc+flat+desc)*fs 0];
    endtime=starttime+rest+asc+flat+desc;
else
    rest=para(1);
    sinfs=para(2); %sinfs>=1;
    t=(starttime+rest)*fs:(starttime+rest+1/(2*sinfs))*fs;

    datatoplot(:,1)=[starttime*fs;(starttime+rest)*fs;t'];
    datatoplot(:,2)=[0;0;(force*sin(2*pi*sinfs*t/fs))'];
    endtime=starttime+rest+1/(2*sinfs);
end

if p
    plot(datatoplot(:,1),datatoplot(:,2),'Color','k','LineWidth',2);
end


end