clc
clear
close all
%% 
fs=10e3;
f0=1e3;
L=100;
t=(0:L-1)/fs;
x=sin(2*pi*f0*t);
X=fftshift(fft(x));
%%
ff=(-L/2:L/2-1)*(fs/L);
figure
subplot(2,1,1)
stem(t,x)
subplot(2,1,2)
plot(ff,abs(X))
suptitle('source signal')
%% decimation
n=3;
y=x(1:n:end);
fs=fs/n;
L=length(y);
ff=(-L/2:L/2-1)*(fs/L);
t=(0:L-1)*fs;

Y=fftshift(fft(y));
figure
subplot(2,1,1)
stem(t,y)
subplot(2,1,2)
plot(ff,abs(Y))
suptitle('decimation')

%%
% y_d=y(1:n+1:end);
% 
% figure
% 
% plot(y_d)