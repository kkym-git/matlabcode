%要改半径r

ftt=fittype("A*exp(-(a*(x-x0)^2+2*b*(x-x0)*(y-y0)+c*(y-y0)^2))", ...
    'independent', {'x','y'}, 'dependent', {'h'}, ...
        'coefficients',{'A','x0','y0','a','b','c'});
% ftt=fittype("A*exp(-(cos(theta)^2/(2*sigma_x^2)+sin(theta)^2/(2*sigma_y^2)*(x-x0)^2+" + ...
%     "2*sin(2*theta)/(4*sigma_x^2)+sin(2*theta)^2/(4*sigma_y^2)*(x-x0)*(y-y0)+" + ...
%     "sin(theta)^2/(2*sigma_x^2)+cos(theta)^2/(2*sigma_y^2)*(y-y0)^2))", ...
%     'independent', {'x','y'}, 'dependent', {'h'}, ...
%         'coefficients',{'A','x0','y0','sigma_x','sigma_y','theta'});

d_all=[];
%计算
for level =1:1
    for trial = 1:1

    for nummu = 1:length( p2p_norm_all{level,trial})
    % for nummu = 3
h=p2p_norm_all{level,trial}{nummu};
h=reshape(h,[],1);
x=1:8; y=1:8; [x,y]=meshgrid(x,y);
x_mat=reshape(x,[],1);
y_mat=reshape(y,[],1);
[sf,gof,output]=fit([x_mat,y_mat],h,ftt,'StartPoint',[1,2,5,1,1,1])
%绘图
clf
plot(sf,[x_mat,y_mat],h)
hold on
shading interp
colormap('parula')
% 使用算法


%%通过abc计算sigma和转角theta
a=sf.a;b=sf.b;c=sf.c;
F=@(x)[-a+cos(x(1))^2/(2*x(2)^2)+sin(x(1))^2/(2*x(3)^2);
    -b-sin(2*x(1))/(4*x(2)^2)+sin(2*x(1))^2/(4*x(3)^2);
    -c+sin(x(1))^2/(2*x(2)^2)+cos(x(1))^2/(2*x(3)^2);];
x0=[0;2;2];%第一位旋转角
% options = optimoptions('fsolve','Display','iter');
[x,fval] = fsolve(F,x0);
GAUSSIAN_coef.theta=x(1);
GAUSSIAN_coef.sigma_x=x(2);
GAUSSIAN_coef.sigma_y=x(3);
GAUSSIAN_coef.A=sf.A;GAUSSIAN_coef.x0=sf.x0;GAUSSIAN_coef.y0=sf.y0;

%%使用单层容积导体模型
Q=1;%衰减强度?
r=30;%40for肱二头肌
r=r/cos(GAUSSIAN_coef.theta)^2
FWHM=2*sqrt(2*log(2))*GAUSSIAN_coef.sigma_y%sigamx还是y？ sigma_x:平行肌纤维 sigma_y:垂直
alpha=FWHM/(2*r)

d=(2*r^2*cos(alpha)-2*r^2+(log(2)/Q)^2)/(2*(r*cos(alpha)-r-log(2)/Q))
d_all(end+1)=d;
    end
end
end

%% 
figure;
boxchart(d_all)
hold on
set(gca, 'YDir', 'reverse');
title(['深度估计箱线图'])