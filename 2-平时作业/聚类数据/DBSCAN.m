clear all;clc;
% 加载数据
load('galaxy.mat');

% 设置 DBSCAN 参数
epsilon = 1.5;      % 邻域半径（可调）
minPts = 10;        % 最小簇内点数（可调）

% 执行 DBSCAN 聚类
labels = dbscan(data, epsilon, minPts);

% 可视化聚类结果
gscatter(data(:,1), data(:,2), labels);
title('DBSCAN 聚类结果');
xlabel('X');
ylabel('Y');
