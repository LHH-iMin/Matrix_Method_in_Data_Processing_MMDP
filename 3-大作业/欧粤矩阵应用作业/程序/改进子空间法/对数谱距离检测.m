
clear all; clc; close all;
%load test.mat
IS=0.25;                                % 设置前导无话段长度
wlen=200;                               % 设置帧长为25ms
inc=80;                                 % 求帧移


[filename,pathname]=uigetfile('*.wav','请选择纯净语音文件：');
[xx,fs]=audioread([pathname filename]);
xx=xx-mean(xx);                         % 消除直流分量
x=xx/max(abs(xx));                      % 幅值归一化
N=length(x);                            % 取信号长度
time=(0:N-1)/fs;                        % 设置时间


SNR=[3,5,10,15];
for ouyue=1:4
signal=awgn(x,SNR(ouyue),'measured','db');                % 叠加噪声
wnd=hamming(wlen);                      % 设置窗函数
overlap=wlen-inc;                       % 求重叠区长度
NIS=fix((IS*fs-wlen)/inc +1);           % 求前导无话段帧数
%signal=x;
y=enframe(signal,wnd,inc)';             % 分帧
fn=size(y,2);                           % 求帧数
frameTime=FrameTimeC(fn, wlen, inc, fs);% 计算各帧对应的时间

Y=fft(y);                               % FFT变换
Y=abs(Y(1:fix(wlen/2)+1,:));            % 计算正频率幅值
N=mean(Y(:,1:NIS),2);                   % 计算前导无话段噪声区平均频谱
NoiseCounter=0;

qq=linspace(0,8,500);
for z=1:500
for i=1:fn, 
    if i<=NIS                           % 在前导无话段中设置为NF=1,SF=0
        SpeechFlag=0;
        NoiseCounter=100;
        SF2(i,z)=0;
    else                                % 检测每帧计算对数频谱距离
        [NoiseFlag, SpeechFlag, NoiseCounter, Dist]=vad_LogSpec(Y(:,i),N,NoiseCounter,qq(z),8);   
        SF2(i,z,ouyue)=SpeechFlag;
        D(i)=Dist;
    end
end
end
end
fprintf('这是第%d轮循环',ouyue);

SF=SF';
for j=1:4
for i=1:500
     signal5(i,j)=sum(SF2(:,i,j)==SF)/length(SF);
end
end
figure;
plot(qq,signal5(:,1))
hold on;
plot(qq,signal5(:,2))
hold on;
plot(qq,signal5(:,3))
hold on;
plot(qq,signal5(:,4))
hold on;



% sindex=find(SF2==1);                     % 从SF中寻找出端点的参数完成端点检测
% plot(SF2);
% voiceseg=findSegment(sindex);
% vosl=length(voiceseg);
% % 作图
% subplot 211; 
% plot(time,x,'k'); 
% title('纯语音波形');
% ylabel('幅值'); ylim([-1 1]);
% subplot 212; plot(time,signal,'k');
% title(['带噪语音 SNR=' num2str(SNR) '(dB)'])
% ylabel('幅值'); ylim([-1.2 1.2]);
% % subplot 313; plot(frameTime,D,'k'); 
% % xlabel('时间/s'); ylabel('幅值'); 
% % title('对数频谱距离'); ylim([0 max(D)]);
% 
% for k=1 : vosl                           % 标出语音端点
%     nx1=voiceseg(k).begin; nx2=voiceseg(k).end;
%     fprintf('%4d   %4d   %4d\n',k,nx1,nx2);
%     subplot 212
%     line([frameTime(nx1) frameTime(nx1)],[-1 1],'color','r','linestyle','-');
%     line([frameTime(nx2) frameTime(nx2)],[-1 1],'color','b','linestyle','--');
% %     subplot 313
% %     line([frameTime(nx1) frameTime(nx1)],[0 max(D)],'color','r','linestyle','-');
% %     line([frameTime(nx2) frameTime(nx2)],[0 max(D)],'color','b','linestyle','--');
% end
