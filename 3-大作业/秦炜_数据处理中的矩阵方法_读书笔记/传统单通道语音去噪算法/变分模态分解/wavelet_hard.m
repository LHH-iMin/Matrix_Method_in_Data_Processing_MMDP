%--------------小波变换-------------------%
function [y_rec] = wavelet_hard(data,layer,wname)
% wavelet_hard(modes(1,:),noise_std,3,'db6')

[C,L] = wavedec(data,layer,wname);

%对含噪声源进行离散小波分解，并提取高低频系数
a3 = appcoef(C,L,wname,layer);
d3 = detcoef(C,L,3);
d2 = detcoef(C,L,2);
d1 = detcoef(C,L,1);


%进行硬阈值处理
ythard1 = wthresh(d1,'h', sqrt(abs(median(d1)/0.6745)) * sqrt(2*log(length(d1))/log(1+1)));
% u = 1./((ythard1-noise_std/log(1+1)).^2+1);
% ythard1 = sign(ythard1) .* (abs(ythard1)-u*noise_std/log(1+1));
% ythard1 = real(ythard1);

ythard2 = wthresh(d2,'h', sqrt(abs(median(d2)/0.6745)) * sqrt(2*log(length(d2))/log(2+1)));
% u = 1./((ythard2-noise_std/log(2+1)).^2+1);
% ythard2 = sign(ythard2) .* (abs(ythard2)-u*noise_std/log(2+1));
% ythard2 = real(ythard2);

ythard3 = wthresh(d3,'h', sqrt(abs(median(d3)/0.6745)) * sqrt(2*log(length(d3))/log(3+1)));
% u = 1./((ythard3-noise_std/log(3+1)).^2+1);
% ythard3 = sign(ythard3) .* (abs(ythard3)-u*noise_std/log(3+1));
% ythard3 = real(ythard3);

%重构信号
C2 = [a3,ythard3,ythard2,ythard1];
y_rec = waverec(C2,L,wname);

% figure;
% subplot(2,1,1),plot(data);
% title('原始信号波形');
% subplot(2,1,2),plot(y_rec);
% title('去噪波形');
% 
% figure;
% plot(y_rec);