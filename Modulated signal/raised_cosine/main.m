% raised cosine function test
clc
clear 
close all

%%
j=sqrt(-1);
rf = 0.6;
span = 6;
sps = 64 ;

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
di = 2*randi([0 1], 100, 1) - 1;
di=di*sqrt(2);
dq = 2*randi([0 1], 100, 1) - 1;
dq=dq*sqrt(2);
diq=di+dq*j;

%% Upsample and filter the data for pulse shaping.
xi = upfirdn(di, h1, sps);
xq = upfirdn(dq, h1, sps);

%% add noise 
ri = xi + randn(size(xi))*0.1;
rq = xq + randn(size(xq))*0.1;
riq=ri+rq*j;
%% Filter and downsample the received signal for matched filtering.
yi = upfirdn(ri, h1, 1, sps);
yq = upfirdn(rq, h1, 1, sps);
xiq=xi+xq*j;
yiq=yi+yq*j;

%% plot
figure
subplot(4,1,1)
stem(di);title('di')
subplot(4,1,2)
plot(xi);title('xi')
subplot(4,1,3)
plot(ri);title('ri')
subplot(4,1,4)
plot(yi);title('yi')

%% abs
figure
subplot(4,1,1)
plot(abs(diq))
subplot(4,1,2)
plot(abs(xiq))
subplot(4,1,3)
plot(abs(riq))
subplot(4,1,4)
plot(abs(yiq))
suptitle('abs')

%% constellation 
figure
subplot(4,1,1)
plot(diq,'kx')
subplot(4,1,2)
plot(xiq,'kx')
subplot(4,1,3)
plot(riq,'kx')
subplot(4,1,4)
plot(yiq,'kx')
suptitle('constellation ')

%% iq.^n spectrum
figure
subplot(5,1,1)
plot(abs(fftshift(fft(diq))))
title('n=1')
subplot(5,1,2)
plot(abs(fftshift(fft(diq.^2))))
title('n=2')
subplot(5,1,3)
plot(abs(fftshift(fft(diq.^3))))
title('n=3')
subplot(5,1,4)
plot(abs(fftshift(fft(diq.^4))))
title('n=4')
subplot(5,1,5)
plot(abs(fftshift(fft(diq.^8))))
title('n=8')
suptitle('spectrum of diq^n')



%% iq .^4 spectrum
figure
subplot(4,1,1)
plot(abs(fftshift(fft(diq.^4))))
title('Diq')
subplot(4,1,2)
plot(abs(fftshift(fft(xiq.^4))))
title('Xiq')
subplot(4,1,3)
plot(abs(fftshift(fft(riq.^4))))
title('Riq')
subplot(4,1,4)
plot(abs(fftshift(fft(yiq.^4))))
title('Yiq')
suptitle('spectrum of iq^4')