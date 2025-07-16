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

% 用sym8小波对原始信号进行5层分解并提取系数
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

%进行硬阈值处理
ythard1 = wthresh(d1,'h',thr);
ythard2 = wthresh(d2,'h',thr);
ythard3 = wthresh(d3,'h',thr);
ythard4 = wthresh(d4,'h',thr);
ythard5 = wthresh(d5,'h',thr);
c2=[a5  ythard5 ythard4 ythard3 ythard2 ythard1];
enhanced_speech1 = waverec(c2,l,'sym8');

%进行软阈值处理
ytsoftd1 = wthresh(d1,'s',thr);
ytsoftd2 = wthresh(d2,'s',thr);
ytsoftd3 = wthresh(d3,'s',thr);
ytsoftd4 = wthresh(d4,'s',thr);
ytsoftd5 = wthresh(d5,'s',thr);
c3=[a5 ytsoftd5 ytsoftd4 ytsoftd3 ytsoftd2 ytsoftd1];
enhanced_speech2 = waverec(c3,l,'sym8');

audiowrite('sp_enhanced1.wav',enhanced_speech1,8000);
audiowrite('sp_enhanced2.wav',enhanced_speech2,8000);

%-----------------------信噪比--------------------------------------------
SNR_before = snr(signal,noise);
res1 = signal - enhanced_speech1';
SNR_after1 = snr(signal,res1);
res2 = signal - enhanced_speech2';
SNR_after2 = snr(signal,res2);

%-------------------------------波形----------------------------------------
figure;
subplot(421);
plot(t,signal); ylim([-1.5,1.5]); title('(a)纯净语音'); xlabel('时间/s'); ylabel('幅度');
subplot(423);
plot(t,sp_noisy);ylim([-1.5,1.5]); title('b)带噪语音(5dB白噪声)'); xlabel('时间/s');ylabel('幅度');
subplot(425);
plot(t,real(enhanced_speech1)); ylim([-1.5,1.5]); title('(c)wavelet硬-增强语音'); xlabel('时间/s'); ylabel('幅度');
subplot(427);
plot(t,real(enhanced_speech2)); ylim([-1.5,1.5]); title('(d)wavelet软-增强语音'); xlabel('时间/s'); ylabel('幅度');

%-------------------------------语谱图----------------------------------------
subplot(422);
spectrogram(signal,256,128,256,8000,'yaxis');xlabel('时间(s)');ylabel('频率(Hz)');title('(e)纯净语音语谱图');
subplot(424);
spectrogram(sp_noisy,256,128,256,8000,'yaxis');xlabel('时间(s)');ylabel('频率(Hz)');title('(f)带噪语音(5dB白噪声)语谱图');
subplot(426);
spectrogram(enhanced_speech1,256,128,256,8000,'yaxis');xlabel('时间(s)');ylabel('频率(Hz)');title('(g)wavelet硬-增强语音语谱图');
subplot(428);
spectrogram(enhanced_speech2,256,128,256,8000,'yaxis');xlabel('时间(s)');ylabel('频率(Hz)');title('(l)wavelet软-增强语音语谱图');

addpath 'D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\评价指标\PESQ_STOI\eva_composite'
pesq('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\cleanfile\sp02.wav', 'sp_enhanced1.wav');
FrequencyWeightedSNRseg('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\cleanfile\sp02.wav', 'sp_enhanced1.wav');
[Csig,Cbak,Covl] = composite('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\cleanfile\sp02.wav', 'sp_enhanced1.wav');

pesq('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\cleanfile\sp02.wav', 'sp_enhanced2.wav');
FrequencyWeightedSNRseg('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\cleanfile\sp02.wav', 'sp_enhanced2.wav');
[Csig,Cbak,Covl] = composite('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\cleanfile\sp02.wav', 'sp_enhanced2.wav');