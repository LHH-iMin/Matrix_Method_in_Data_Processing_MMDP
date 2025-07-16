%%2025年5月17日 李厚华
clc;clear all;close all;
% 加载图像数据
load('image_registration.mat');

% 转换为双精度并应用汉明窗减少边缘效应
im1 = im2double(im1);
im2 = im2double(im2);
window = hamming(201) * hamming(201)';
im1 = im1 .* window;
im2 = im2 .* window;

% 计算傅里叶变换
F1 = fft2(im1);
F2 = fft2(im2);

% 计算互功率谱并归一化
cross_power = (F2 .* conj(F1)) ./ (abs(F1 .* F2) + eps); % 正确顺序

% 逆傅里叶变换得到相关图，并取实部
c = real(ifft2(cross_power));

% 找到最大峰值的位置
[~, idx] = max(c(:));
[row, col] = ind2sub(size(c), idx);

% 计算初始位移量
dx = col - 1;
dy = row - 1;

% 调整位移量到[-100, 100]范围
dx = dx - 201 * (dx > 100);
dy = dy - 201 * (dy > 100);

% 输出结果
fprintf('平移量为：x方向 %d 像素，y方向 %d 像素\n', dx, dy);



% 显示im1的傅里叶变换
subplot(2,2,1);
imshow(log(1 + abs(fftshift(F1))), []);
title('im1幅度谱 (对数缩放)');
colorbar;

subplot(2,2,3);
imshow(angle(fftshift(F1)), [-pi pi]);
title('im1相位谱');
colorbar;

% 显示im2的傅里叶变换
subplot(2,2,2);
imshow(log(1 + abs(fftshift(F2))), []);
title('im2幅度谱 (对数缩放)');
colorbar;

subplot(2,2,4);
imshow(angle(fftshift(F2)), [-pi pi]);
title('im2相位谱');
colorbar;


figure
% 显示互功率谱
subplot(1,2,1);
imshow(abs(fftshift(cross_power)), []);
title('互功率谱幅度');
colorbar;

subplot(1,2,2);
imshow(angle(fftshift(cross_power)), [-pi pi]);
title('互功率谱相位');
colorbar;


% --------------------------
% 子图3：相关图可视化（空域）
% --------------------------
figure
subplot(1,2,1);
c_shifted = fftshift(c);  % 将零频移到中心
imagesc(c_shifted); 
axis image; colormap jet; colorbar;
title('逆傅里叶变换相关图');
xlabel('x'); ylabel('y');
hold on;
plot(101 + dx, 101 + dy, 'ro', 'MarkerSize', 15, 'LineWidth', 2);  % 标记峰值
hold off;

% --------------------------
% 子图4：相关图三维可视化（突出峰值）
% --------------------------
subplot(1,2,2);
[X, Y] = meshgrid(1:201, 1:201);
surf(X, Y, c_shifted, 'EdgeColor', 'none');
view(-30, 60); axis tight;
title('相关图三维视图');
xlabel('x'); ylabel('y'); zlabel('相关性强度');
hold on;
plot3(101 + dx, 101 + dy, max(c(:)), 'ro', 'MarkerSize', 15, 'LineWidth', 2);
hold off;
