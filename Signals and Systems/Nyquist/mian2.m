clc
clear
close all

%% fs>2fmax
L=1000;
fc=1e3*(1:0.1:2);
fs=10e3;
t=(0:L-1)/fs;
x=sum(sin(2*pi*fc.'*t));
X=fftshift(fft(x));
ff=(-L/2:L/2-1)*(fs/L);

figure
subplot(2,1,1)
plot(x)
subplot(2,1,2)
plot(ff,abs(X))


%% fs=2fmax
L=1000;
fc=1e3*(1:0.1:2);
fs=4e3;
t=(0:L-1)/fs;
x=sum(sin(2*pi*fc.'*t));
X=fftshift(fft(x));
ff=(-L/2:L/2-1)*(fs/L);

figure
subplot(2,1,1)
plot(x)
subplot(2,1,2)
plot(ff,abs(X))

%% fs2<fmax
L=1000;
fc=1e3*(1:0.1:2);
fs=3.8e3;
t=(0:L-1)/fs;
x=sum(sin(2*pi*fc.'*t));
X=fftshift(fft(x));
ff=(-L/2:L/2-1)*(fs/L);

figure
subplot(2,1,1)
plot(x)
subplot(2,1,2)
plot(ff,abs(X))