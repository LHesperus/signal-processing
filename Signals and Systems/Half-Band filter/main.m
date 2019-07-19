clc
clear
close all
%% parameter
Hd = halfband;
h=Hd.Numerator;
H=fftshift(fft(h));

%% plot
figure
stem(h)
figure
plot(abs(H))