function [soursesave,sbar,w_sourse,PT,energy_ratio,w,CoV,mad_record,outrecord]=ultrasound_conv_bss(data,R,regularization_factor_eigvals,Tol)
%data=x*y*t
if ~exist('R','var')
    R=10;
end
if ~exist('regularization_factor_eigvals','var')
    regularization_factor_eigvals=0.75;
end
if ~exist('Tol','var')
    Tol=1e-5;
end
soursesave=cell(0);
sbar=cell(0);
w_sourse=cell(0);
PT=cell(0);
energy_ratio=cell(0);
w=cell(0);
CoV=cell(0);
mad_record=cell(0);

% reshape
[pdepth, pwidth, t]=size(data);
data_reshape=reshape(data,pdepth*pwidth,t);

%z_score&extend
data_zscore=zscore(data_reshape,0,2);
[l,t]=size(data_zscore);
%extend(?)(R*length,t)

extended_data = zeros(R * l,t- R + 1);
for extension_idx = 1:R
    extended_data(extension_idx:R:end, :) = data_zscore(:, R- extension_idx+1:t - extension_idx+1);
end
% extended_data = zero(R*l,t);
% for extension_idx = 1:R
%     extended_data(extension_idx) =
% end



%subtract
extended_data_mean = mean(extended_data,2);
normalized_data = extended_data - extended_data_mean;%xbar

