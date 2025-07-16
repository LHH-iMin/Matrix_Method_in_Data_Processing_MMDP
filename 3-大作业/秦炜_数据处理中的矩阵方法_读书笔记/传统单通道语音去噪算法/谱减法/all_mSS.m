%-------------------------------------------------------------------------
%  文 件 名  : mSS
%  作    者  : 秦炜
%  生成日期  : 2022年5月27日
%  功能描述  : 语音增强-多宽带谱减法的实现过程                                                    
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
    enhanced_speech = mband('sp_noisy.wav','sp_enhanced.wav',4,'linear');
%     %% 谱减法
%     noise_estimated = sp_noisy(1:0.5*fs,1);              %将前0.5秒的信号作为估计的噪声
%     fft_x = fft(sp_noisy);        %对加噪语音进行FFT
%     phase_fft_x = angle(fft_x);       %取带噪语音的相位作为最终相位
%     fft_noise_estimated = fft(noise_estimated);      %对噪声进行FFT
%     mag_signal = abs(fft_x)-sum(abs(fft_noise_estimated))/length(fft_noise_estimated);    %恢复出来的幅度
%     mag_signal(mag_signal<0) = 0;         %将小于0的部分置为0
%     %% 恢复语音信号
%     fft_s = mag_signal .* exp(1i.*phase_fft_x);
%     enhanced_speech = ifft(fft_s);
% 
%     audiowrite('sp_noisy.wav',sp_noisy,fs);       % 将混合的语音写入
%     audiowrite('sp_enhanced.wav',enhanced_speech,fs);       % 将混合的语音写入

    addpath 'D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\评价指标\PESQ_STOI\eva_composite'
    pesq1 = pesq([fileFolder2 fileNames2{ii}], 'sp_enhanced.wav');
    pesq_sum = pesq_sum + pesq1(1);
    segSnr1 = FrequencyWeightedSNRseg([fileFolder2 fileNames2{ii}],'sp_enhanced.wav');
    segSnr_sum = segSnr_sum + segSnr1;
end
pesq_avg = pesq_sum/30
segSnr_avg = segSnr_sum/30


