clc
clear 
close all

%%  nature of delta 
L=1024;

delta=zeros(1,L);
delta(L/2)=1;
DELTA=fftshift(fft(delta));

figure
subplot(2,1,1)
plot(delta)
title('\delta (n)')
subplot(2,1,2)
plot(abs(DELTA))
title('Spectrum of \delta (n)')