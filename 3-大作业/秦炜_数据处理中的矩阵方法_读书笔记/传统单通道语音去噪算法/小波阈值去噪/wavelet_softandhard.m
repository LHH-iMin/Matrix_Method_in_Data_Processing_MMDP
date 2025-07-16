close all; clear; clc;
[signal,fs] = audioread('D:\Daily\matrix\���_���ݴ����еľ��󷽷�_����ʼ�\dataset\cleanfile\sp02.wav');  % ����ɾ�����
signal = signal - mean(signal);  % ȥֱ������
signal = signal/max(abs(signal));  % ��һ��
model = load(['D:\Daily\matrix\���_���ݴ����еľ��󷽷�_����ʼ�\dataset\noisefile\white.mat']);    % ���������
% model = load(['D:\Daily\matrix\���_���ݴ����еľ��󷽷�_����ʼ�\dataset\noisefile\pink.mat']);     % ����ۺ�����
% model = load(['D:\Daily\matrix\���_���ݴ����еľ��󷽷�_����ʼ�\dataset\noisefile\factory1.mat']); % ���빤������
white = resample(model.white, 8000, 19980);  % �²������ݣ�ԭ���ݲ�����Ϊ19.98k
N = length(signal);
noise = white(1000:1000+N-1);   % ѡȡһ���������ȳ�����

%-------------------------------��������---------------------------------                      
t = (0:N-1)/fs;
SNR = 5;                      % ����ȴ�С
noise = noise/norm(noise,2).*10^(-SNR/20)*norm(signal);     
sp_noisy = signal + noise;                      % �����̶�����ȵĴ�������
sp_noisy = sp_noisy - mean(sp_noisy);

% ��sym8С����ԭʼ�źŽ���5��ֽⲢ��ȡϵ��
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

%����Ӳ��ֵ����
ythard1 = wthresh(d1,'h',thr);
ythard2 = wthresh(d2,'h',thr);
ythard3 = wthresh(d3,'h',thr);
ythard4 = wthresh(d4,'h',thr);
ythard5 = wthresh(d5,'h',thr);
c2=[a5  ythard5 ythard4 ythard3 ythard2 ythard1];
enhanced_speech1 = waverec(c2,l,'sym8');

%��������ֵ����
ytsoftd1 = wthresh(d1,'s',thr);
ytsoftd2 = wthresh(d2,'s',thr);
ytsoftd3 = wthresh(d3,'s',thr);
ytsoftd4 = wthresh(d4,'s',thr);
ytsoftd5 = wthresh(d5,'s',thr);
c3=[a5 ytsoftd5 ytsoftd4 ytsoftd3 ytsoftd2 ytsoftd1];
enhanced_speech2 = waverec(c3,l,'sym8');

audiowrite('sp_enhanced1.wav',enhanced_speech1,8000);
audiowrite('sp_enhanced2.wav',enhanced_speech2,8000);

%-----------------------�����--------------------------------------------
SNR_before = snr(signal,noise);
res1 = signal - enhanced_speech1';
SNR_after1 = snr(signal,res1);
res2 = signal - enhanced_speech2';
SNR_after2 = snr(signal,res2);

%-------------------------------����----------------------------------------
figure;
subplot(421);
plot(t,signal); ylim([-1.5,1.5]); title('(a)��������'); xlabel('ʱ��/s'); ylabel('����');
subplot(423);
plot(t,sp_noisy);ylim([-1.5,1.5]); title('b)��������(5dB������)'); xlabel('ʱ��/s');ylabel('����');
subplot(425);
plot(t,real(enhanced_speech1)); ylim([-1.5,1.5]); title('(c)waveletӲ-��ǿ����'); xlabel('ʱ��/s'); ylabel('����');
subplot(427);
plot(t,real(enhanced_speech2)); ylim([-1.5,1.5]); title('(d)wavelet��-��ǿ����'); xlabel('ʱ��/s'); ylabel('����');

%-------------------------------����ͼ----------------------------------------
subplot(422);
spectrogram(signal,256,128,256,8000,'yaxis');xlabel('ʱ��(s)');ylabel('Ƶ��(Hz)');title('(e)������������ͼ');
subplot(424);
spectrogram(sp_noisy,256,128,256,8000,'yaxis');xlabel('ʱ��(s)');ylabel('Ƶ��(Hz)');title('(f)��������(5dB������)����ͼ');
subplot(426);
spectrogram(enhanced_speech1,256,128,256,8000,'yaxis');xlabel('ʱ��(s)');ylabel('Ƶ��(Hz)');title('(g)waveletӲ-��ǿ��������ͼ');
subplot(428);
spectrogram(enhanced_speech2,256,128,256,8000,'yaxis');xlabel('ʱ��(s)');ylabel('Ƶ��(Hz)');title('(l)wavelet��-��ǿ��������ͼ');

addpath 'D:\Daily\matrix\���_���ݴ����еľ��󷽷�_����ʼ�\����ָ��\PESQ_STOI\eva_composite'
pesq('D:\Daily\matrix\���_���ݴ����еľ��󷽷�_����ʼ�\dataset\cleanfile\sp02.wav', 'sp_enhanced1.wav');
FrequencyWeightedSNRseg('D:\Daily\matrix\���_���ݴ����еľ��󷽷�_����ʼ�\dataset\cleanfile\sp02.wav', 'sp_enhanced1.wav');
[Csig,Cbak,Covl] = composite('D:\Daily\matrix\���_���ݴ����еľ��󷽷�_����ʼ�\dataset\cleanfile\sp02.wav', 'sp_enhanced1.wav');

pesq('D:\Daily\matrix\���_���ݴ����еľ��󷽷�_����ʼ�\dataset\cleanfile\sp02.wav', 'sp_enhanced2.wav');
FrequencyWeightedSNRseg('D:\Daily\matrix\���_���ݴ����еľ��󷽷�_����ʼ�\dataset\cleanfile\sp02.wav', 'sp_enhanced2.wav');
[Csig,Cbak,Covl] = composite('D:\Daily\matrix\���_���ݴ����еľ��󷽷�_����ʼ�\dataset\cleanfile\sp02.wav', 'sp_enhanced2.wav');