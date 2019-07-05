clc
clear 
close all


%%
fc=10e3;
fs=100e3;
f0=1e3;
N=1000;
t=(0:N-1)/fs;
ff=(-N/2:N/2-1)*(fs/N);
%x=2*(randn(1,N)>0)-1;
x=sin(2*pi*f0*t);
y = modulate(x,fc,fs,'am');
Y=fftshift(fft(y));
figure
plot(y)

figure
plot(ff,abs(Y))