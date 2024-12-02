%批量绘制放电串图像的demo

method='CBSS';
loaddir=['E:\Result\327\13一组24一组\' method];
savedir=['E:\picture\327\' method];
for M=1:1
    for L=1:3
        for T=1:2
            loadfile=[loaddir '\KYM_M' num2str(M) 'L' num2str(L) 'T' num2str(T) '_decomposed.mat']
            load(loadfile)
            %%
            for gn=1:2
                % pic=draw_PluseTime(pulses{gn},2000,20,1);
                pic=draw_PluseTime(decomps{gn}.MUPulses,2000,1,20,1);
                titlename=['KYM-M' num2str(M) 'L' num2str(L) 'T' num2str(T) '-' num2str(gn) '-CKC'];
                figname=['D:\data\24-3-27\CKC\fig\'  'KYM_M' num2str(M) 'L' num2str(L) 'T' num2str(T) '_' num2str(gn) '_' method '.fig'];
                picture=[savedir  '\KYM_M' num2str(M) 'L' num2str(L) 'T' num2str(T) '_' num2str(gn) '_' method '.jpg'];
                title(titlename);
                % savefig(figname);%绘制
                saveas(gcf,picture);
                close all;
            end
        end
    end
end