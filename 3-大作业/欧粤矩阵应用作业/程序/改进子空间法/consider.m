
%[filename,pathname]=uigetfile('*.wav','请选择纯净语音文件：');

function snrrr=consider(ouyueyue,SNR)

IS=0.25;                                % 设置前导无话段长度
wlen=80;                               % 设置帧长为25ms
inc=40;                                 % 求帧移
SNR=SNR;                                 % 设置信噪比
[tidy,fs]=audioread('C:\Users\UCAS_BigBird\Desktop\ouyue1zuihou\语音四.wav');
%[wavin,fs]=audioread('C:\Users\UCAS_BigBird\Desktop\ouyue1zuihou\SeeYouOnly-8db.wav');
%x=xx;
%[filename,pathname]=uigetfile('*.wav','璇烽?鎷╃函鍑?闊虫枃浠讹細');
%[tidy,fs]=audioread([pathname filename]);
%[filename,pathname]=uigetfile('*.wav','璇烽?鎷╁甫鍣闊虫枃浠讹細');
%[wavin,fs]=audioread([pathname filename]);



x=tidy(:,1)-mean(tidy(:,1));                         % 娑堥櫎鐩存祦鍒嗛噺
x=tidy/max(abs(tidy));                      % 骞呭?褰掍竴鍖?
% signal=wavin(:,1)-mean(wavin(:,1));                         % 娑堥櫎鐩存祦鍒嗛噺
% signal=signal/max(abs(signal));      




N=length(x);                            % 取信号长度
time=(0:N-1)/fs;                        % 设置时间
signal=awgn(x,SNR,'measured','db');                % 叠加噪声
wnd=hamming(wlen);                      % 设置窗函数
overlap=wlen-inc;                       % 求重叠区长度
NIS=fix((IS*fs-wlen)/inc +1);           % 求前导无话段帧数
y=enframe(signal,wnd,inc)' ;          % 分帧
disp(size(y));
fn=size(y,2);                           % 求帧数

n_var=var(signal(1:2000),1);  %取前3000采样点用于估计噪声方差
Y=fft(y,wlen);                               % FFT变换
YPhase=angle(Y(1:fix(wlen/2)+1,:));          %含噪语音的相位
Y=abs(Y(1:fix(wlen/2)+1,:));            % 计算正频率幅值

N=mean(Y(:,1:NIS),2);                   % 计算前导无话段噪声区平均频谱
NoiseCounter=100;
NoiseLength=9;
Beta=0.03;
NN=2;
u=3;

Ry=zeros(wlen,wlen);          %定义帧信号的Toeplitz协方差矩阵
seq=zeros(1,wlen);


YS=Y;                                               %平均谱值
for i=2:(fn-1)
    YS(:,i)=(Y(:,i-1)+Y(:,i)+Y(:,i+1))/3;
end

% chance=100;
% q=logspace(-2,1.4,chance);
% chance2=5;
% NoiseMargin=linspace(1,5,chance2);
% ouyue=0; %表示运行到哪里了



% for loop=1:chance
% u=q(loop);
% for loop2=1:chance2
for i=1:fn
         [NoiseFlag, SpeechFlag, NoiseCounter, Dist]=vad_LogSpec(Y(:,i),N,NoiseCounter,ouyueyue(1),8);   
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
                Gu=Ax./(Ax+ouyueyue(2)*n_var);
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

sig=sig-mean(sig);                         % 娑堥櫎鐩存祦鍒嗛噺
sig=sig/max(abs(sig));                      % 骞呭?褰掍竴鍖?

len=min(length(sig),length(x));
x=x(1:len);
sig=sig(1:len);
signal=signal(1:len);

Ps=sum(sum((x-mean(mean(x))).^2));%signal power
Pn=sum(sum((x-sig).^2));           %noise power
snrrr=-10*log10(Ps/Pn);
end

% ouyue=ouyue+1;
% fprintf('这是第%d次迭代过程\n',ouyue);
% end