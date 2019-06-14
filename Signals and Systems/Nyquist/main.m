clc
clear
close all

%% fs>2fc
L=1000;
fc=1e3;
fs=3e3;
t=(0:L-1)/fs;
x=sin(2*pi*fc*t);
X=fftshift(fft(x));
ff=(-L/2:L/2-1)*(fs/L);

figure
subplot(2,1,1)
plot(x)
subplot(2,1,2)
plot(ff,abs(X))

%% fs = 2fc
L=100;
fc=1e3;
fs=2e3;
t=(0:L-1)/fs;
x=sin(2*pi*fc*t);
X=fftshift(fft(x));
ff=(-L/2:L/2-1)*(fs/L);

figure
subplot(2,1,1)
plot(x)
subplot(2,1,2)
plot(ff,abs(X))


%% fs<2fc
L=1000;
fc=1e3;
fs=1e3;
t=(0:L-1)/fs;
x=sin(2*pi*fc*t);
X=fftshift(fft(x));
ff=(-L/2:L/2-1)*(fs/L);

figure
subplot(2,1,1)
plot(x)
subplot(2,1,2)
plot(ff,abs(X))