%% 阵列方向图
% ref：现代数字信号处理：何子述，p204
% author：lcg UESTC 20201113
% 空域滤波的方向图(也称波束图)为输出信号与输入信号幅度之比
clc;clear all;close all
%% parameter
j=sqrt(-1);
theta=-90:0.01:90;
theta=theta/180*pi;
theta0=10/180*pi;
N=16;% 阵元个数
lambda=3e8/600e6;
d=lambda/2;%阵元间距

%% beampattern
F=sin(N*pi*d/lambda*(sin(theta)-sin(theta0)))./sin(pi*d/lambda*(sin(theta)-sin(theta0)));
F=abs(F)/max(abs(F));
figure
plot(theta*180/pi,20*log10(F))%这里是乘20
xlabel('空间角度/ ( {\circ} )')
ylabel('归一化方向图/dB')
title('阵元间距\lambda /2的16阵元均匀线阵方向图')
axis([-100 100 -50 0])


% 主瓣两侧零点宽度
BW0=2*asin(lambda/(N*d)+sin(theta0));
disp(['主瓣两侧零点宽度',num2str(BW0*180/pi)])


% 3dB
theta3dB=50.8*lambda/(N*d);
disp(['3dB主瓣宽度',num2str(theta3dB)])



%% 公式未化简版本：F=|w……{H}a(theta)|,可更改w实现加窗
phi=2*pi*d*sin(theta)/lambda;
phi0=2*pi*d*sin(theta0)/lambda;
a=exp(-j*(0:N-1)'*phi);
w=exp(-j*(0:N-1)'*phi0);
% w = fir1(15,0.01,'low')';
% figure;plot(abs(w))
F=abs(w'*a);
F=abs(F)/max(abs(F));
figure
plot(theta*180/pi,20*log10(F))%这里是乘20
xlabel('空间角度/ ( {\circ} )')
ylabel('归一化方向图/dB')
title('阵元间距\lambda /2的16阵元均匀线阵方向图')
axis([-100 100 -50 0])


%% 由于均匀线阵的方向图可以简化成FFT的形式，也可以用fft求 fft(w),但是求得的图有点不一样，不知怎么回事
phi=2*pi*d*sin(theta)/lambda;
phi0=2*pi*d*sin(theta0)/lambda;
w=exp(-j*(0:N-1)'*phi0);
F=abs(fftshift(fft(conj(w),length(theta))));%应该是w的共轭？
F=abs(F)/max(abs(F));
figure
plot(theta*180/pi,20*log10(F))%这里是乘20
xlabel('空间角度/ ( {\circ} )')
ylabel('归一化方向图/dB')
title('阵元间距\lambda /2的16阵元均匀线阵方向图')
axis([-100 100 -50 0])


