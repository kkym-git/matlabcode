% 用于按Motion批量得到muap的CoG位置
% by KYM 24/11/28
% 使用所有的MUAP参与CoG计算！(MUAP比较深的时候pp值差距较小)
%
% 输入：muaparray_cell,size_x,size_y(MUAP的排布)
% 主要输出：
% CoG图,cogall,p2p_norm_all

cogall={};
num_level=size(muaparray_cell,1);
num_trial=size(muaparray_cell,2);
size_x=8;
size_y=8;

for level=1:num_level
    for trial=1:num_trial
        k=1;
        % for num=1:length(muaparray)
        for num=1:length(muaparray_cell{level,trial})

            muap=muaparray_cell{level,trial}{num};
            % muap_recon=muap_pca(muap,1);

            muap_cog=muap;
            %%%%若有电极有问题，进行插值
            % muap_cog{1,1}=(muap_cog{2,1}+muap_cog{2,2}+muap_cog{1,2})/3;
            % muap_cog{3,3}=(muap_cog{2,2}+muap_cog{3,2}+muap_cog{4,2}+muap_cog{2,3}+muap_cog{2,4}+muap_cog{3,4}+muap_cog{4,4})/8;
            % muap_cog{5,2}=(muap_cog{5,1}+muap_cog{4,2}+muap_cog{5,3}+muap_cog{4,1}+muap_cog{4,3}+muap_cog{6,1}+muap_cog{6,3})/7;
            % muap_cog{6,2}=(muap_cog{6,1}+muap_cog{5,1}+muap_cog{7,1}+muap_cog{7,2}+muap_cog{5,3}+muap_cog{6,3}+muap_cog{7,3})/7;

            % muap_cog{10,3}=(muap_cog{9,2}+muap_cog{10,2}+muap_cog{11,2}+muap_cog{9,4}+muap_cog{10,4}+muap_cog{11,4}+muap_cog{9,3}+muap_cog{11,3})/8;

            % muap_cog{13,1}=(muap_cog{13,2}+muap_cog{12,2}+muap_cog{12,1})/3;
            % muap_cog=muap_interpolation(muap_cog,[7,3]);
            % muap_cog=muap_interpolation(muap_cog,[8,2]);
            [iend,jend]=size(muap_recon);
           
            for i=1:1:iend
                for j=1:1:jend
                    if iend==5 || jend==5
                        if i+j==2%%%%%%%%%%%%%%%%%%%%%for5*13
                            tmpmuap=(muap_cog{2,1}+muap_cog{2,2}+muap_cog{1,2})/3;
                        else
                            tmpmuap=muap_cog{i,j};
                        end
                    else
                        tmpmuap=muap_cog{i,j};
                    end
                    p2p(i,j)=max(tmpmuap)-min(tmpmuap);
                end
            end
            % p2p=normalize(p2p(2:13,:));
            max_peak=max(max(p2p));
            min_peak=min(min(p2p));
            for i=1:1:iend
                for j=1:1:jend
                    p2p_norm(i,j)=(p2p(i,j)-min_peak)/(max_peak-min_peak);
                end
            end
            p2p_norm_all{level,trial}{num}=p2p_norm;
            %CoG from Xia
            % for i=1:1:iend
            %     for j=1:1:jend
            %         if p2p_norm(i,j)>0.8
            %             p2p_cog(i,j)=p2p_norm(i,j);%cog不用0.8以下的值
            %         else
            %             p2p_cog(i,j)=0;
            %         end
            %     end
            % end
            p2p_cog=p2p_norm;
            % p2p_cog(7,3)=0;
            P=sum(sum(p2p_cog));
            cogx=0;
            cogy=0;
            for i=1:1:iend
                for j=1:1:jend
                    cogx=cogx+p2p_cog(i,j)*j;
                    cogy=cogy+p2p_cog(i,j)*i;
                end
            end
            cogx=cogx/P;
            cogy=cogy/P;
            cogall{level,trial}(k,:)=[cogx,cogy];
            k=k+1;
        end
    end
end
cogmat=[];
for l=1:num_level
for t=1:num_trial%%%%%%%%%%%%%%%%%%%%%%%%%%trial数

    cogmat=[cogmat;cogall{l,t}];
end
end
figure;
scatter(cogmat(:,1),cogmat(:,2));hold on
xlim([1,size_y]);ylim([1,size_x]);

% % 循环遍历每个数据点，并添加序号
% for i = 1:size(cogmat,1)
%     text(cogmat(i,1),cogmat(i,2), num2str(i), 'FontSize', 10); % 在每个点旁边添加序号
% end

set(gca, 'YDir', 'reverse');
grid on
title('M2 iPT2muAP CoGall')