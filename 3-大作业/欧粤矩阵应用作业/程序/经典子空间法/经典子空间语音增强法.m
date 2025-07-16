%基于Ephraim和Van Trees提出的信号子空间法(TDC)的语音增强程序，适用于噪声为白噪声的情况
%在经典版本中噪声空间恒定，u也是恒定
%下方加了两个for循环，目的是为了找出不同初始信噪比下，u和最终输出结果的关系

clear all;
%--------------------------------参数定义----------------------------------
frame_len=80;              %帧长
step_len=0.5*frame_len;    %分帧时的步长，相当于重叠50%
N=2;                       %计算Toeplitz协方差矩阵时用到的前后相邻的帧数,N为偶数
v=0.05;                    %噪声抑制系数，推荐v=2或3;
u=4;
%-------------------------------读入带噪语音文件----------------------------
[filename,pathname]=uigetfile('*.wav','请选择纯净语音文件：');
[tidy,fs]=audioread([pathname filename]);
SNR=[3,5,8,10];
for ouyueyue=1:4
ouyue=awgn(tidy,SNR(ouyueyue),'measured','db');                % 叠加噪声
wavin=ouyue;
wav_length=length(wavin);
R = step_len;
L = frame_len; 
f = (wav_length-mod(wav_length,frame_len))/frame_len;
k = 2*f-1;                          % 帧数        
frame_num=k;
for r = 1:k 
    y = wavin(1+(r-1)*R:L+(r-1)*R); % 对带噪语音帧间重叠一半取值；
    out(1+(r-1)*L:r*L) = y(1:L).*hamming(frame_len);    % 得到一个新帧数的序列
end
inframe=reshape(out,frame_len,k);   % 改变序列的形状
n_var=var(wavin(1:2000),1);  %取前3000采样点用于估计噪声方差
xv=n_var;                    %定义Rx的特征值判别阈值
Ry=zeros(frame_len,frame_len);          %定义帧信号的Toeplitz协方差矩阵
seq=zeros(1,frame_len);                 %定义相邻6帧的自相关序列，长度等于帧长
L=N*frame_len;                          %定义相邻N帧的长度
outframe=zeros(frame_len,frame_num);    %定义增强后的矩阵
u=logspace(-2,1.4,100);
for sss =1:100
    %%%下面是完整的一次
for i=(N+1):(frame_num-N-2)
    for j=0:(frame_len-1)
        bgn_point=(i-N-1)*step_len+1;       %相邻6帧的起始点
        end_point=(i+N-1)*step_len;         %相邻6帧的终点
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
fprintf('这是第%d次',sss+ouyueyue);
 %%%上面是完整的一次
end
 
end

%%下面的是老版本用来绘图的，但是我这里为的是for循环判断，所以不需要绘制出输出结果。
%%我也有喜欢的人，但是我觉得程序比她有意思多了。

%-----------------------信噪比--------------------------------------------
%SNR_before=SNR1(tidy,wavin);
%SNR_after=SNR2(tidy,wavout);
%wavwrite(wavout,fs,nbits,['EVT_' num2str(frame_len) '_' num2str(N) '_51u_' filename]);
%-----------------------将处理前后的结果进行作图比较-------------------------
% figure(1);
% subplot(3,1,1);plot(tidy);xlabel('(a)原始语音（采样点数）');ylabel('幅度');
% subplot(3,1,2);plot(wavin);xlabel('(b)带噪语音(5dB白噪声)（采样点数）');ylabel('幅度');
% %subplot(4,1,3);plot(ouyue);xlabel('自己仿制的带噪语音(5dB白噪声)（采样点数）');ylabel('幅度');
% subplot(3,1,3);plot(wavout);xlabel('(c)子空间法增强语音-TDC（采样点数）');ylabel('幅度');
