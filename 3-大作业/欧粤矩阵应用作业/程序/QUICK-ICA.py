import matplotlib.pyplot as plt  
import numpy as np
from numpy import linalg as LA
 
C=200 #样本数
x=np.arange(C)
s1=2*np.sin(0.02*np.pi *x)#正弦信号
 
a=np.linspace(-2,2,25)
s2= np.array([a,a,a,a,a,a,a,a]).reshape(200,)#锯齿信号
s3=np.array(20*(5*[2]+5*[-2]))  #方波信号 
s4 =4*(np.random.random([1,C])-0.5).reshape(200,) #随机信号
 
# drow origin signal 
ax1 = plt.subplot(411)
ax2 = plt.subplot(412)
ax3 = plt.subplot(413)
ax4 = plt.subplot(414)
ax1.plot(x,s1)
ax2.plot(x,s2)
ax3.plot(x,s3)
ax4.plot(x,s4)
plt.show()
 
s=np.array([s1,s2,s3,s4])  #合成信号
ran=2*np.random.random([4,4])  #随机矩阵
mix=ran.dot(s) #混合信号
# drow mix signal 
ax1 = plt.subplot(411)
ax2 = plt.subplot(412)
ax3 = plt.subplot(413)
ax4 = plt.subplot(414)
ax1.plot(x,mix.T[:,0])
ax2.plot(x,mix.T[:,1])
ax3.plot(x,mix.T[:,2])
ax4.plot(x,mix.T[:,3])
plt.show()
 
#mix=np.array([[1.1,2,3,4,1],
   # [5,6,2,8,7],
  #  [6,2,5,1,3],
   # [7,8,3,3,2]])
 
Maxcount=10000  #  %最大迭代次数  
Critical=0.00001  #  %判断是否收敛
R,C=mix.shape
 
average=np.mean(mix, axis=1) #计算行均值，axis=0，计算每一列的均值
 
for i in range(R):
    mix[i,:]=mix[i,:]- average[i] #数据标准化，均值为零
Cx=np.cov(mix)  
value,eigvector = np.linalg.eig(Cx)#计算协方差阵的特征值
val=value**(-1/2)*np.eye(R, dtype=float) 
White=np.dot(val ,eigvector.T)  #白化矩阵
 
Z=np.dot(White,mix) #混合矩阵的主成分Z，Z为正交阵
 
 
#W = np.random.random((R,R))# 4x4
W=0.5*np.ones([4,4])#初始化权重矩阵
 
for n in range(R):
    count=0    
    WP=W[:,n].reshape(R,1) #初始化
    LastWP=np.zeros(R).reshape(R,1) # 列向量;LastWP=zeros(m,1); 
    while LA.norm(WP-LastWP,1)>Critical:
        #print(count," loop :",LA.norm(WP-LastWP,1))
        count=count+1
        LastWP=np.copy(WP)    #  %上次迭代的值  
        gx=np.tanh(LastWP.T.dot(Z))  # 行向量
 
        for i in range(R):  
            tm1=np.mean( Z[i,:]*gx ) 
            #tm2=np.mean(1-gx**2)*LastWP[i] #收敛快
            tm2=np.mean(gx)*LastWP[i]     #收敛慢
            WP[i]=tm1 - tm2
        #print(" wp :", WP.T ) 
        WPP=np.zeros(R) #一维0向量
        for j in range(n):  
            WPP=WPP+  WP.T.dot(W[:,j])* W[:,j] 
        WP.shape=1,R
        WP=WP-WPP
        WP.shape=R,1
        WP=WP/(LA.norm(WP))
        if(count ==Maxcount):
            print("reach Maxcount，exit loop",LA.norm(WP-LastWP,1))
            break
    print("loop count:",count )
    W[:,n]=WP.reshape(R,)
SZ=W.T.dot(Z)
 
# plot extract signal
x=np.arange(0,C)
ax1 = plt.subplot(411)
ax2 = plt.subplot(412)
ax3 = plt.subplot(413)
ax4 = plt.subplot(414)
ax1.plot(x, SZ.T[:,0])
ax2.plot(x, SZ.T[:,1])
ax3.plot(x, SZ.T[:,2])
ax4.plot(x, SZ.T[:,3])
plt.show()