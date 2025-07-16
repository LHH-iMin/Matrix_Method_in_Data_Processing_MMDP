%%2025年5月17日 李厚华
clc;clear all;close all;
% 加载数据
load('image_registration.mat');
im1 = im2double(im1);
im2 = im2double(im2);

% --- 时域归一化互相关 (NCC) ---
% 计算归一化互相关矩阵
ncc = normxcorr2(im1, im2); % MATLAB内置函数

% 找到NCC矩阵的峰值位置
[~, idx] = max(ncc(:));
[row, col] = ind2sub(size(ncc), idx);

% 计算平移量（注意NCC矩阵的尺寸）
dx = -(col - size(im1, 2));  % 符号取反
dy = -(row - size(im1, 1));

% 输出结果
fprintf('平移量为：x方向 %d 像素，y方向 %d 像素\n', dx, dy);


% 原始图像展示设置
im3=ones(201,201);
im4=ones(201,1);
im4=[im1 im4 im2;ones(1,403);im2 im4 im3];
figure;

% 显示im1的傅里叶变换
imshow(im4);
% 可视化设置
figure;
% --- 可视化 ---
figure;

% 显示NCC矩阵
subplot(1,2,1);
imagesc(ncc);
axis image;
colormap jet;
colorbar;
title('归一化互相关矩阵 (NCC)');
xlabel('x 平移'); ylabel('y 平移');

% 标记峰值
hold on;
plot(col, row, 'ko', 'MarkerSize', 15, 'LineWidth', 2);
hold off;

% 显示对齐后的图像
subplot(1,2,2);
im2_aligned = imtranslate(im2, [-dx, -dy]); % 平移回对齐位置
imshowpair(im1, im2_aligned, 'falsecolor');
title('对齐后图像对比');