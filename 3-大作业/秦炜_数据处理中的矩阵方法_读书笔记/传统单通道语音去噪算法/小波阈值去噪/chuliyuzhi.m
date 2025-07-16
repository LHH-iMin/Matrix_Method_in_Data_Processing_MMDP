function gd = chuliyuzhi(a,b)%a为信号分解后的小波系数，b为获得的阈值
m=length(a);
h=0.5*b;
for i=1:m
if (abs(a(i))>=b)
    n(i)=10*(a(i).*a(i)-0.9801*b*b);
    gd(i)=sign(a(i))*(abs(a(i))-0.99*b/exp(n(i)));
elseif(abs(a(i))>=h)
    gd(i)=0.01*(a(i)-h);
else gd(i)=0;
end
end
