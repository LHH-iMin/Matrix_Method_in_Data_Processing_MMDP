clear all;clc;
% 加载数据
load('galaxy.mat');

%% ========== DBSCAN 聚类 ==========
% 定义参数
epsilon = 5;   % 邻域半径
minPts = 10;      % 最小邻域点数

% 调用DBSCAN函数（需确保已安装Statistics and Machine Learning Toolbox）
labels_dbscan = dbscan(data, epsilon, minPts);
% DBSCAN结果
figure
gscatter(data(:,1), data(:,2), labels_dbscan, [], 'o', 5);
title('DBSCAN 聚类');
xlabel('X'); ylabel('Y');

%% ========== K-Means 聚类 ==========
num_clusters = 31; % 预设簇数量
[labels_kmeans, centroids] = kmeans(data, num_clusters);

% K-Means结果
figure
gscatter(data(:,1), data(:,2), labels_kmeans, [], 'o', 5);
title('K-Means 聚类');
xlabel('X'); ylabel('Y');



