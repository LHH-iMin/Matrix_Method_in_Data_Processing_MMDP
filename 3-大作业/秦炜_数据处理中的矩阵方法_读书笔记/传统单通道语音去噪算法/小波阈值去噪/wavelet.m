%-------------------------------------------------------------------------
%  �� �� ��  : wavelet
%  ��    ��  : ���
%  ��������  : 2022��5��25��
%  ��������  : ������ǿ-С���㷨��ʵ�ֹ���                                                    
%-----------------------------------------------------------------------

close all; clear; clc;
[signal,fs] = audioread('D:\Daily\matrix\���_���ݴ����еľ��󷽷�_����ʼ�\dataset\cleanfile\sp02.wav');  % ����ɾ�����
signal = signal - mean(signal);  % ȥֱ������
signal = signal/max(abs(signal));  % ��һ��
model = load(['D:\Daily\matrix\���_���ݴ����еľ��󷽷�_����ʼ�\dataset\noisefile\white.mat']);    % ���������
% model = load(['D:\Daily\matrix\���_���ݴ����еľ��󷽷�_����ʼ�\noise\pink.mat']);     % ����ۺ�����
% model = load(['D:\Daily\matrix\���_���ݴ����еľ��󷽷�_����ʼ�\noise\factory1.mat']); % ���빤������
white = resample(model.white, 8000, 19980);  % �²������ݣ�ԭ���ݲ�����Ϊ19.98k
N = length(signal);
noise = white(1000:1000+N-1);   % ѡȡһ���������ȳ�����

%-------------------------------��������---------------------------------                      
t = (0:N-1)/fs;
SNR = 5;                      % ����ȴ�С
noise = noise/norm(noise,2).*10^(-SNR/20)*norm(signal);     
sp_noisy = signal + noise;                      % �����̶�����ȵĴ�������
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

%���øĽ���ֵ��������ȥ�봦��
gd1 = chuliyuzhi(d1,thr);
gd2 = chuliyuzhi(d2,thr);
gd3 = chuliyuzhi(d3,thr);
gd4 = chuliyuzhi(d4,thr);
gd5 = chuliyuzhi(d5,thr);
c1 = [a5 gd5 gd4 gd3 gd2 gd1];
enhanced_speech = waverec(c1,l,'sym8');  % ��߶��ع�

audiowrite('sp_enhanced.wav',enhanced_speech,8000)

%-----------------------�����--------------------------------------------
SNR_before = snr(signal,noise)
res = signal - enhanced_speech';
SNR_after = snr(signal,res)

%-------------------------------����----------------------------------------
figure;
subplot(321);
plot(t,signal); ylim([-1.5,1.5]); title('(a)��������'); xlabel('ʱ��/s'); ylabel('����');
subplot(323);
plot(t,sp_noisy);ylim([-1.5,1.5]); title('b)��������(5dB������)'); xlabel('ʱ��/s');ylabel('����');
subplot(325);
plot(t,real(enhanced_speech)); ylim([-1.5,1.5]); title('(c)wavelet-��ǿ����'); xlabel('ʱ��/s'); ylabel('����');

%-------------------------------����ͼ----------------------------------------
subplot(322);
spectrogram(signal,256,128,256,8000,'yaxis');xlabel('ʱ��(s)');ylabel('Ƶ��(Hz)');title('(d)������������ͼ');
subplot(324);
spectrogram(sp_noisy,256,128,256,8000,'yaxis');xlabel('ʱ��(s)');ylabel('Ƶ��(Hz)');title('(e)��������(5dB������)����ͼ');
subplot(326);
spectrogram(enhanced_speech,256,128,256,8000,'yaxis');xlabel('ʱ��(s)');ylabel('Ƶ��(Hz)');title('(f)wavelet-��ǿ��������ͼ');

addpath 'D:\Daily\matrix\���_���ݴ����еľ��󷽷�_����ʼ�\����ָ��\PESQ_STOI\eva_composite'
pesq('D:\Daily\matrix\���_���ݴ����еľ��󷽷�_����ʼ�\dataset\cleanfile\sp02.wav', 'sp_enhanced.wav')
FrequencyWeightedSNRseg('D:\Daily\matrix\���_���ݴ����еľ��󷽷�_����ʼ�\dataset\cleanfile\sp02.wav', 'sp_enhanced.wav')
[Csig,Cbak,Covl] = composite('D:\Daily\matrix\���_���ݴ����еľ��󷽷�_����ʼ�\dataset\cleanfile\sp02.wav', 'sp_enhanced.wav')