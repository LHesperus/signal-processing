clc
clear all
close all
len=10000;
t=(1:len-1)/10000;
x=0.1*sin(2*pi*t);%+0.2*sin(2*pi*2*t);
y=hilbert(x);
figure
plot(x)
figure
plot(real(y))
figure
plot(imag(y))

h=1./(pi*t);
yh=conv(h,x);
figure
plot(yh)