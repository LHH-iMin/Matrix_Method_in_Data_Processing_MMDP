%-------------------------------------------------------------------------
%  文 件 名  : kalman
%  作    者  : 秦炜
%  生成日期  : 2022年5月22日
%  功能描述  : 语音增强-卡尔曼滤波算法的实现过程                                                    
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

Time = (0:1/fs:(length(signal)-1)/fs)';     % 时间轴
Noise=sp_noisy(1:fs,1);                     % 选取前1秒语音作为噪声方差估计
len_win = 0.0025;        % 窗长2.5ms
shift_percent = 1;       % 窗移占比
AR_order = 20;           % 滤波器阶数
iter = 7;                      %迭代次数设置
%% 分帧加窗处理
len_winframe = fix(len_win * fs);
window = ones(len_winframe,1);
[y, num_frame] = KFrame(sp_noisy, len_winframe, window, shift_percent);

%% 初始化
H = [zeros(1,AR_order-1),1];   % 观测矩阵
R = var(Noise);                       % 噪声方差
[filt_coeff, Q] = lpc(y, AR_order);              % LPC预测，得到滤波器的系数
C = R * eye(AR_order,AR_order);              % 误差协方差矩阵
enhanced_speech = zeros(1,length(sp_noisy));    % 增强后的语音信号
enhanced_speech(1:AR_order) = sp_noisy(1:AR_order,1)';   %初始化
updata_x = sp_noisy(1:AR_order,1);

% 迭代器的次数.
i = AR_order+1;
j = AR_order+1;

%% 卡尔曼滤波
for k = 1:num_frame   %一次处理一帧信号
    jStart = j;       % 跟踪每次迭代AR_Order+1的值.
    OutputOld = updata_x;    %为每次迭代保留第一批AROrder预估量
    
    for l = 1:iter               %迭代次数
        fai = [zeros(AR_order-1,1) eye(AR_order-1); fliplr(-filt_coeff(k,2:end))];
        
        for ii = i:len_winframe
            %% 卡尔曼滤波
            predict_x = fai * updata_x;
            predict_C = (fai * C * fai') + (H' * Q(k) * H);
            K = (predict_C * H')/((H * predict_C * H') + R);
            updata_x = predict_x + (K * (y(ii,k) - (H*predict_x)));
            enhanced_speech(j-AR_order+1:j) = updata_x';
            C = (eye(AR_order) - K * H) * predict_C;
            j = j+1;
        end
        i = 1;
        if l < iter
            j = jStart;
            updata_x = OutputOld;
        end
        % 更新滤波后信号的lpc
        [filt_coeff(k,:), Q(k)] = lpc(enhanced_speech((k-1)*len_winframe+1:k*len_winframe),AR_order);
    end
end
enhanced_speech = enhanced_speech(1:N)';

audiowrite('sp_noisy.wav',sp_noisy,fs);       % 将含噪语音写入
audiowrite('sp_enhanced.wav',enhanced_speech,fs); % 将增强语音写入

%-----------------------信噪比--------------------------------------------
SNR_before = snr(signal,noise)
res = signal - enhanced_speech;
SNR_after = snr(signal,res)
%-------------------------------波形----------------------------------------
figure;
subplot(321);
plot(t,signal,'k'); ylim([-1.5,1.5]); title('(a)纯净语音'); xlabel('时间/s'); ylabel('幅度');
subplot(323);
plot(t,sp_noisy,'b');ylim([-1.5,1.5]); title('b)带噪语音(5dB白噪声)'); xlabel('时间/s');ylabel('幅度');
subplot(325);
plot(t,real(enhanced_speech),'r'); ylim([-1.5,1.5]); title('(c)卡尔曼滤波法-增强语音'); xlabel('时间/s'); ylabel('幅度');
%-------------------------------语谱图----------------------------------------
subplot(322);
spectrogram(signal,256,128,256,8000,'yaxis');xlabel('时间(s)');ylabel('频率(Hz)');title('(d)纯净语音语谱图');
subplot(324);
spectrogram(sp_noisy,256,128,256,8000,'yaxis');xlabel('时间(s)');ylabel('频率(Hz)');title('(e)带噪语音(5dB白噪声)语谱图');
subplot(326);
spectrogram(enhanced_speech,256,128,256,8000,'yaxis');xlabel('时间(s)');ylabel('频率(Hz)');title('(f)卡尔曼滤波法-增强语音语谱图');

addpath 'D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\评价指标\PESQ_STOI\eva_composite'
pesq('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\cleanfile\sp02.wav', 'sp_enhanced.wav')
FrequencyWeightedSNRseg('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\cleanfile\sp02.wav','sp_enhanced.wav')
[Csig,Cbak,Covl] = composite('D:\Daily\matrix\秦炜_数据处理中的矩阵方法_读书笔记\dataset\cleanfile\sp02.wav','sp_enhanced.wav')
