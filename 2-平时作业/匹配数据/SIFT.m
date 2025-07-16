% 加载图像数据
load('image_registration.mat');

% 确保图像为uint8类型
im1 = im2uint8(im1);
im2 = im2uint8(im2);

% 检测SIFT特征点
points1 = detectSIFTFeatures(im1);
points2 = detectSIFTFeatures(im2);

% 提取特征描述子
[features1, validPoints1] = extractFeatures(im1, points1);
[features2, validPoints2] = extractFeatures(im2, points2);

% 匹配特征点，调整参数以增加匹配数
indexPairs = matchFeatures(features1, features2, 'MatchThreshold', 40, 'MaxRatio', 0.6);

% 提取对应的匹配点
matchedPoints1 = validPoints1(indexPairs(:,1), :);
matchedPoints2 = validPoints2(indexPairs(:,2), :);

% 检查是否有足够的匹配点
if size(matchedPoints1, 1) < 1
    error('未找到足够的匹配点对。');
end

% 使用RANSAC估计平移变换
try
    tform = estimateGeometricTransform2D(matchedPoints1, matchedPoints2, 'translation', 'MaxDistance', 1);
    translation = tform.Translation;
catch ME
    error('估计平移失败：%s', ME.message);
end

% 输出结果
fprintf('平移量为 dx = %.2f, dy = %.2f\n', translation(1), translation(2));