Rxx=cov(normalized_data');

%whittening
[U, S_vec, Vh] = svd(Rxx);
S_vec = diag(S_vec);
num_noise_evals = length(S_vec) * regularization_factor_eigvals;
eig_threshold = mean((S_vec(length(S_vec) - num_noise_evals:end)));
indices = find(S_vec > eig_threshold);
whitening_matrix = U(:, indices)*diag(1./sqrt(S_vec(indices)))*Vh(:, indices)';
z=whitening_matrix*normalized_data;%whitteneddata
%% fixed-point iteration
y=10;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% y是啥
[len,~]=size(z);
B=zeros(len);
for i =1:y
%     i
    %initialize
    %https://link.springer.com/article/10.1186/s12938-023-01076-0
    w{i}=random('Normal',0,1,[1,size(z,1)]);%向量横置
    w{i}=w{i}/norm(w{i});
    w0=zeros(size(w{i}));
    loop_num=1;
    k=1;
    fixedflag=true;
    %第一次不动点算法  G=log(cosh(x)),g=tanh(x)，g'=1-tanh^2
    %有
    while 1-  abs(dot(w{i},w0) ) > Tol
        w0=w{i};
        A=mean(1-tanh(w0*z).^2);
        w{i}=mean(z.*tanh(w0*z),2)'-A.*w0;
        w{i}=(w{i}'-B*(B')*(w{i}'))';
        w{i}=w{i}/norm(w{i});
        outrecord{i}(k)=abs( 1 + dot(w{i},w0) );
        plot(w{i});
        if loop_num>100
            fixedflag=false;
            disp('fail')
            break
        end
        
        

        loop_num=loop_num+1;
        k=k+1;
    end
    if fixedflag==false
        return
    end
    
%     disp(loop_num);
%     plot(outrecord);

    idx=1;
    cov_old=inf;
    peakflag=true;

    while true

        s{i}=w{i}*z;%%% 第二次定点算法,对得到的源再不动点算法一次 G=1/6 x^3 g=1/2 x^2 g'=x
        %[sbar{i},pt(idx,:),cov(idx)]=BlindDeconvPeakFinding(s{i});%%%%%%%%%% 有现成的？
        [l_sourse,t_sourse]=size(s{i});
        extended_sourse = zeros(R * l_sourse,t_sourse- R + 1);
        for extend_sourse_idx = 1:R
            extended_sourse(extend_sourse_idx:R:end, :) = s{i}(:, R- extend_sourse_idx+1:t_sourse - extend_sourse_idx+1);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%subtraction and whitten
        %subtract
        % extended_sourse_mean = mean(extended_sourse,2);
        % normalized_sourse = extended_sourse - extended_sourse_mean;%xbar
        % 
        % Rxx=cov(normalized_sourse');
        % 
        % %whittening
        % [U, S_vec, Vh] = svd(Rxx);
        % S_vec = diag(S_vec);
        % num_noise_evals = length(S_vec) * regularization_factor_eigvals;
        % eig_threshold = mean((S_vec(length(S_vec) - num_noise_evals:end)));
        % indices = find(S_vec > eig_threshold);
        % whitening_matrix = U(:, indices)*diag(1./sqrt(S_vec(indices)))*Vh(:, indices)';
        % extended_sourse=whitening_matrix*normalized_sourse;%whitteneddata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
        %%%%%%第二次定点算法
        j=1;
        [size_w_sourse,~]=size(extended_sourse);
        w_sourse{i,j}=randn(1,size_w_sourse);%向量横置
        w_sourse{i,j}=w_sourse{i,j}/norm(w_sourse{i,j});
        w_old=zeros(size(w_sourse{i,j}));

        second_fix_flag=true;
        while 1-abs(dot(w_sourse{i,j},w_old)) <Tol
            w_old=w_sourse{i,j};
            j=j+1;
            Abar=mean(w_old*extended_sourse);
            w_sourse{i,j}=mean(extended_sourse .* (0.5*(w_old*extended_sourse).^2),2 )' - Abar*w_old;
            w_sourse{i,j}=w_sourse{i,j}/norm(w_sourse{i,j});
            
            if j>100
                second_fix_flag=false;
                break
            end
        end
        %结束第二次的定点算法
        %% 
        
        if second_fix_flag==false
            return
        end
%         display(j)
        
        sbar{i}=w_sourse{i,j}*extended_sourse;%%%%%sbar_i
        sbar_square=sbar{i};%%%%%%%%%%%%%%%%%%%%%%%%%%%%%这样就全正
        [~,peak_indices]=findpeaks(sbar_square,'MinPeakDistance',30);%%%%%%%PT{i}  寻峰算法
        signal_peaks=sbar_square(peak_indices);
        if isempty(signal_peaks)%%%%%%%%%%%signal_peaks为空
            return
        end
        [labels,clusters]=kmeans(signal_peaks',2,'start',[mean(signal_peaks);0]);
        if clusters(1)>clusters(2)
            high_cluster_idx=1;
        else
            high_cluster_idx=2;
        end
        PT{i}=peak_indices(labels==high_cluster_idx);
        
        
        isi=diff(PT{i});
        CoV{i}=std(isi)/mean(isi);%%%cov
        %pt=plusetime
        if cov_old<CoV{i}
            CoV{i}=cov_old;
            break
        end
        w{i}=mean( z(:,PT{i}) ,2)';
%         if c==168
%             subplot(3,1,1);plot(w{i});
%             subplot(3,1,2);plot(sbar{i});
%             subplot(3,1,3);plot(sbar{i}.^2);
%             disp('1');
%         end
        if idx>=100
            peakflag=false;
            break
        end
        cov_old=CoV{i};
        idx=idx+1;
    end
    
    
    
    B(:,i)=w{i}';



    mad_record{i}=mad(isi);
     %%%%criteria?
        %         discharge variability should be low, and the energy of the signal within the expected range for MU discharge (6 - 16 Hz used for low force level
        %         contractions) should be high.
        signal_fft=fft(s{i});
        fs=2000;%%%%%%%%%%% 系统参数
        L=length(signal_fft);
        P2=abs(signal_fft/L);
        P1=P2(1,1:L/2+1);
        P1(1,2:end-1)=2*P1(1,2:end-1);
        f = fs*(0:(L/2))/L;
        % 找到6-14Hz频率范围的索引
        f_index = find(f >= 5 & f <= 20);
        % 计算6-14Hz频率范围的能量
        energy_in_range = sum(P1(f_index).^2);
        % 计算整个频谱的能量
        total_energy = sum(P1.^2);
        % 计算能量占比
        energy_ratio{i}= energy_in_range / total_energy * 100;
        mad_record{i}=mad(isi);
        if ( mad_record{i}<30)
         soursesave{i}=s{i};
        end
    
end


end







