%-------------------------------------------------------------------------
%  文 件 名  : logmmse
%  作    者  : 秦炜
%  生成日期  : 2022年5月22日
%  功能描述  : 对数最小均方误差算法的实现过程                                                    
%-----------------------------------------------------------------------
close all; clear; clc;
fileFolder1 = fullfile('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\noisyfile\airport_10dB\10dB\');  % 搜索目录
% fileFolder1 = fullfile('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\noisyfile\babble_10dB\10dB\');  % 搜索目录
% fileFolder1 = fullfile('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\noisyfile\car_10dB\10dB\');  % 搜索目录
% fileFolder1 = fullfile('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\noisyfile\exhibition_10dB\10dB\');  % 搜索目录
% fileFolder1 = fullfile('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\noisyfile\restaurant_10dB\10dB\');  % 搜索目录
% fileFolder1 = fullfile('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\noisyfile\station_10dB\10dB\');  % 搜索目录
% fileFolder1 = fullfile('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\noisyfile\street_0dB\0dB\');  % 搜索目录
% fileFolder1 = fullfile('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\noisyfile\train_10dB\10dB\');  % 搜索目录
dirOutput1 = dir(fullfile(fileFolder1,'*.wav'));  % 获取目录下所有 wav 格式音频文件信息
fileNames1 = {dirOutput1.name};  % 获取音频文件的名字，放入数组fileNames中
filePath1 = {dirOutput1.folder};  % 获取音频文件目录，存放入数组filePath中

fileFolder2 = fullfile('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\cleanfile\');  % 搜索目录
dirOutput2 = dir(fullfile(fileFolder2,'*.wav'));  % 获取目录下所有 wav 格式音频文件信息
fileNames2 = {dirOutput2.name};  % 获取音频文件的名字，放入数组fileNames中
filePath2 = {dirOutput2.folder};  % 获取音频文件目录，存放入数组filePath中

%-------------------------------读入带噪语音文件--------------------------
pesq_sum = 0;
segSnr_sum = 0;
for ii = 1:1:30
    [sp_noisy,fs] = audioread([fileFolder1 fileNames1{ii}]);
    audiowrite('sp_noisy.wav', sp_noisy, fs);
    [enhanced_speech] = logmmse('sp_noisy.wav','sp_enhanced.wav');

    addpath 'D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\评价指标\PESQ_STOI\eva_composite'
    pesq1 = pesq([fileFolder2 fileNames2{ii}], 'sp_enhanced.wav');
    pesq_sum = pesq_sum + pesq1(1);
    segSnr1 = FrequencyWeightedSNRseg([fileFolder2 fileNames2{ii}],'sp_enhanced.wav');
    segSnr_sum = segSnr_sum + segSnr1;
end
pesq_avg = pesq_sum/30
segSnr_avg = segSnr_sum/30