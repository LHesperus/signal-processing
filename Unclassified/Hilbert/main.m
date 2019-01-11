%
clc
clear all

fc=1e4;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
T=1/fs;                                                 %sample time
L=3000;                                                 %length of signal
t=(0:L-1)*T;                                            %time vector
A=1;                                                    %%Ampltitude

y=A*sin(2*pi*fc*t);
plot(y)
y=hilbert(y)
plot(abs(y))
angle_y=angle(y)
plot(angle_y)