function gd = chuliyuzhi(a,b)%aΪ�źŷֽ���С��ϵ����bΪ��õ���ֵ
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
