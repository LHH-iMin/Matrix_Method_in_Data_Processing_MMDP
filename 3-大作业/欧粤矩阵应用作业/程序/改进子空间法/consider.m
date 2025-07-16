
%[filename,pathname]=uigetfile('*.wav','��ѡ�񴿾������ļ���');

function snrrr=consider(ouyueyue,SNR)

IS=0.25;                                % ����ǰ���޻��γ���
wlen=80;                               % ����֡��Ϊ25ms
inc=40;                                 % ��֡��
SNR=SNR;                                 % ���������
[tidy,fs]=audioread('C:\Users\UCAS_BigBird\Desktop\ouyue1zuihou\������.wav');
%[wavin,fs]=audioread('C:\Users\UCAS_BigBird\Desktop\ouyue1zuihou\SeeYouOnly-8db.wav');
%x=xx;
%[filename,pathname]=uigetfile('*.wav','请�?择纯�?��音文件：');
%[tidy,fs]=audioread([pathname filename]);
%[filename,pathname]=uigetfile('*.wav','请�?择带噪语音文件：');
%[wavin,fs]=audioread([pathname filename]);



x=tidy(:,1)-mean(tidy(:,1));                         % 消除直流分量
x=tidy/max(abs(tidy));                      % 幅�?归一�?
% signal=wavin(:,1)-mean(wavin(:,1));                         % 消除直流分量
% signal=signal/max(abs(signal));      




N=length(x);                            % ȡ�źų���
time=(0:N-1)/fs;                        % ����ʱ��
signal=awgn(x,SNR,'measured','db');                % ��������
wnd=hamming(wlen);                      % ���ô�����
overlap=wlen-inc;                       % ���ص�������
NIS=fix((IS*fs-wlen)/inc +1);           % ��ǰ���޻���֡��
y=enframe(signal,wnd,inc)' ;          % ��֡
disp(size(y));
fn=size(y,2);                           % ��֡��

n_var=var(signal(1:2000),1);  %ȡǰ3000���������ڹ�����������
Y=fft(y,wlen);                               % FFT�任
YPhase=angle(Y(1:fix(wlen/2)+1,:));          %������������λ
Y=abs(Y(1:fix(wlen/2)+1,:));            % ������Ƶ�ʷ�ֵ

N=mean(Y(:,1:NIS),2);                   % ����ǰ���޻���������ƽ��Ƶ��
NoiseCounter=100;
NoiseLength=9;
Beta=0.03;
NN=2;
u=3;

Ry=zeros(wlen,wlen);          %����֡�źŵ�ToeplitzЭ�������
seq=zeros(1,wlen);


YS=Y;                                               %ƽ����ֵ
for i=2:(fn-1)
    YS(:,i)=(Y(:,i-1)+Y(:,i)+Y(:,i+1))/3;
end

% chance=100;
% q=logspace(-2,1.4,chance);
% chance2=5;
% NoiseMargin=linspace(1,5,chance2);
% ouyue=0; %��ʾ���е�������



% for loop=1:chance
% u=q(loop);
% for loop2=1:chance2
for i=1:fn
         [NoiseFlag, SpeechFlag, NoiseCounter, Dist]=vad_LogSpec(Y(:,i),N,NoiseCounter,ouyueyue(1),8);   
         SF(i)=SpeechFlag;
         if SpeechFlag==0
            N=(NoiseLength*N+YS(:,i))/(NoiseLength+1);                               %���²�ƽ������
            X(:,i)=Beta*YS(:,i);
            Spec=X(:,i).*exp(sqrt(-1)*YPhase(:,i));
            ou(:,i)=real(ifft(Spec,wlen));   
          else
            if   i>=(NN+1) && i<=(fn-NN-2)
                for j=0:(wlen-1)
                bgn_point=(i-NN-1)*inc+1;       %����6֡����ʼ��
                end_point=(i+NN-1)*inc;  
                %fprintf('��ʼ�ĵ��ǣ�%d, �����ĵ��ǣ� %d',bgn_point,end_point);
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

sig=sig-mean(sig);                         % 消除直流分量
sig=sig/max(abs(sig));                      % 幅�?归一�?

len=min(length(sig),length(x));
x=x(1:len);
sig=sig(1:len);
signal=signal(1:len);

Ps=sum(sum((x-mean(mean(x))).^2));%signal power
Pn=sum(sum((x-sig).^2));           %noise power
snrrr=-10*log10(Ps/Pn);
end

% ouyue=ouyue+1;
% fprintf('���ǵ�%d�ε�������\n',ouyue);
% end