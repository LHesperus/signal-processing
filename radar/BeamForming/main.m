%% 波束形成 加强某方向信号能量 
% LCG UESTC 2020.11.24
% fft 求空间频率谱，角度也是频率
%% parameter
clc;clear ;close all
j=sqrt(-1);
L=10000; % snapshot
N=16; %阵元个数
K=3;% 目标个数
theta=[-10,20,40]/180*pi;
lambda=1;
d=lambda/2;

%% X=AS+No,A:N*k,S:K*L
Amp=[5,5,5]';
f0=[-0.25,0.15,0.25]';
A=exp(-j*(0:N-1)'.*2*pi*d/lambda*sin(theta));
% S=rand(K,L)+rand(K,L)*j;
S=exp(j*2*pi*f0.*(0:L-1));% 固定频率入射
S=Amp.*S;

No=rand(N,L);
X=A*S+No;
X=X.*exp(-j*2*pi*(0:N-1)'*d/lambda*sin(0/180*pi));%指向0°
figure
ff=linspace(-0.5,0.5,L);
Sp=abs(fftshift(fft(sum(X,1))));
plot(ff,Sp)
%% FFT 空间功率谱
tmp=linspace(-1,1,1024);
doaFFT=abs(fftshift(fft(sum(conj(X),2),length(tmp))));% 快拍求和,共轭,fft
doaFFT=doaFFT/max(doaFFT);
figure
plot(asin(tmp)*180/pi,10*log10(doaFFT))
xlabel('角度 / (^o)')
title('信号的空间功率谱')

%% 指向40°测试
j=sqrt(-1);
L=10000; % snapshot
N=16; %阵元个数
K=3;% 目标个数
theta=[-10,20,40]/180*pi;
lambda=1;
d=lambda/2;

%% X=AS+No,A:N*k,S:K*L
Amp=[5,5,5]';
f0=[-0.25,0.15,0.25]';
A=exp(-j*(0:N-1)'.*2*pi*d/lambda*sin(theta));
% S=rand(K,L)+rand(K,L)*j;
S=exp(j*2*pi*f0.*(0:L-1));% 固定频率入射
S=Amp.*S;

No=rand(N,L);
X=A*S+No;
X=X.*exp(-j*2*pi*(0:N-1)'*d/lambda*sin(40/180*pi));%指向4°
figure
ff=linspace(-0.5,0.5,L);
Sp=abs(fftshift(fft(sum(X,1))));
plot(ff,Sp)
%% FFT 空间功率谱
tmp=linspace(-1,1,1024);
doaFFT=abs(fftshift(fft(sum(conj(X),2),length(tmp))));% 快拍求和,共轭,fft
doaFFT=doaFFT/max(doaFFT);
figure
plot(asin(tmp)*180/pi,10*log10(doaFFT))
xlabel('角度 / (^o)')
title('信号的空间功率谱')
