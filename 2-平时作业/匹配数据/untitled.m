%%2025年5月17日 李厚华
clc;clear all;close all;
load('image_registration.mat', 'im1', 'im2');
im1 = double(im1);
im2 = double(im2);

% 傅里叶变换
F1 = fft2(im1);
F2 = fft2(im2);

% 计算互功率谱
cross_power = (F2 .* conj(F1)) ./ (abs(F2) .* abs(F1) + eps);
corr = fftshift(ifft2(cross_power));

% 找到互相关图的峰值位置
[~, max_idx] = max(corr(:));
[ypeak, xpeak] = ind2sub(size(corr), max_idx);

% 计算整数位移
center_y = (size(corr,1)+1)/2;
center_x = (size(corr,2)+1)/2;
dx0 = xpeak - center_x;
dy0 = ypeak - center_y;

% 处理循环边界，获取3x3邻域
rows = mod((ypeak-1:ypeak+1) -1, size(corr,1)) +1;
cols = mod((xpeak-1:xpeak+1) -1, size(corr,2)) +1;

x_slice = corr(ypeak, cols);
y_slice = corr(rows, xpeak);

% 抛物线拟合亚像素位移
% x方向
v = x_slice;
denominator = v(1) + v(3) - 2*v(2);
if denominator == 0
    delta_x = 0;
else
    delta_x = (v(1) - v(3)) / (2 * denominator);
end

% y方向
v = y_slice;
denominator = v(1) + v(3) - 2*v(2);
if denominator == 0
    delta_y = 0;
else
    delta_y = (v(1) - v(3)) / (2 * denominator);
end

% 总位移
dx = dx0 + delta_x;
dy = dy0 + delta_y;

fprintf('平移量为 dx = %.4f 像素，dy = %.4f 像素\n', dx, dy);