M=1;L=2;T=1;gn=1;
pic=draw_PluseTime(pulses{1},2000,20,1);
titlename=['KYM-M' num2str(M) 'L' num2str(L) 'T' num2str(T) 'gn' num2str(gn) '-CBSS'];
picture=[titlename '.jpg'];
 title(titlename);
 saveas(gcf,picture);