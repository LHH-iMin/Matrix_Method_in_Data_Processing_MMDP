%����Ephraim��Van Trees������ź��ӿռ䷨(TDC)��������ǿ��������������Ϊ�����������
%�ھ���汾�������ռ�㶨��uҲ�Ǻ㶨
%�·���������forѭ����Ŀ����Ϊ���ҳ���ͬ��ʼ������£�u�������������Ĺ�ϵ

clear all;
%--------------------------------��������----------------------------------
frame_len=80;              %֡��
step_len=0.5*frame_len;    %��֡ʱ�Ĳ������൱���ص�50%
N=2;                       %����ToeplitzЭ�������ʱ�õ���ǰ�����ڵ�֡��,NΪż��
v=0.05;                    %��������ϵ�����Ƽ�v=2��3;
u=4;
%-------------------------------������������ļ�----------------------------
[filename,pathname]=uigetfile('*.wav','��ѡ�񴿾������ļ���');
[tidy,fs]=audioread([pathname filename]);
SNR=[3,5,8,10];
for ouyueyue=1:4
ouyue=awgn(tidy,SNR(ouyueyue),'measured','db');                % ��������
wavin=ouyue;
wav_length=length(wavin);
R = step_len;
L = frame_len; 
f = (wav_length-mod(wav_length,frame_len))/frame_len;
k = 2*f-1;                          % ֡��        
frame_num=k;
for r = 1:k 
    y = wavin(1+(r-1)*R:L+(r-1)*R); % �Դ�������֡���ص�һ��ȡֵ��
    out(1+(r-1)*L:r*L) = y(1:L).*hamming(frame_len);    % �õ�һ����֡��������
end
inframe=reshape(out,frame_len,k);   % �ı����е���״
n_var=var(wavin(1:2000),1);  %ȡǰ3000���������ڹ�����������
xv=n_var;                    %����Rx������ֵ�б���ֵ
Ry=zeros(frame_len,frame_len);          %����֡�źŵ�ToeplitzЭ�������
seq=zeros(1,frame_len);                 %��������6֡����������У����ȵ���֡��
L=N*frame_len;                          %��������N֡�ĳ���
outframe=zeros(frame_len,frame_num);    %������ǿ��ľ���
u=logspace(-2,1.4,100);
for sss =1:100
    %%%������������һ��
for i=(N+1):(frame_num-N-2)
    for j=0:(frame_len-1)
        bgn_point=(i-N-1)*step_len+1;       %����6֡����ʼ��
        end_point=(i+N-1)*step_len;         %����6֡���յ�
        seq(j+1)=wavin(bgn_point:(end_point-j))'*...
                 wavin((bgn_point+j):end_point)/(end_point-bgn_point-j+1);
    end;
    Ry=toeplitz(seq);
    [Uy,Ay]=eig(Ry);% [Uy,Ay]=eig(Ry,'nobalance');
    [I,J]=find(Ay>xv);
    M=length(I);
    Ax=zeros(M,M);
    Ux=zeros(frame_len,M);
    Ay_seq=zeros(1,frame_len);
    A=sort(Ay);        
    seq1=A(frame_len,:);
    [Ay_seq,IX]=sort(seq1);
     for k=1:M
        num=frame_len-k+1;
        Ax(k,k)=Ay_seq(num)-xv;
        Ux(:,k)=Uy(:,IX(num));
    end;
    Gu=Ax./(Ax+u(sss)*n_var);
    outframe(:,i)=Ux*Gu*(conj(Ux)')*inframe(:,i);
end;
wavout=zeros(1,(frame_num-1)*step_len+frame_len);
for t=1:frame_num
    num1=(t-1)*step_len+1;
    num2=(t+1)*step_len;
    wavout(num1:num2)=wavout(num1:num2)+(outframe(:,t))';
end;
wavout=wavout';
len=min(length(wavout),length(tidy));
tidy=tidy(1:len);
wavout=wavout(1:len);
wavin=wavin(1:len);
Ps=sum(sum((tidy-mean(mean(tidy))).^2));%signal power
Pn=sum(sum((tidy-wavout).^2));           %noise power
snr(sss,ouyueyue)=10*log10(Ps/Pn);
fprintf('���ǵ�%d��',sss+ouyueyue);
 %%%������������һ��
end
 
end

%%��������ϰ汾������ͼ�ģ�����������Ϊ����forѭ���жϣ����Բ���Ҫ���Ƴ���������
%%��Ҳ��ϲ�����ˣ������Ҿ��ó����������˼���ˡ�

%-----------------------�����--------------------------------------------
%SNR_before=SNR1(tidy,wavin);
%SNR_after=SNR2(tidy,wavout);
%wavwrite(wavout,fs,nbits,['EVT_' num2str(frame_len) '_' num2str(N) '_51u_' filename]);
%-----------------------������ǰ��Ľ��������ͼ�Ƚ�-------------------------
% figure(1);
% subplot(3,1,1);plot(tidy);xlabel('(a)ԭʼ����������������');ylabel('����');
% subplot(3,1,2);plot(wavin);xlabel('(b)��������(5dB������)������������');ylabel('����');
% %subplot(4,1,3);plot(ouyue);xlabel('�Լ����ƵĴ�������(5dB������)������������');ylabel('����');
% subplot(3,1,3);plot(wavout);xlabel('(c)�ӿռ䷨��ǿ����-TDC������������');ylabel('����');
