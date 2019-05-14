clc
close all

fc1=1e4;                                                 %carrier frequency
fc2=3e4;
fs=1e5;                                                 %sample frequency
T=1/fs;                                                 %sample time
L=300;                                                 %length of signal
t=(0:L-1)*T;                                            %time vector
A=1;                                                    %%Ampltitude

y=A*sin(2*pi*fc1*t)+sin(2*pi*fc2*t);
figure
plot(y)
title("y");
figure
ff = fs*(-L/2+1:(L/2))/L;
plot(ff,abs(fftshift(fft(y))))
xlabel('Hz')
title('Y')

[b,a] = butter(3,0.4,'high');
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