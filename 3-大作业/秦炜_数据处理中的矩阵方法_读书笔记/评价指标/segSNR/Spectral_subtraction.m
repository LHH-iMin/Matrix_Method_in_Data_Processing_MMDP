close all; clear; clc;
%-------------------------------读入带噪语音文件---------------------------
[filename,pathname] = uigetfile('*.wav','请选择纯净语音文件：');
clean = audioread([pathname filename])';

[filename,pathname] = uigetfile('*.wav','请选择带噪语音文件：');
noise = audioread([pathname filename])';
[sound,fs] = audioread('sp01.wav');  
%-------------------------------参数定义---------------------------------
frame_len = 256; %帧长
step_len = 0.5*frame_len; %分帧时的步长，相当于重叠50%
wav_length = length(clean);
R = step_len;
L = frame_len; 
f = (wav_length-mod(wav_length,frame_len))/frame_len;
k = 2*f-1; % 帧数
h = sqrt(1/101.3434)*hamming(256)'; % 汉宁窗乘以系数的原因是使其复合条件要求；
noise = noise(1:f*L);  % 带噪语音与纯净语音长度对齐
clean= clean(1:f*L);
win = zeros(1,f*L); % 设定初始值；
enspeech = zeros(1,f*L);                         
%-------------------------------分帧-------------------------------------
for r = 1:k 
    y = noise(1+(r-1)*R:L+(r-1)*R); % 对带噪语音帧间重叠一半取值；
    y = y.*h; % 对取得的每一帧都加窗处理；
    w = fft(y); % 对每一帧都作傅里叶变换；
    Y(1+(r-1)*L:r*L) = w(1:L); % 把傅里叶变换值放在Y中；
end
%-------------------------------估计噪声-----------------------------------
   NOISE= stationary_noise_evaluate(Y,L,k); %噪声最小值跟踪算法
%     NOISE= non_stationary_noise_evaluate(Y,L,k); % 基于统计信息的非平稳噪声自适应算法
%-------------------------------谱减法-------------------------------------
for     t = 1:k     
         X = abs(Y).^2;   
         S = X(1+(t-1)*L:t*L)-NOISE(1+(t-1)*L:t*L); % 含噪语音功率谱减去噪声功率谱；
         S = sqrt(S);
         A = Y(1+(t-1)*L:t*L)./abs(Y(1+(t-1)*L:t*L)); % 带噪于语音的相位；
         S = S.*A; % 因为人耳对相位的感觉不明显，所以恢复时用的是带噪语音的相位信息；
         s = ifft(S);   
         s = real(s); % 取实部；
         enspeech(1+(t-1)*L/2:L+(t-1)*L/2) = enspeech(1+(t-1)*L/2:L+(t-1)*L/2)+s; % 在实域叠接相加；
         win(1+(t-1)*L/2:L+(t-1)*L/2) = win(1+(t-1)*L/2:L+(t-1)*L/2)+h; % 窗的叠接相加；
end
enspeech = enspeech./win; % 去除加窗引起的增益得到增强的语音；
%-----------------------信噪比--------------------------------------------
%SNR_before=SNR1(tidy,wavin);
%SNR_after=SNR2(tidy,enspeech);
%-------------------------------画出波形----------------------------------------

 subplot(3,1,1);plot(clean);title('(a)纯净语音');xlabel('样点数');ylabel('幅度');axis([0 2.5*10^4 -0.3 0.3]);
 subplot(3,1,2);plot(noise);title('(b)带噪语音(15dB白噪声)');xlabel('样点数');ylabel('幅度');axis([0 2.5*10^4 -0.3 0.3]);
 subplot(3,1,3);plot(enspeech);title('(c)谱减法-增强语音');xlabel('样点数');ylabel('幅度');axis([0 2.5*10^4 -0.3 0.3]);
 axis([0 7*10^4 -1 1]);
 axis([0 2.5*10^4 -0.3 0.3]);
 audiowrite('spectruesub_enspeech.wav',enspeech,fs); % 写出增强语音；
 fwSNRseg=FrequencyWeightedSNRseg('sp01.wav', 'spectruesub_enspeech.wav')%计算加权频带分段信噪比
