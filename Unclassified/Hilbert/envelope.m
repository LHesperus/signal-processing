%extract the envelope
clc
clear all
close all
j=sqrt(-1);
f0=1e2;                                                 %carrier frequency
fc=1e4;
fs=1e5;                                                 %sample frequency
T=1/fs;                                                 %sample time
L=3000;                                                 %length of signal
t=(0:L-1)*T;                                            %time vector
A=1;                                                    %%Ampltitude
ff=fs*(-L/2+1:L/2)/L;

%%
y=A*(1+0.3*sin(2*pi*f0*t)).*cos(2*pi*fc*t);
figure
subplot(3,2,1)
plot(y)
title("y");
subplot(3,2,2)
plot(ff,abs(fftshift(fft(y))))
subplot(3,2,3)
plot(abs(hilbert(y))) 
title('envelop')
subplot(3,2,4)
plot(ff,abs(fftshift(fft(abs(hilbert(y))))))
title('Spetrum of envelop')
subplot(3,2,5)
plot(abs(hilbert(y))-mean(abs(hilbert(y)))) 
title('envelop without DC component')
subplot(3,2,6)
plot(ff,abs(fftshift(fft(abs(hilbert(y))-mean(abs(hilbert(y)))))))
title('Y_h without DC component')

%%
y_r=real(hilbert(y));
y_i=imag(hilbert(y));
y_h=hilbert(y);
figure
subplot(3,2,1)
plot3(ff,real(fftshift(fft(y_r))),zeros(1,size(ff,2)))
hold on
plot3(ff,zeros(1,size(ff,2)),imag(fftshift(fft(y_r))))
max_Y=max([abs(real(fftshift(fft(y_r)))) abs(imag(fftshift(fft(y_r))))]);
xlabel('f'); ylabel('r') ;zlabel('i');title('y_r')
axis([min(ff) max(ff) -max_Y max_Y -max_Y max_Y])

subplot(3,2,2)
plot3(ff,real(fftshift(fft(y_i))),zeros(1,size(ff,2)))
hold on
plot3(ff,zeros(1,size(ff,2)),imag(fftshift(fft(y_i))))
max_Y=max([abs(real(fftshift(fft(y_i)))) abs(imag(fftshift(fft(y_i))))]);
axis([min(ff) max(ff) -max_Y max_Y -max_Y max_Y])
xlabel('f'); ylabel('r') ;zlabel('i');title('y_i (y_r by hilbert)')

subplot(3,2,3)
plot3(ff,real(fftshift(fft(y_i*j))),zeros(1,size(ff,2)))
hold on
plot3(ff,zeros(1,size(ff,2)),imag(fftshift(fft(y_i*j))))
axis([min(ff) max(ff) -max_Y max_Y -max_Y max_Y])
xlabel('f'); ylabel('r') ;zlabel('i');title('y_i*j')

subplot(3,2,4)
plot3(ff,real(fftshift(fft(y_h))),zeros(1,size(ff,2)))
hold on
plot3(ff,zeros(1,size(ff,2)),imag(fftshift(fft(y_h))))
max_Y=max([abs(real(fftshift(fft(y_h)))) abs(imag(fftshift(fft(y_h))))]);
axis([min(ff) max(ff) -max_Y max_Y -max_Y max_Y])
xlabel('f'); ylabel('r') ;zlabel('i');title('y=y_r+y_i*j')

subplot(3,2,5)
plot(ff,abs(fftshift(fft(y_h))))
max_Y=max(abs(fftshift(fft(y_h))));
axis([min(ff) max(ff) -max_Y max_Y])
xlabel('f'); ylabel('Y');title('abs(Y)')
