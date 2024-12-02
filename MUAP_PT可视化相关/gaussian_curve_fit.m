% function h = gaussian_curve_fit(x1,y1,A,x0,y0,sigma_x,sigma_y,theta)
function h = gaussian_curve_fit(x,y,A,x0,y0,a,b,c)
%GAUSSIAN_CURVE_FIT 用于使用二维高斯拟合矫正grid与肌纤维对齐
%   A:最高点振幅 （x,y）：电极位置 (x0,y0):中心位置 spread（sigma_x,sigma_y）rotation angle theta

% a=cos(theta)^2/(2*sigma_x^2)+sin(theta)^2/(2*sigma_y^2);
% b=-sin(2*theta)/(4*sigma_x^2)+sin(2*theta)^2/(4*sigma_y^2);
% c=sin(theta)^2/(2*sigma_x^2)+cos(theta)^2/(2*sigma_y^2);
h=A*exp(-(a*(x-x0)^2+2*b*(x-x0)*(y-y0)+c*(y-y0)^2));
end

%%没有用成功，不知道为什么