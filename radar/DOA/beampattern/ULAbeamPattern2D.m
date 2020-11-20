%% 阵列方向图
% ref：雷达空时自适应处理，JR，中文版 p48
% author：lcg UESTC 20201119
% 2维波束图，角度-多普勒导向矢量方向图
clc;clear all;close all
%% parameter
j=sqrt(-1);
theta0=20/180*pi;%指向
N=16;% 阵元个数
M=12;
lambda=3e8/600e6;
d=lambda/2;%阵元间距
v=100;%速度
T=1e-8;%PRI
beta=2*v*T/d;
% beta=1;
%% 由于均匀线阵的方向图可以简化成FFT的形式，也可以用fft求 
thetai=d/lambda*sin(theta0);
fdi=beta*thetai;
fdi=0.25;
ai=exp(j*2*pi*(0:N-1)'*thetai);
bi=exp(j*2*pi*(0:M-1)'*fdi);
vi = kron(bi,ai);
vi2=reshape(vi ,N,M);% 注意N，M不要搞反了
F=abs(fftshift(fft2(vi2,1024,1024)));
F=abs(F)/max(max(abs(F)));
F=20*log10(F);

%% plot
theta=asin(linspace(-1,1,1024));
fd=linspace(-0.5,0.5,1024);
figure
mesh(fd,theta/pi*180,F)
xlabel('归一化频率')
ylabel('角度')
colormap(colorcube)
axis([-0.5 0.5 -100 100 -50 0])
figure
imagesc(fd,theta/pi*180,F)%用这个函数好像theta不准
colormap(colorcube)