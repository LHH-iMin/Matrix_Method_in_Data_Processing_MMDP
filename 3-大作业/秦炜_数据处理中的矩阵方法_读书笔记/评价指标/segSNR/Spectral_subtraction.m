close all; clear; clc;
%-------------------------------������������ļ�---------------------------
[filename,pathname] = uigetfile('*.wav','��ѡ�񴿾������ļ���');
clean = audioread([pathname filename])';

[filename,pathname] = uigetfile('*.wav','��ѡ����������ļ���');
noise = audioread([pathname filename])';
[sound,fs] = audioread('sp01.wav');  
%-------------------------------��������---------------------------------
frame_len = 256; %֡��
step_len = 0.5*frame_len; %��֡ʱ�Ĳ������൱���ص�50%
wav_length = length(clean);
R = step_len;
L = frame_len; 
f = (wav_length-mod(wav_length,frame_len))/frame_len;
k = 2*f-1; % ֡��
h = sqrt(1/101.3434)*hamming(256)'; % ����������ϵ����ԭ����ʹ�临������Ҫ��
noise = noise(1:f*L);  % ���������봿���������ȶ���
clean= clean(1:f*L);
win = zeros(1,f*L); % �趨��ʼֵ��
enspeech = zeros(1,f*L);                         
%-------------------------------��֡-------------------------------------
for r = 1:k 
    y = noise(1+(r-1)*R:L+(r-1)*R); % �Դ�������֡���ص�һ��ȡֵ��
    y = y.*h; % ��ȡ�õ�ÿһ֡���Ӵ�����
    w = fft(y); % ��ÿһ֡��������Ҷ�任��
    Y(1+(r-1)*L:r*L) = w(1:L); % �Ѹ���Ҷ�任ֵ����Y�У�
end
%-------------------------------��������-----------------------------------
   NOISE= stationary_noise_evaluate(Y,L,k); %������Сֵ�����㷨
%     NOISE= non_stationary_noise_evaluate(Y,L,k); % ����ͳ����Ϣ�ķ�ƽ����������Ӧ�㷨
%-------------------------------�׼���-------------------------------------
for     t = 1:k     
         X = abs(Y).^2;   
         S = X(1+(t-1)*L:t*L)-NOISE(1+(t-1)*L:t*L); % �������������׼�ȥ���������ף�
         S = sqrt(S);
         A = Y(1+(t-1)*L:t*L)./abs(Y(1+(t-1)*L:t*L)); % ��������������λ��
         S = S.*A; % ��Ϊ�˶�����λ�ĸо������ԣ����Իָ�ʱ�õ��Ǵ�����������λ��Ϣ��
         s = ifft(S);   
         s = real(s); % ȡʵ����
         enspeech(1+(t-1)*L/2:L+(t-1)*L/2) = enspeech(1+(t-1)*L/2:L+(t-1)*L/2)+s; % ��ʵ�������ӣ�
         win(1+(t-1)*L/2:L+(t-1)*L/2) = win(1+(t-1)*L/2:L+(t-1)*L/2)+h; % ���ĵ�����ӣ�
end
enspeech = enspeech./win; % ȥ���Ӵ����������õ���ǿ��������
%-----------------------�����--------------------------------------------
%SNR_before=SNR1(tidy,wavin);
%SNR_after=SNR2(tidy,enspeech);
%-------------------------------��������----------------------------------------

 subplot(3,1,1);plot(clean);title('(a)��������');xlabel('������');ylabel('����');axis([0 2.5*10^4 -0.3 0.3]);
 subplot(3,1,2);plot(noise);title('(b)��������(15dB������)');xlabel('������');ylabel('����');axis([0 2.5*10^4 -0.3 0.3]);
 subplot(3,1,3);plot(enspeech);title('(c)�׼���-��ǿ����');xlabel('������');ylabel('����');axis([0 2.5*10^4 -0.3 0.3]);
 axis([0 7*10^4 -1 1]);
 axis([0 2.5*10^4 -0.3 0.3]);
 audiowrite('spectruesub_enspeech.wav',enspeech,fs); % д����ǿ������
 fwSNRseg=FrequencyWeightedSNRseg('sp01.wav', 'spectruesub_enspeech.wav')%�����ȨƵ���ֶ������
