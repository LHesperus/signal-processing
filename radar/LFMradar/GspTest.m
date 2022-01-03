% 信号相干处理增益计算

clc;clear all;close all
j=sqrt(-1);         %
c=3e8;              % 光速
T_LFM=100e-6;       % 时宽
B=10e6;             % LFM带宽
fs=100e6;           % 采样率
N=10;               % 扩展N倍
PRI=T_LFM*N;        % 
M=32;               % 脉冲个数


%% 发射部分
% 生成线性调频信号
[s,t]=genLFM(fs,0,B,T_LFM);len=length(s);
s=2*s;
S=abs(fftshift(fft(s)));
ff=(-len/2:len/2-1)*(fs/len);

figure
subplot(221);plot(t,real(s))
subplot(222);plot(t,imag(s))
subplot(223);plot(ff,S)

corr_s=conv(s,conj(s));
figure
plot(abs(corr_s))

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
% suptitle('发射波形基带')


%% 接收部分
% 重排
X=reshape(s_lfm,[],M);X=X.';%注意这里重排不要排错了
%------------------------------- 匹配滤波----------------------------------
H=fft(s,size(X,2));
Xpc=zeros(M,size(X,2));% 脉压后矩阵
for ii=1:M
    Xpc(ii,:)=fftshift(ifft(fft(X(ii,:)).*conj(H)));
end

figure
mesh(abs(Xpc))




nfft=M;
% nfft=256;
Xfft=fftshift(fft(Xpc,nfft,1),1);
figure
mesh(abs(Xfft))



Gpc=B*PRI
max(max(abs(Xpc)))/mean(abs(s).^2)


Gsp=B*PRI*M
max(max(abs(Xfft)))/mean(abs(s).^2)