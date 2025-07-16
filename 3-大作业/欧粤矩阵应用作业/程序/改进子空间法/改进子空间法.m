clear all; clc; close all;

IS=0.05;                                % 设置前导无话段长度
wlen=80;                               % 设置帧长为25ms
inc=40;                                 % 求帧移
SNR=8;                                 % 设置信噪比
[filename,pathname]=uigetfile('*.wav','请选择纯净语音文件：');
[xx,fs]=audioread([pathname filename]);

% [filename,pathname]=uigetfile('*.wav','璇烽?鎷╃函鍑?闊虫枃浠讹細');
% [tidy,fs]=audioread([pathname filename]);
% [filename,pathname]=uigetfile('*.wav','璇烽?鎷╁甫鍣闊虫枃浠讹細');
% [wavin,fs]=audioread([pathname filename]);



x=xx(:,1)-mean(xx(:,1));                         % 娑堥櫎鐩存祦鍒嗛噺
x=xx/max(abs(xx));                      % 骞呭?褰掍竴鍖?
% signal=wavin(:,1)-mean(wavin(:,1));                         % 娑堥櫎鐩存祦鍒嗛噺
% signal=signal/max(abs(signal));                      % 骞呭?褰掍竴鍖?

% Ps=sum(sum((x-mean(mean(x))).^2));%signal power
% Pn=sum(sum((x-signal).^2));           %noise power
% snr1=10*log10(Ps/Pn);
% disp(snr1);



N=length(x);                            % 取信号长度
time=(0:N-1)/fs;                        % 设置时间

signal=awgn(x,SNR,'measured','db');                % 叠加噪声
wnd=hamming(wlen);                      % 设置窗函数
overlap=wlen-inc;                       % 求重叠区长度
NIS=fix((IS*fs-wlen)/inc +1);           % 求前导无话段帧数

tic;
y=enframe(signal,wnd,inc)' ;          % 分帧
disp(size(y));
fn=size(y,2);                           % 求帧数

n_var=var(signal(1:2000),1);  %取前3000采样点用于估计噪声方差

%NRM=zeros(size(N));                           %噪声残余量最大值
Y=fft(y,wlen);                               % FFT变换
YPhase=angle(Y(1:fix(wlen/2)+1,:));          %含噪语音的相位
Y=abs(Y(1:fix(wlen/2)+1,:));            % 计算正频率幅值


N=mean(Y(:,1:NIS),2);                   % 计算前导无话段噪声区平均频谱
NoiseCounter=100;
NoiseLength=9;
Beta=0.03;
NN=2;
u=0.02;

Ry=zeros(wlen,wlen);          %定义帧信号的Toeplitz协方差矩阵
seq=zeros(1,wlen);


YS=Y;                                               %平均谱值
for i=2:(fn-1)
    YS(:,i)=(Y(:,i-1)+Y(:,i)+Y(:,i+1))/3;
end


chance=100;
q=linspace(0,8,chance);
chance2=50;
NoiseMargin=linspace(0,5,chance2);
ouyue=0; %表示运行到哪里了
%for loop=1:chance
%u=q(loop);
%for loop2=1:chance2
for i=1:fn
         [NoiseFlag, SpeechFlag, NoiseCounter, Dist]=vad_LogSpec(Y(:,i),N,NoiseCounter,1.804,8);   
         SF(i)=SpeechFlag;
         if SpeechFlag==0
            N=(NoiseLength*N+YS(:,i))/(NoiseLength+1);                               %更新并平滑噪声
            X(:,i)=Beta*YS(:,i);
            Spec=X(:,i).*exp(sqrt(-1)*YPhase(:,i));
            ou(:,i)=real(ifft(Spec,wlen));   
          else
            if   i>=(NN+1) && i<=(fn-NN-2)
                for j=0:(wlen-1)
                bgn_point=(i-NN-1)*inc+1;       %相邻6帧的起始点
                end_point=(i+NN-1)*inc;  
                %fprintf('开始的点是：%d, 结束的点是： %d',bgn_point,end_point);
                seq(j+1)=signal(bgn_point:(end_point-j))'*signal((bgn_point+j):end_point)/(end_point-bgn_point-j+1);
                end;
                Ry=toeplitz(seq);
                [Uy,Ay]=eig(Ry);
                n_var=var(real(ifft(N)));
                [I,J]=find(Ay>n_var);
                M=length(I);
                Ax=zeros(M,M);
                Ux=zeros(wlen,M);
                Ay_seq=zeros(1,wlen);
                A=sort(Ay);
                seq1=A(wlen,:);
                [Ay_seq,IX]=sort(seq1);
                for k=1:M
                    num=wlen-k+1;
                    Ax(k,k)=Ay_seq(num)-n_var;
                    Ux(:,k)=Uy(:,IX(num));
                end;
                Gu=Ax./(Ax+u*n_var);
                ou(:,i)=Ux*Gu*(conj(Ux)')*y(:,i);
             else
                 ou(:,i)=zeros(80,1);
            end
            end
end

sig=zeros((fn-1)*inc+wlen,1);
for i=1:fn
    start=(i-1)*inc+1;    
    spec=ou(:,i);
    sig(start:start+wlen-1)=sig(start:start+wlen-1)+ou(:,i);    
end
toc;
sig=sig-mean(sig);                         % 娑堥櫎鐩存祦鍒嗛噺
sig=sig/max(abs(sig));                      % 骞呭?褰掍竴鍖?

len=min(length(sig),length(x));
x=x(1:len);
sig=sig(1:len);
signal=signal(1:len);
Ps=sum(sum((x-mean(mean(x))).^2));%signal power
Pn=sum(sum((x-sig).^2));           %noise power
snr2=10*log10(Ps/Pn);
disp(snr2);


%%程序有些时候有些枯燥，但是女人不能给我自由。我喜欢一个人静静的写写程序，听听歌。

% 
subplot 311; plot(x,'k'); grid; axis tight;
title(['SNR-Before :  10.1065' ,  '            SNR-after :',num2str(snr2)]);
%subplot 412; plot(signal,'k'); grid; axis tight;
%title(['带噪语音 信噪比=' num2str(SNR) 'dB']); ylabel('幅值')
subplot 312; plot(sig,'k');grid; grid;axis tight;
title('改进子空间语音增强后波形'); %ylabel('幅值'); xlabel('时间/s');
subplot 313; plot(SF,'k');grid; 
title('语音帧检测');