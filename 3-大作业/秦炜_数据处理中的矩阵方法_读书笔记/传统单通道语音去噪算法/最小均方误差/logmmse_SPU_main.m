%-------------------------------------------------------------------------
%  文 件 名  : logmmse_SPU
%  作    者  : 秦炜
%  生成日期  : 2022年5月22日
%  功能描述  : 对数最小均方误差算法的实现过程                                                    
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

audiowrite('sp_noisy.wav',sp_noisy,fs);       % 将混合的语音写入
[enhanced_speech] = logmmse_SPU('sp_noisy.wav','sp_enhanced.wav',1);

%-----------------------信噪比--------------------------------------------
SNR_before = snr(signal,noise)
res = signal - enhanced_speech';
SNR_after = snr(signal,res)
%-------------------------------波形----------------------------------------
figure;
subplot(321);
plot(t,signal,'k'); ylim([-1.5,1.5]); title('(a)纯净语音'); xlabel('时间/s'); ylabel('幅度');
subplot(323);
plot(t,sp_noisy,'b');ylim([-1.5,1.5]); title('b)带噪语音(5dB白噪声)'); xlabel('时间/s');ylabel('幅度');
subplot(325);
plot(t,real(enhanced_speech),'r'); ylim([-1.5,1.5]); title('(c)logmmse_SPU-增强语音'); xlabel('时间/s'); ylabel('幅度');
%-------------------------------语谱图----------------------------------------
subplot(322);
spectrogram(signal,256,128,256,8000,'yaxis');xlabel('时间(s)');ylabel('频率(Hz)');title('(d)纯净语音语谱图');
subplot(324);
spectrogram(sp_noisy,256,128,256,8000,'yaxis');xlabel('时间(s)');ylabel('频率(Hz)');title('(e)带噪语音(5dB白噪声)语谱图');
subplot(326);
spectrogram(enhanced_speech,256,128,256,8000,'yaxis');xlabel('时间(s)');ylabel('频率(Hz)');title('(f)logmmse_SPU-增强语音语谱图');

addpath 'D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\评价指标\PESQ_STOI\eva_composite'
pesq('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\cleanfile\sp02.wav', 'sp_enhanced.wav')
FrequencyWeightedSNRseg('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\cleanfile\sp02.wav','sp_enhanced.wav')
[Csig,Cbak,Covl] = composite('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\cleanfile\sp02.wav','sp_enhanced.wav')