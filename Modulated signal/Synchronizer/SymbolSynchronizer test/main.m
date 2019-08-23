clc
clear 
close all

%%
j=sqrt(-1);
rf = 0.6;
span = 4;
sps = 40 ;
fs=64e3;


h1 = rcosdesign(rf,span,sps,'sqrt'); % square-root raised cosine 
%h1 = rcosdesign(rf,span,sps,'normal');% normal raised cosine FIR filter
%fvtool(h1,'impulse')
figure
subplot(2,1,1)
stem(h1)
title('h')
subplot(2,1,2)
H=abs(fftshift(fft(h1)));
plot(10*log10(H/max(H)))
title('H')
%% gen iq baseband signal
di = 2*randi([0 1], 1, 1000) - 1;
di=di*sqrt(2);
dq = 2*randi([0 1], 1, 1000) - 1;
dq=dq*sqrt(2);
diq=di+dq*j;

%% Upsample and filter the data for pulse shaping.
% xi = upfirdn(di, h1, sps);
% xq = upfirdn(dq, h1, sps);
% xi=xi(1:10:end);
% xq=xq(1:10:end);
% tx=(0:length(xi)-1)/6.4e3;
xi=reshape([di;zeros(sps-1,length(di))],1,sps*length(di));%%需要插0，不是插符号值
xq=reshape([dq;zeros(sps-1,length(di))],1,sps*length(dq));
xi=conv(xi,h1);
xq=conv(xq,h1);
xiq=xi+xq*j;
%% add noise 
ri = xi + randn(size(xi))*0.1;
rq = xq + randn(size(xq))*0.1;
riq=ri+rq*j;
%% Filter and downsample the received signal for matched filtering.
% yi = upfirdn(ri, h1, 1, sps);
% yq = upfirdn(rq, h1, 1, sps);
% xiq=xi+xq*j;
% yiq=yi+yq*j;


%% upfirdn func test 
[yiq,ypc]=Gardner_func(riq,sps);
%% plot
figure
subplot(4,1,1)
stem(di);title('di')
subplot(4,1,2)
plot(xi);title('xi')
subplot(4,1,3)
plot(ri);title('ri')
subplot(4,1,4)
plot(real(yiq));title('yi')

%% constellation 
figure
subplot(5,1,1)
plot(diq,'kx');title('diq')
subplot(5,1,2)
plot(xiq,'kx');title('xiq')
subplot(5,1,3)
plot(riq,'kx');title('riq')
subplot(5,1,4)
plot(ypc,'kx');title('after PC')
subplot(5,1,5)
plot(yiq,'kx');title('yiq')
suptitle('constellation ')

%%

s = abs(ypc);%1000个采样点
%用小波函数db1对信号进行单尺度小波分解
[cA1,cD1]=dwt(s,'haar');
figure
subplot(3,2,1); plot(s); 
title('原始信号');
subplot(3,2,2); plot(cA1);
title('近似分量');
subplot(3,2,3); plot(cD1);
title('细节分量');

figure
len=length(cA1);
ff=(-len/2:len/2-1)/len;
plot(ff,abs(fftshift(fft(cA1))))
len=length(ypc);
ff=(-len/2:len/2-1)/len;
figure;plot(ff,abs(fftshift(fft(sqrt(real(ypc).^4+imag(ypc).^4)))))