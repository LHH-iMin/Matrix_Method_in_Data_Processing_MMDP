%-------------------------------------------------------------------------
%  文 件 名  : VMD
%  作    者  : 秦炜
%  生成日期  : 2022年5月25日
%  功能描述  : 变分模态算法的实现过程                                                    
%-----------------------------------------------------------------------

%-------------------------------读入带噪语音文件--------------------------
close all; clear; clc;
[signal,fs] = audioread('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\cleanfile\sp02.wav');  % 读入干净语音
signal = signal - mean(signal);  % 去直流分量
signal = signal/max(abs(signal));  % 归一化
model = load(['D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\noisefile\white.mat']);    % 读入白噪音
% model = load(['D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\noisefile\pink.mat']);     % 读入粉红噪音
% model = load(['D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\noisefile\factory1.mat']); % 读入工厂噪音
white = resample(model.white, 8000, 19980);  % 下采样数据，原数据采样率为19.98k
N = length(signal);
noise = white(1000:1000+N-1);   % 选取一段与语音等长噪声

%-------------------------------参数定义---------------------------------                      
t = (0:N-1)/fs;
SNR = 5;                      % 信噪比大小
noise = noise/norm(noise,2).*10^(-SNR/20)*norm(signal);     
sp_noisy = signal + noise;                      % 产生固定信噪比的带噪语音
sp_noisy = sp_noisy - mean(sp_noisy);
noise_std = sqrt((noise.'*noise)/length(noise));  % 噪声方差
% some sample parameters for VMD
alpha = 1000;       % moderate bandwidth constraint
tau = 0;            % noise-tolerance (no strict fidelity enforcement)
% K = 12;             % 3 modes
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
[aa, b] = size(S);
enhanced_speech = zeros(aa,b);
for r = 1:aa
    data = S(r,:);
    x_res = zeros(1,frameSize);
    wname = 'db6';
    for w = 3:7
        [C,L] = wavedec(data,w,wname);
        %对含噪声源进行离散小波分解，并提取高低频系数
    wt_corr = zeros(1,w);
    switch w
    case 3
        a1 = appcoef(C,L,wname,1);
        d1 = detcoef(C,L,1);
        a2 = appcoef(C,L,wname,2);
        d2 = detcoef(C,L,2);
        a3 = appcoef(C,L,wname,3);
        d3 = detcoef(C,L,3);
        wt_corr(1) = corr(a1',d1','type','Spearman');
        wt_corr(2) = corr(a2',d2','type','Spearman');
        wt_corr(3) = corr(a3',d3','type','Spearman');
        
    case 4
        a1 = appcoef(C,L,wname,1);
        d1 = detcoef(C,L,1);
        a2 = appcoef(C,L,wname,2);
        d2 = detcoef(C,L,2);
        a3 = appcoef(C,L,wname,3);
        d3 = detcoef(C,L,3);
        a4 = appcoef(C,L,wname,4);
        d4 = detcoef(C,L,4);
        wt_corr(1) = corr(a1',d1','type','Spearman');
        wt_corr(2) = corr(a2',d2','type','Spearman');
        wt_corr(3) = corr(a3',d3','type','Spearman');
        wt_corr(4) = corr(a4',d4','type','Spearman');

    case 5
        a1 = appcoef(C,L,wname,1);
        d1 = detcoef(C,L,1);
        a2 = appcoef(C,L,wname,2);
        d2 = detcoef(C,L,2);
        a3 = appcoef(C,L,wname,3);
        d3 = detcoef(C,L,3);
        a4 = appcoef(C,L,wname,4);
        d4 = detcoef(C,L,4);
        a5 = appcoef(C,L,wname,5);
        d5 = detcoef(C,L,5);
        wt_corr(1) = corr(a1',d1','type','Spearman');
        wt_corr(2) = corr(a2',d2','type','Spearman');
        wt_corr(3) = corr(a3',d3','type','Spearman');
        wt_corr(4) = corr(a4',d4','type','Spearman');
        wt_corr(5) = corr(a5',d5','type','Spearman');

    case 6
        a1 = appcoef(C,L,wname,1);
        d1 = detcoef(C,L,1);
        a2 = appcoef(C,L,wname,2);
        d2 = detcoef(C,L,2);
        a3 = appcoef(C,L,wname,3);
        d3 = detcoef(C,L,3);
        a4 = appcoef(C,L,wname,4);
        d4 = detcoef(C,L,4);
        a5 = appcoef(C,L,wname,5);
        d5 = detcoef(C,L,5);
        a6 = appcoef(C,L,wname,6);
        d6 = detcoef(C,L,6);
        wt_corr(1) = corr(a1',d1','type','Spearman');
        wt_corr(2) = corr(a2',d2','type','Spearman');
        wt_corr(3) = corr(a3',d3','type','Spearman');
        wt_corr(4) = corr(a4',d4','type','Spearman');
        wt_corr(5) = corr(a5',d5','type','Spearman');
        wt_corr(6) = corr(a6',d6','type','Spearman');

    otherwise
        a1 = appcoef(C,L,wname,1);
        d1 = detcoef(C,L,1);
        a2 = appcoef(C,L,wname,2);
        d2 = detcoef(C,L,2);
        a3 = appcoef(C,L,wname,3);
        d3 = detcoef(C,L,3);
        a4 = appcoef(C,L,wname,4);
        d4 = detcoef(C,L,4);
        a5 = appcoef(C,L,wname,5);
        d5 = detcoef(C,L,5);
        a6 = appcoef(C,L,wname,6);
        d6 = detcoef(C,L,6);
        a7 = appcoef(C,L,wname,7);
        d7 = detcoef(C,L,7);
        wt_corr(1) = corr(a1',d1','type','Spearman');
        wt_corr(2) = corr(a2',d2','type','Spearman');
        wt_corr(3) = corr(a3',d3','type','Spearman');
        wt_corr(4) = corr(a4',d4','type','Spearman');
        wt_corr(5) = corr(a5',d5','type','Spearman');
        wt_corr(6) = corr(a6',d6','type','Spearman');
        wt_corr(7) = corr(a7',d7','type','Spearman');
    end
    wt_corr(1) = -1;
    wt_corr(2) = -1;
    if max(wt_corr)>1/2/w
        wt_max = max(wt_corr);
        idx = find(wt_corr==wt_max);
        K = 2*(idx-1);
        break;
    else
        continue;
    end
    
    if w == 7
        K = 2*w;
    end

    end

    [modes, u_hat, omega] = VMD(data, alpha, tau, K, DC, init, tol);
    [a,b] = size(modes);
    R_corr = zeros(K,2*frameSize-1);
    R_corr1 = zeros(1,2*frameSize-1);
    x_ress = modes(1,:)+modes(2,:)+modes(3,:);
    for i = 1:K
        R_corrr = xcorr(modes(i,:));
        R_corrr = R_corrr./max(R_corrr);
        R_corr(i,:) = R_corrr;
    end
    x_noise = data-x_ress;
    R_corr1 = xcorr(x_noise);
    R_corr1 = R_corr1./max(R_corr1);
    R = zeros(1,K);
    for i = 1:K
        RR = corrcoef(R_corr(i,:)',R_corr1');
        R(i) = RR(1,2);
    end

    idx = find(R<=3/K);
    x_res = sum(modes(idx,:));
    tol = sum(abs(modes(max(idx),:)))/10;
    if length(idx)<K
        idx1 = find(R>3/K);
        NN = K - length(idx);
        for i = 1:NN
            if sum(abs(modes(i,1))) < tol
                x_res = x_res + modes(i,:);
            end
        end
    end

    enhanced_speech(r,:) = x_res;

end

enhanced_speech = linear_ovladd(sp_noisy,enhanced_speech,wlen,inc);
figure; plot(enhanced_speech);
title('调用linear_ovladd合成波形');

audiowrite('sp_enhanced.wav',enhanced_speech,fs);       % 将混合的语音写入

%-----------------------信噪比--------------------------------------------
SNR_before = snr(signal,noise);
res = signal - enhanced_speech;
SNR_after = snr(signal,res);

%-------------------------------波形----------------------------------------
figure;
subplot(321);
plot(t,signal); ylim([-1.5,1.5]); title('(a)纯净语音'); xlabel('时间/s'); ylabel('幅度');
subplot(323);
plot(t,sp_noisy);ylim([-1.5,1.5]); title('b)带噪语音(5dB白噪声)'); xlabel('时间/s');ylabel('幅度');
subplot(325);
plot(t,real(enhanced_speech)); ylim([-1.5,1.5]); title('(c)VMD-增强语音'); xlabel('时间/s'); ylabel('幅度');

%-------------------------------语谱图----------------------------------------
subplot(322);
spectrogram(signal,256,128,256,8000,'yaxis');xlabel('时间(s)');ylabel('频率(Hz)');title('(d)纯净语音语谱图');
subplot(324);
spectrogram(sp_noisy,256,128,256,8000,'yaxis');xlabel('时间(s)');ylabel('频率(Hz)');title('(e)带噪语音(5dB白噪声)语谱图');
subplot(326);
spectrogram(enhanced_speech,256,128,256,8000,'yaxis');xlabel('时间(s)');ylabel('频率(Hz)');title('(f)VMD-增强语音语谱图');

addpath 'D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\评价指标\PESQ_STOI\eva_composite'
pesq('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\cleanfile\sp02.wav', 'sp_enhanced.wav')
FrequencyWeightedSNRseg('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\cleanfile\sp02.wav','sp_enhanced.wav')
[Csig,Cbak,Covl] = composite('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\cleanfile\sp02.wav','sp_enhanced.wav')
