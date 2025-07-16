%-------------------------------------------------------------------------
%  文 件 名  : wavelet
%  作    者  : 秦炜
%  生成日期  : 2022年5月25日
%  功能描述  : 语音增强-小波算法的实现过程                                                    
%-----------------------------------------------------------------------

close all; clear; clc;
[signal,fs] = audioread('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\cleanfile\sp02.wav');  % 读入干净语音
signal = signal - mean(signal);  % 去直流分量
signal = signal/max(abs(signal));  % 归一化
model = load(['D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\noisefile\white.mat']);    % 读入白噪音
% model = load(['D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\noise\pink.mat']);     % 读入粉红噪音
% model = load(['D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\noise\factory1.mat']); % 读入工厂噪音
white = resample(model.white, 8000, 19980);  % 下采样数据，原数据采样率为19.98k
N = length(signal);
noise = white(1000:1000+N-1);   % 选取一段与语音等长噪声

%-------------------------------参数定义---------------------------------                      
t = (0:N-1)/fs;
SNR = 5;                      % 信噪比大小
noise = noise/norm(noise,2).*10^(-SNR/20)*norm(signal);     
sp_noisy = signal + noise;                      % 产生固定信噪比的带噪语音
sp_noisy = sp_noisy - mean(sp_noisy);

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

%-----------------------信噪比--------------------------------------------
SNR_before = snr(signal,noise)
res = signal - enhanced_speech';
SNR_after = snr(signal,res)

%-------------------------------波形----------------------------------------
figure;
subplot(321);
plot(t,signal); ylim([-1.5,1.5]); title('(a)纯净语音'); xlabel('时间/s'); ylabel('幅度');
subplot(323);
plot(t,sp_noisy);ylim([-1.5,1.5]); title('b)带噪语音(5dB白噪声)'); xlabel('时间/s');ylabel('幅度');
subplot(325);
plot(t,real(enhanced_speech)); ylim([-1.5,1.5]); title('(c)wavelet-增强语音'); xlabel('时间/s'); ylabel('幅度');

%-------------------------------语谱图----------------------------------------
subplot(322);
spectrogram(signal,256,128,256,8000,'yaxis');xlabel('时间(s)');ylabel('频率(Hz)');title('(d)纯净语音语谱图');
subplot(324);
spectrogram(sp_noisy,256,128,256,8000,'yaxis');xlabel('时间(s)');ylabel('频率(Hz)');title('(e)带噪语音(5dB白噪声)语谱图');
subplot(326);
spectrogram(enhanced_speech,256,128,256,8000,'yaxis');xlabel('时间(s)');ylabel('频率(Hz)');title('(f)wavelet-增强语音语谱图');

addpath 'D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\评价指标\PESQ_STOI\eva_composite'
pesq('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\cleanfile\sp02.wav', 'sp_enhanced.wav')
FrequencyWeightedSNRseg('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\cleanfile\sp02.wav', 'sp_enhanced.wav')
[Csig,Cbak,Covl] = composite('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\cleanfile\sp02.wav', 'sp_enhanced.wav')