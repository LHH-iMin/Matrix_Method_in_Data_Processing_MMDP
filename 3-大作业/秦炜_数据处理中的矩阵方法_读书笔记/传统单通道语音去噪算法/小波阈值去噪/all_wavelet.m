%-------------------------------------------------------------------------
%  文 件 名  : wavelet
%  作    者  : 秦炜
%  生成日期  : 2022年5月25日
%  功能描述  : 语音增强-小波算法的实现过程                                                    
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

    sp_noisy = sp_noisy';
    [c,l] = wavedec(sp_noisy,5,'sym8');
    a5 = appcoef(c,l,'sym8',5);
    d5 = detcoef(c,l,5);
    d4 = detcoef(c,l,4);
    d3 = detcoef(c,l,3);
    d2 = detcoef(c,l,2);
    d1 = detcoef(c,l,1);
    sigma = wnoisest(c,l,1);
    thr = wbmpen(c,l,sigma,2);

    %利用改进阈值函数进行去噪处理
    gd1 = chuliyuzhi(d1,thr);
    gd2 = chuliyuzhi(d2,thr);
    gd3 = chuliyuzhi(d3,thr);
    gd4 = chuliyuzhi(d4,thr);
    gd5 = chuliyuzhi(d5,thr);
    c1 = [a5 gd5 gd4 gd3 gd2 gd1];
    enhanced_speech = waverec(c1,l,'sym8');  % 多尺度重构

    audiowrite('sp_enhanced.wav',enhanced_speech,8000)

    addpath 'D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\评价指标\PESQ_STOI\eva_composite'
    pesq1 = pesq([fileFolder2 fileNames2{ii}], 'sp_enhanced.wav');
    pesq_sum = pesq_sum + pesq1(1);
    segSnr1 = FrequencyWeightedSNRseg([fileFolder2 fileNames2{ii}],'sp_enhanced.wav');
    segSnr_sum = segSnr_sum + segSnr1;
end
pesq_avg = pesq_sum/30
segSnr_avg = segSnr_sum/30