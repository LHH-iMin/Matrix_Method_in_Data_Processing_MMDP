% 加载数据
load('image_registration.mat', 'im1', 'im2');

% 转换为双精度浮点并归一化
im1 = im2double(im1);
im2 = im2double(im2);

% 获取图像尺寸
[height, width] = size(im1);

% 预计算模板平方和
template = im1;
template_sq = sum(template(:).^2);

% 初始化NSSD矩阵
nssd = inf(height, width); % 初始化为无穷大

% 遍历所有可能的位移 (dx, dy)
for dy = 0 : height-1
    for dx = 0 : width-1
        % 从im2中提取当前窗口（允许循环位移）
        window = circshift(im2, [dy, dx]);
        
        % 计算窗口平方和
        window_sq = sum(window(:).^2);
        
        % 计算SSD
        ssd = sum((template(:) - window(:)).^2);
        
        % 计算NSSD（归一化平方差）
        if template_sq == 0 || window_sq == 0
            nssd(dy+1, dx+1) = Inf;
        else
            nssd(dy+1, dx+1) = ssd / sqrt(template_sq * window_sq);
        end
    end
end

% 找到最小值位置
[~, idx] = min(nssd(:));
[best_dy, best_dx] = ind2sub([height, width], idx);

% 调整位移量到 [-100, 100] 范围
dx = best_dx - 1;
dy = best_dy - 1;
dx = dx - width * (dx > width/2);
dy = dy - height * (dy > height/2);

% 输出结果
fprintf('平移量：水平方向 %d 像素，垂直方向 %d 像素\n', dx, dy);

% 可视化NSSD矩阵
figure;
imagesc(nssd); colormap jet; colorbar;
title('NSSD响应图（最小值对应最佳匹配）');
hold on;
plot(best_dx, best_dy, 'ro', 'MarkerSize', 15, 'LineWidth', 2);
hold off;