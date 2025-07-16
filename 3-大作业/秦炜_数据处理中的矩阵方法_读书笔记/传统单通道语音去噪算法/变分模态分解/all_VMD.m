%-------------------------------------------------------------------------
%  文 件 名  : subspace
%  作    者  : 秦炜
%  生成日期  : 2022年5月27日
%  功能描述  : 语音增强-VMD算法的实现过程                                                    
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
    
    % some sample parameters for VMD
    alpha = 1000;       % moderate bandwidth constraint
    tau = 0;            % noise-tolerance (no strict fidelity enforcement)
    DC = 0;             % no DC part imposed
    init = 1;           % initialize omegas uniformly
    tol = 1e-7;

    %--------------- Run actual VMD code
    N = 8192; 
    frameSize = 512;  % 帧长
    inc = 0.5*frameSize;  % 帧间距
    wlen = 512;
    win = hamming(wlen);
    S = enframe(sp_noisy,win,inc);  % 分帧,对x进行分帧
    [a, b] = size(S);
    enhanced_speech = zeros(a,b);
    for r = 1:a
        data = S(r,:);
        wname = 'db6';
        for w = 3:7
            [C,L] = wavedec(data,w,wname);
            %对含噪声源进行离散小波分解，并提取高低频系数
            a = appcoef(C,L,wname,w);
            d = detcoef(C,L,w);
            clear corr
            if corr(a',d','type','Spearman')>1/2/w
                K = 2*(w-1);
                break;
            end
            K = 2*w;
        end
        [modes, u_hat, omega] = VMD(data, alpha, tau, K, DC, init, tol);
        [a,b] = size(modes);
        corr = zeros(1,a);
        x_res = zeros(1,frameSize);
        for i = 1:a
            corr1 = corrcoef(data,modes(i,:));
            corr(i) = corr1(1,2);
        end
        for i = 1:a
            if corr(i)>max(corr)/(10*max(corr)-3.3)
                x_res = x_res + modes(i,:);
            else
                [xc] = wavelet_hard(modes(i,:),3,'db6');
         
%               [thr,sort,keepapp,crit] = ddencmp('den','wp',modes(i,:));  % 小波包分解
%               xc = wpdencmp(modes(i,:),sort,3,'db6',crit,thr,keepapp);
                x_res = x_res + xc;  % 重构

%               [thrv,sortv,keepappv] = ddencmp('den','wv',modes(i,:));
%               xd = wdencmp('gbl',modes(i,:),'db6',10,thrv,sortv,keepappv);
%               x_res = x_res + xd;
            end
        end
%     x_res = x_res/max(abs(x_res));

        enhanced_speech(r,:) = x_res;

    end

    enhanced_speech = linear_ovladd(sp_noisy,enhanced_speech,wlen,inc);
    audiowrite('sp_enhanced.wav',enhanced_speech,fs);       % 将增强的语音写入

    addpath 'D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\评价指标\PESQ_STOI\eva_composite'
    pesq1 = pesq([fileFolder2 fileNames2{ii}], 'sp_enhanced.wav');
    pesq_sum = pesq_sum + pesq1(1);
    segSnr1 = FrequencyWeightedSNRseg([fileFolder2 fileNames2{ii}],'sp_enhanced.wav');
    segSnr_sum = segSnr_sum + segSnr1;
    ii
end
pesq_avg = pesq_sum/30
segSnr_avg = segSnr_sum/30