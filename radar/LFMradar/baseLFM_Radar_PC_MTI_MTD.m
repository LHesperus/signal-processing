%==========================================================================
% 雷达系统基本测试
% 包含脉压，MTI和MTD
% MTI部分也可以注释掉
% 作者：LHesperus
%==========================================================================
% 雷达参数
clc;clear all;close all
j=sqrt(-1);         %
c=3e8;              % 光速
T_LFM=100e-6;       % 时宽
B=10e6;             % LFM带宽
fs=100e6;           % 采样率
N=10;               % 扩展N倍
PRI=T_LFM*N;        % 
M=32;               % 脉冲个数
fc=600e6;           % 载频
lambda=c/fc;        % 波长
% 目标参数
v=[0 10 30];       %速度，地杂波等先用0速度点目标代替
R=[10e3 2e3 100e3]; %距离
A=[10 1 1];         %目标强度控制
fd=2*v/lambda;      %多普勒频率
tau=2*R/c;          %时延

disp(['最大测距范围：',num2str(PRI*c/2)])
disp(['最大测速范围：',num2str(-1/PRI*lambda/2/2),'~',num2str(1/PRI*lambda/2/2)])

%% 发射部分
% 生成线性调频信号
[s,t]=genLFM(fs,0,B,T_LFM);len=length(s);
S=abs(fftshift(fft(s)));
ff=(-len/2:len/2-1)*(fs/len);

figure
subplot(221);plot(t,real(s))
subplot(222);plot(t,imag(s))
subplot(223);plot(ff,S)
% 扩展至多个周期
s_lfm=[s,zeros(1,length(s)*(N-1))];
s_lfm=repmat(s_lfm,1,M);
len=length(s_lfm);
S_lfm=abs(fftshift(fft(s_lfm)));
ff=(-len/2:len/2-1)*(fs/len);
t=(0:len-1)/fs;
figure
subplot(221);plot(real(s_lfm))
subplot(222);plot(imag(s_lfm))
subplot(223);plot(ff,S_lfm)
suptitle('发射波形基带')


%% 信道部分
% 模拟回波
s_echo=zeros(1,length(s_lfm));
for ii=1:length(tau)
    delay=round(tau(ii)*fs);
    s_echoTmp=s_lfm.*exp(j*2*pi*fd(ii)*t);
    s_echo=s_echo+A(ii)*[zeros(1,delay),s_echoTmp(1:end-delay)];
end

% 信道
snr=10;
s_echo=awgn(s_echo,snr,'measured');

%% 接收部分
% 重排
X=reshape(s_echo,[],M);X=X.';%注意这里重排不要排错了：X=reshape(s_echo,M,[]);
%------------------------------- 匹配滤波----------------------------------
H=fft(s,size(X,2));
Xpc=zeros(M,size(X,2));% 脉压后矩阵
for ii=1:M
    Xpc(ii,:)=(ifft(fft(X(ii,:)).*conj(H)));
end
figure
mesh(abs(Xpc))
title('多个脉冲脉压结果')
figure;plot(abs(fftshift(fft(sum(X,2),1024))))% 测试多普勒频率
title('多普勒频率积累测试')
%------------------------ MTI----------------------------------------------
% 对消后低频部分信号被抑制，可能波及到速度低的目标
% 高通滤波器
X_mti=zeros(M-2,size(Xpc,2));
for ii=1:M-2
      X_mti(ii,:)=Xpc(ii,:)+Xpc(ii+2,:)-2*Xpc(ii+1,:);%三脉冲对消
%      X_mti(ii,:)=Xpc(ii,:)-Xpc(ii+1,:);%两脉冲对消
end
M=M-2;
% M=M-1;%两脉冲对消
figure;plot(abs(fftshift(fft(sum(X_mti,2),1024))))% 测试多普勒频率
title('多普勒频率积累测试')
%-------------------------------- MTD-------------------------------------
nfft=M;
% nfft=256;
Xfft=fftshift(fft(X_mti,nfft,1),1);
len1=size(Xfft,1);
len2=size(Xfft,2);
% t=(-len2/2:len2/2-1)/fs;
t=(0:len2-1)/fs;
ff=(-len1/2:len1/2-1)*(fs/len2/len1);
[XX,YY]= meshgrid(t,ff);
figure
mesh(XX,YY,abs(Xfft))
ylabel('频率')
xlabel('时延')
disp(['(fd,tau):',num2str([fd,tau])])

