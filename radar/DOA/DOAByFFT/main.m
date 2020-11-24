%% DOA FFT 测试
% LCG UESTC 2020.11.24
%% parameter
clc;clear ;close all
j=sqrt(-1);
L=1000; % snapshot
N=16; %阵元个数
K=3;% 目标个数
theta=[-10,30,40]/180*pi;
lambda=1;
d=lambda/2;

%% X=AS+No,A:N*k,S:K*L
Amp=[5,10,20]';
A=exp(-j*(0:N-1)'.*2*pi*d/lambda*sin(theta));
S=rand(K,L)+rand(K,L)*j;
S=Amp.*S;

No=rand(N,L);
X=A*S+No;

%% FFT 空间功率谱
tmp=linspace(-1,1,1024);
doaFFT=abs(fftshift(fft(sum(conj(X),2),length(tmp))));% 快拍求和,共轭,fft
doaFFT=doaFFT/max(doaFFT);
figure
plot(asin(tmp)*180/pi,10*log10(doaFFT))
xlabel('角度 / (^o)')
title('信号的空间功率谱')