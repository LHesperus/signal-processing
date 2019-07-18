% 仿真4比特原始数据与星座图的编码映射过程；
% 完成16QAM信号的调制解调；
% 基带信号符号速率 ps ＝1Mbps；
% 成形滤波器的滚降因子 a=0.8；
% 载波信号频率fc=2MHz ；
% 采样频率 Fs=8MHz ；
% 绘制16QAM信号的频谱及时域波形；
% 采用相干解调法仿真其解调过程；
% 绘制解调前后的基带信号时域波形；
% 将原始基带数据、QAM已调数据、滤波器系数写入相应的文本文件中。
clc;
clear
close all;
 
ps=1*10^6;   %码速率为1MHz
a=0.8;       %成形滤波器系数
Fs=8*10^6;   %采样速率
fc=2*10^6;   %载波频率
N=4000;      %仿真数据的长度
 
t=0:1/Fs:(N*Fs/ps-1)/Fs;%产生长度为N,频率为fs的时间序列
s=randi([0,16],1,N);       %产生随机16进制数据作为原始数据
Bs=dec2bin(s,4);         %将十进制数据转换成4比特的二进制数据
 
%对Bs的高2比特进行差分编码
%取高2比特分别存放在A，B变量中
A=s>7;
B=(s-A*8)>3;
%差分编码后的数据存放在C，D中
C=zeros(N,1);D=zeros(N,1);
for i=2:N
    C(i)=mod(((~mod(A(i)+B(i),2))&mod(A(i)+C(i-1),2)) + (mod(A(i)+B(i),2)&mod(A(i)+D(i-1),2)),2);
    D(i)=mod(((~mod(A(i)+B(i),2))&mod(B(i)+D(i-1),2)) + (mod(A(i)+B(i),2)&mod(B(i)+C(i-1),2)),2);
end
%差分编码后的高2比特数据与原数据低2比特合成映射前的数据DBs
DBs=C*8+D*4+s-A*8-B*4;
 
 
%完成调制前的正交同相支路数据映射
I=zeros(1,N);Q=zeros(1,N);
for i=1:N
    switch DBs(i)
        case 0, I(i)=3; Q(i)=3;
        case 1, I(i)=1; Q(i)=3;
        case 2, I(i)=3; Q(i)=1;
        case 3, I(i)=1; Q(i)=1;
        case 4, I(i)=-3;Q(i)=3;
        case 5, I(i)=-3;Q(i)=1;
        case 6, I(i)=-1;Q(i)=3;
        case 7, I(i)=-1;Q(i)=1;
        case 8, I(i)=3; Q(i)=-3;
        case 9, I(i)=3; Q(i)=-1;
        case 10,I(i)=1; Q(i)=-3;
        case 11,I(i)=1; Q(i)=-1;
        case 12,I(i)=-3;Q(i)=-3;
        case 13,I(i)=-1;Q(i)=-3;
        case 14,I(i)=-3;Q(i)=-1;
        otherwise,I(i)=-1;Q(i)=-1;
    end
end
 
%对编码数据以Fs频率采样
Ads_i=upsample(I,Fs/ps);
Ads_q=upsample(Q,Fs/ps);
 
%加噪声
% SNR=30;
% Ads_i=awgn(Ads_i,SNR);
% Ads_q=awgn(Ads_q,SNR);
  
%设计平方根升余弦滤波器
n_T=[-2 2];
rate=Fs/ps;
T=1;
Shape_b = rcosfir(a,n_T,rate,T,'sqrt');
%对采样后的数据进行升余弦滤波;
rcos_Ads_i=filter(Shape_b,1,Ads_i);
rcos_Ads_q=filter(Shape_b,1,Ads_q);
figure;plot(rcos_Ads_i+rcos_Ads_q*j,'x') 
%产生同相正交两路载频信号
f0_i=cos(2*pi*fc*t);
f0_q=sin(2*pi*fc*t);      
  
%产生16QAM已调信号
qam16=rcos_Ads_i.*f0_i+rcos_Ads_q.*f0_q;      
figure;
plot(qam16);
srdata = rcos_Ads_i + rcos_Ads_q * 1i;
scatterplot(srdata(length(srdata)*0.9:2:length(srdata)));
 
 
 
%%%%%　仿真输入测试的PSK基带数据　%%%
bitstream=randi([0,1],1,N);             
psk2=pskmod(bitstream,2);
Ns=8*N;
xI=zeros(1,Ns);
xQ=zeros(1,Ns);
xI(1:8:8*N)=real(psk2);%8倍插值
xQ(1:8:8*N)=imag(psk2);
%截短后的根升余弦匹配滤波器
h1=rcosfir(0.8,[-8,8],4,1,'sqrt');
hw=kaiser(65,3.97);
%hh=h1.*hw.';
hh=h1;
aI1=conv(xI,hh);
bQ1=conv(xQ,hh);
L=length(aI1);
%仿真输入数据
% aI=[aI1(22:2:L),0,0];%2倍抽取
% bQ=[bQ1(22:2:L),0,0];
%
% scatterplot(psk2(length(psk2)*0.5:length(psk2)));
 
