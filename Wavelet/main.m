clc
clear all
close all
%% 
fs=100e3;
f0=1e3;
len=10000;
t=(0:len-1)/fs;
x=sin(2*pi*f0*t);
y=[zeros(1,len),x,zeros(1,len),x,zeros(1,len)];
figure
plot(y)
figure
stft(y,fs,'Window',kaiser(200,30))
figure
cwt(y,fs)