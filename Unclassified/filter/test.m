clc
close all

fc1=1e2;                                                 %carrier frequency
fc2=1e4;
fs=1e5;                                                 %sample frequency
T=1/fs;                                                 %sample time
L=3000;                                                 %length of signal
t=(0:L-1)*T;                                            %time vector
A=1;                                                    %%Ampltitude
ff = fs*(-L/2+1:(L/2))/L;

y=A*(1+cos(2*pi*fc2*t)).*cos(2*pi*fc1*t);
y_q=A*(1+cos(2*pi*fc2*t)).*sin(2*pi*fc1*t);
%y=A*cos(2*pi*(fc1-fc2)*t)+cos(2*pi*(fc1+fc2)*t);
figure
subplot(3,1,1)
plot(y)
subplot(3,1,2)
plot(y_q)
subplot(3,1,3)
plot(ff,abs(fftshift(fft(y))))

[b,a] = butter(8,0.2,'high');
figure
freqz(b,a)

y_fil = filter(b,a,y);
figure
plot(y_fil)
title('y filter')
figure
plot(ff,abs(fftshift(fft(y_fil))))
xlabel('Hz')
title('Y fil')
