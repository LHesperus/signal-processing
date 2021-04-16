%==========================================================================
% 匹配滤波测试
% 时域 h(t)=s*(t0-t)  y=conv(h,s)
% 频域 H(f)=S*(f)=conj(fft(s(t)))  y=ifft(S(f)H(f))=ifft(S(f)S*(f))
%==========================================================================
% 
clc;clear;close all
j=sqrt(-1);
T_LFM=1e-3;
B=10e6;
fs=100e6;
N=10; % 
PRI=T_LFM*N;  % 
M=8;   %脉冲个数

% [s,t]=genLFM(fs,0,B,T_LFM);
s=linspace(-1,1,length(s));%+linspace(1,-1,length(s))*j;%其他信号测试
s=rand(1,length(s))-0.5+(rand(1,length(s))-0.5)*j;
h=conj(s(end:-1:1));
% h=conj(s);
len=length(s);
S=abs(fftshift(fft(s)));
ff=(-len/2:len/2-1)*(fs/len);

figure
subplot(221);plot(t,real(s))
subplot(222);plot(t,imag(s))
subplot(223);plot(ff,S)
%------------------------------- 时域相关----------------------------------
sh=conv(s,h);
sh=abs(sh(len/2+1:end-len/2+1));
yy=linspace(min(sh),max(sh),length(sh));
figure
plot(t,(sh));
% hold on
% plot(-1/B*[1 1],[min(sh) max(sh)],'black');
% hold on
% plot(1/B*[1 1],[min(sh) max(sh)],'black');
% axis([t(len/2-100) t(len/2+100) min(sh) max(sh)])

disp(['匹配后最大值为：',num2str(max(sh))])
disp(['-4dB带宽：',num2str(B)])
disp(['压缩比=T_LFM/(1/B)=T_LFM*B=',num2str(T_LFM*B)])


%-------------------------------- 频域处理----------------------------------
h=s;
sh2=abs(fftshift(ifft(fft(s).*conj(fft(h)))));
figure;
plot(t,sh2)
% axis([t(len/2-100) t(len/2+100) min(sh) max(sh)])