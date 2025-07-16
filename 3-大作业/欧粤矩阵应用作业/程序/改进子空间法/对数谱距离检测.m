
clear all; clc; close all;
%load test.mat
IS=0.25;                                % ����ǰ���޻��γ���
wlen=200;                               % ����֡��Ϊ25ms
inc=80;                                 % ��֡��


[filename,pathname]=uigetfile('*.wav','��ѡ�񴿾������ļ���');
[xx,fs]=audioread([pathname filename]);
xx=xx-mean(xx);                         % ����ֱ������
x=xx/max(abs(xx));                      % ��ֵ��һ��
N=length(x);                            % ȡ�źų���
time=(0:N-1)/fs;                        % ����ʱ��


SNR=[3,5,10,15];
for ouyue=1:4
signal=awgn(x,SNR(ouyue),'measured','db');                % ��������
wnd=hamming(wlen);                      % ���ô�����
overlap=wlen-inc;                       % ���ص�������
NIS=fix((IS*fs-wlen)/inc +1);           % ��ǰ���޻���֡��
%signal=x;
y=enframe(signal,wnd,inc)';             % ��֡
fn=size(y,2);                           % ��֡��
frameTime=FrameTimeC(fn, wlen, inc, fs);% �����֡��Ӧ��ʱ��

Y=fft(y);                               % FFT�任
Y=abs(Y(1:fix(wlen/2)+1,:));            % ������Ƶ�ʷ�ֵ
N=mean(Y(:,1:NIS),2);                   % ����ǰ���޻���������ƽ��Ƶ��
NoiseCounter=0;

qq=linspace(0,8,500);
for z=1:500
for i=1:fn, 
    if i<=NIS                           % ��ǰ���޻���������ΪNF=1,SF=0
        SpeechFlag=0;
        NoiseCounter=100;
        SF2(i,z)=0;
    else                                % ���ÿ֡�������Ƶ�׾���
        [NoiseFlag, SpeechFlag, NoiseCounter, Dist]=vad_LogSpec(Y(:,i),N,NoiseCounter,qq(z),8);   
        SF2(i,z,ouyue)=SpeechFlag;
        D(i)=Dist;
    end
end
end
end
fprintf('���ǵ�%d��ѭ��',ouyue);

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



% sindex=find(SF2==1);                     % ��SF��Ѱ�ҳ��˵�Ĳ�����ɶ˵���
% plot(SF2);
% voiceseg=findSegment(sindex);
% vosl=length(voiceseg);
% % ��ͼ
% subplot 211; 
% plot(time,x,'k'); 
% title('����������');
% ylabel('��ֵ'); ylim([-1 1]);
% subplot 212; plot(time,signal,'k');
% title(['�������� SNR=' num2str(SNR) '(dB)'])
% ylabel('��ֵ'); ylim([-1.2 1.2]);
% % subplot 313; plot(frameTime,D,'k'); 
% % xlabel('ʱ��/s'); ylabel('��ֵ'); 
% % title('����Ƶ�׾���'); ylim([0 max(D)]);
% 
% for k=1 : vosl                           % ��������˵�
%     nx1=voiceseg(k).begin; nx2=voiceseg(k).end;
%     fprintf('%4d   %4d   %4d\n',k,nx1,nx2);
%     subplot 212
%     line([frameTime(nx1) frameTime(nx1)],[-1 1],'color','r','linestyle','-');
%     line([frameTime(nx2) frameTime(nx2)],[-1 1],'color','b','linestyle','--');
% %     subplot 313
% %     line([frameTime(nx1) frameTime(nx1)],[0 max(D)],'color','r','linestyle','-');
% %     line([frameTime(nx2) frameTime(nx2)],[0 max(D)],'color','b','linestyle','--');
% end
