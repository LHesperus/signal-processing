%
clc
clear all
close all

fc=1e4;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
T=1/fs;                                                 %sample time
L=30;                                                 %length of signal
t=(0:L-1)*T;                                            %time vector
A=1;                                                    %%Ampltitude

y=A*sin(2*pi*fc*t);
figure
plot(y)
title("y");

%% gen analytic signal by FFT and IFFT
Y=fft(y,length(y));
Y=fftshift(Y);
figure
plot(abs(Y))
title("Y")

%Y=[Y(1:length(Y)/2),zeros(1,length(Y)/2)];
Y=[zeros(1,length(Y)/2),Y((length(Y)/2+1):end)];
size(Y)
figure
plot(abs(Y))
title("halveY")

Y=ifftshift(Y);
figure
plot(abs(Y));
title("ifftshift")

y_h=ifft(Y);
y_h=2*y_h;
figure
plot(real(y_h))
title("y_h real")

figure
plot(imag(y_h))
title("y_h imag")


%% gen analytic signal by hilbert
y=hilbert(y);
size(y)
y_i=imag(y);
figure
plot(y_i)
title("y_i")

figure
plot(abs(y))
angle_y=angle(y);

figure
plot(angle_y)