aI=real(srdata(202:2:length(srdata)));%2倍抽取？为何先8倍插值，再2倍抽取？
bQ=imag(srdata(202:2:length(srdata)));
ma=max(abs(aI));mb=max(abs(bQ));
m=max(ma,mb);
aI=aI/m;bQ=bQ/m;
%
N=floor(length(aI)/4);
Ns=4*N;  %总的采样点数
 
bt=0.001;
c2=2^(-14);
c1=2^(-6);
% c1=8/3*bt;
% c2=32/9*bt*bt;
i=3;    %用来表示Ts的时间序号,指示n,n_temp,nco,
 
w=[0.5,zeros(1,N-1)];  %环路滤波器输出寄存器，初值设为0.5
n=[0.7 zeros(1,Ns-1)]; %NCO寄存器，初值设为0.9
n_temp=[n(1),zeros(1,Ns-1)];
u=[0.6,zeros(1,2*N-1)];%NCO输出的定时分数间隔寄存器，初值设为0.6
yI=zeros(1,2*N);       %I路内插后的输出数据
yQ=zeros(1,2*N);       %Q路内插后的输出数据
time_error=zeros(1,N); %Gardner提取的时钟误差寄存器
 
ik=time_error;
qk=time_error;
 
k=1;    %用来表示Ti时间序号,指示u,yI,yQ
ms=1;   %用来指示T的时间序号,用来指示a,b以及w
strobe=zeros(1,Ns);
 
ns=length(aI)-2;
while(i<ns)
    n_temp(i+1)=n(i)-w(ms);
%      n_temp(i+1)=n(i)-0.5;
    if(n_temp(i+1)>0)
        n(i+1)=n_temp(i+1);
    else
        n(i+1)=mod(n_temp(i+1),1);
        %内插滤波器模块
        FI1=0.5*aI(i+2)-0.5*aI(i+1)-0.5*aI(i)+0.5*aI(i-1);
        FI2=1.5*aI(i+1)-0.5*aI(i+2)-0.5*aI(i)-0.5*aI(i-1);
        FI3=aI(i);
        yI(k)=(FI1*u(k)+FI2)*u(k)+FI3;
        FQ1=0.5*bQ(i+2)-0.5*bQ(i+1)-0.5*bQ(i)+0.5*bQ(i-1);
        FQ2=1.5*bQ(i+1)-0.5*bQ(i+2)-0.5*bQ(i)-0.5*bQ(i-1);
        FQ3=bQ(i);
        yQ(k)=(FQ1*u(k)+FQ2)*u(k)+FQ3;
        strobe(k)=mod(k,2);
        %时钟误差提取模块，采用的是Gardner算法
        if(strobe(k)==0)
            %取出插值数据
            ik(ms)=yI(k);
            qk(ms)=yQ(k);
             
            %每个数据符号计算一次时钟误差
            if(k>2)
               Ia=(yI(k)+yI(k-2))/2;
               Qa=(yQ(k)+yQ(k-2))/2;
               time_error(ms)=[yI(k-1)-Ia ]  *(yI(k)-yI(k-2))+[yQ(k-1)-Qa]  *(yQ(k)-yQ(k-2));
            else
                time_error(ms)=(yI(k-1)*yI(k)+yQ(k-1)*yQ(k));
            end
            %环路滤波器,每个数据符号计算一次环路滤波器输出
            if(ms>1)
                w(ms+1)=w(ms)+c1*(time_error(ms)-time_error(ms-1))+c2*time_error(ms-1);
                %w(ms+1)=w(ms)+c1*(time_error(ms)-time_error(ms-1));
            else
                w(ms+1)=w(ms)+c1*time_error(ms)+c2*time_error(ms);
            end
            ms=ms+1;
        end
          k=k+1;
%         u(k)=n(i)/w(ms);
          u(k) = 0.5* n(i);%%近视运算
    end
    i=i+1;
end
%
figure;
subplot(311);plot(u);xlabel('运算点数');ylabel('分数间隔');
subplot(312);plot(time_error);xlabel('运算点数');ylabel('定时误差');
subplot(313);plot(w);xlabel('运算点数');ylabel('环路滤波器输出');
%
%
%
iq=ik+qk*sqrt(-1);
L=length(iq)
% off=6;
scatterplot(iq(1:end));
scatterplot(iq(L*0.5:end));
scatterplot(iq(L*0.9:end));