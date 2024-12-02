function muap_recon = muap_pca(muap,precentage)
%muap_pca 用pca对muap降噪
%   input:
% muap:cell 输入的muap
% precentage:0-1的数字 pca需要的特征值占总特征值和的占比,一般0.95
%   output：
% muap_recon:cell 输出muap
k=1;
[i_end,j_end]=size(muap);
empty_loc=zeros(i_end,j_end);
%将MUAP从cell格式化为矩阵个，记录其中空的部分（对于5*13，有一个空位）
for i=1:1:i_end
    for j=1:1:j_end
        if isempty(muap{i,j})
            empty_loc(i,j)=1;
            continue
        end
        matrix_muap(k,:)=muap{i,j};
        k=k+1;
    end
end
%对矩阵进行PCA（减去均值，计算协方差矩阵，对角化）
matrix_zeromean=matrix_muap-mean(matrix_muap,2);
sigma=cov(matrix_zeromean);
[u,s,v]=svd(sigma);
eigenvalue=diag(s);
% [coeff, score, latent, ~, explained] = pca(matrix_muap);


%只取百分比前precentage的特征值
for vec_idx=1:length(eigenvalue)
   if (sum(eigenvalue(1:vec_idx))/sum(eigenvalue)>=precentage)
       break
   end
end

%协方差矩阵是对称的，所以用u与用v并无区别
eigenvectors=u(:,1:vec_idx);%文章中是取前四
matrix_recon=matrix_zeromean*eigenvectors*eigenvectors'+mean(matrix_muap,2);
figure;k=1;
for i=1:1:i_end
    for j=1:1:j_end
        if empty_loc(i,j)==1;
            continue
        end
        muap_recon{i,j}=matrix_recon(k,:);
        k=k+1;
    end
end
end  