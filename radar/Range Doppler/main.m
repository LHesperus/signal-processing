%% 仿真了双基地雷达的距离多普勒，发射信号为线性调频脉冲信号，单目标
%% 频域处理
clc
clear all
close all
%%
j=sqrt(-1);
c=3e8;
R=152000; %目标距离
v=50;%目标速度
vmax=400;%最大检测速度
lambda=c/800e6;%信号射频波长
fd=2*v/lambda;%目标多普勒
disp(['理论多普勒频移',num2str(fd)])
% Fdmax=2*vmax/lambda;%最大可检测多普勒
fs=8e6;
delay=round(R/c*fs);%对应时延
Rmin=-1e6;
Rmax=1e6;
len=1e6;%信号总长
gamma=1+j;
beta0=0.1+0.1*j;
beta1=0.01+0.01*j;
% beta1=0.1;
t=(0:len-1)/fs;
copy=100;%脉冲重复的个数
copy10=10*copy;
s_ref=gamma*sum(exp(j*2*pi*t(1:len/copy10).*(0:fs/8/(len/copy10):fs/8-fs/8/(len/copy10))),1);

s_ref=[s_ref,zeros(1,9*size(s_ref,2))];%补0
s_ref=repmat(s_ref,1,copy);
% s_ref=[zeros(1,100),s_ref(1:end-100)];
s_ref=awgn(s_ref,10,'measured');
PRF=fs/(len/copy);
disp(['PRF：',num2str(PRF)]);
disp(['R_un：',num2str(c/PRF)]);%双站的应该不用除2
figure
plot(abs(fftshift(fft(s_ref))))
figure
plot(real(s_ref))
% len=10*len;
% t=(0:len-1)/fs;

s_echo=beta0*s_ref+beta1*[zeros(1,delay),s_ref(1:end-delay)].*exp(-j*2*pi*fd*t);%回波信号

% Lsur=floor(fs/(2*Fdmax));
Lsur=len/copy;%快时间维分块长度,按每个PRI分块,可以试试乘2或除2
Dim=floor(len/Lsur);%
FastTimeDim=zeros(Dim,Lsur);

% [Range,doppler,RD]=RangeDoppler(s_ref,s_echo,Lsur,0,0,0,fs,0);
% [Range,doppler,RD]=RangeDoppler(s_ref,s_echo,Lsur,10000,0,0,fs,0);
[Range,doppler,RD]=RangeDoppler(s_ref,s_echo,Lsur,0,20480,512,fs,0);
for ii=1:Dim
    FastTimeDim(ii,:)=fft(s_ref((ii-1)*Lsur+1:ii*Lsur)).*conj(fft(s_echo((ii-1)*Lsur+1:ii*Lsur)));
    FastTimeDim(ii,:)=(ifft(FastTimeDim(ii,:)));%不加fftshit，距离从0开始
end
SlowTimeDim=fftshift(fft(FastTimeDim,[],1),1);%加fftshift，速度从负的最小值到正的最大值
doppler=(-Dim/2:Dim/2-1)*(fs/Lsur/Dim);%最大可检测多普勒为fs/(2*Lsur),Lsur应该>=fs*(lambda/(4Vmax))
disp(['最大可检测多普勒：',num2str(fs/(2*Lsur))])
Range=(0:Lsur-1)*(1/fs)*c;%采样间隔1/fs,距离为1/fs*c
disp(['最大可检测距离为：',num2str(Lsur*c/fs)])
Range=Range(end:-1:1);
figure
mesh(Range,doppler,10*log10(abs(SlowTimeDim)/max(max(abs(SlowTimeDim)))))
title('距离多普勒')
% mesh(abs(SlowTimeDim))
ylabel('Hz')
xlabel('m')


figure
plot((-len+1:len-1),(abs(xcorr(s_ref,s_echo)/(2*len))))
title('互相关')
figure
correlation=fftshift(ifft(fft(s_ref).*conj(fft(s_echo))));
plot(abs(correlation))
title('频域压缩')