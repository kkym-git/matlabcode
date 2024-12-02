int32 ch;
ch = 18;	% will need to be changed to match the sensor channel
values = libstruct('tagSAFEARRAY');
numberOfValues = getData(ch, 2000, 4000, values);
if (numberOfValues > 0)
    plot(values.pvData);
else
    str = ['getData returned ', num2str(numberOfValues),' from channel ', num2str(ch)];
    disp(str);
end
