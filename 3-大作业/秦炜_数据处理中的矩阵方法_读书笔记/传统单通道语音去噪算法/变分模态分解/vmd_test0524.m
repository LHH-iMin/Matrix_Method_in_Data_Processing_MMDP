%-------------------------------------------------------------------------
%  文 件 名  : VMD
%  作    者  : 秦炜
%  生成日期  : 2022年5月24日
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
% noise_std = sqrt((noise.'*noise)/length(noise));  % 噪声方差

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
            noise_std = sqrt((noise.'*noise)/length(noise));
            [xc] = wavelet_hard(modes(i,:),3,'db6');
         
%             [thr,sort,keepapp,crit] = ddencmp('den','wp',modes(i,:));  % 小波包分解
%             xc = wpdencmp(modes(i,:),sort,3,'db6',crit,thr,keepapp);
            x_res = x_res + xc;  % 重构

%             [thrv,sortv,keepappv] = ddencmp('den','wv',modes(i,:));
%             xd = wdencmp('gbl',modes(i,:),'db6',10,thrv,sortv,keepappv);
%             x_res = x_res + xd;
        end
    end
%     x_res = x_res/max(abs(x_res));

    enhanced_speech(r,:) = x_res;

end

enhanced_speech = linear_ovladd(sp_noisy,enhanced_speech,wlen,inc);
% figure; plot(enhanced_speech);
% title('调用linear_ovladd合成波形');

audiowrite('sp_enhanced.wav',enhanced_speech,fs);       % 将混合的语音写入

%-----------------------信噪比--------------------------------------------
SNR_before = snr(signal,noise)
res = signal - enhanced_speech;
SNR_after = snr(signal,res)

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