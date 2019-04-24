%
clc
clear all
close all
j=sqrt(-1);
fc=1e4;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
T=1/fs;                                                 %sample time
L=300;                                                 %length of signal
t=(0:L-1)*T;                                            %time vector
A=1;                                                    %%Ampltitude
ff=fs*(-L/2+1:L/2)/L;


y=A*sin(2*pi*fc*t);
figure
plot(y)
title("y");

%% gen analytic signal by FFT and IFFT
Y=fft(y,length(y));
Y=fftshift(Y);
aaa=real(Y)';
bbb=imag(Y)';
figure
subplot(3,1,1)
plot(ff,abs(Y))
title("Y")

%Y=[Y(1:length(Y)/2),zeros(1,length(Y)/2)];
Y=[zeros(1,length(Y)/2),Y((length(Y)/2+1):end)];
subplot(3,1,2)
plot(ff,abs(Y))
title("halveY")

Y=ifftshift(Y);
subplot(3,1,3)
plot(ff,abs(Y));
title("ifftshift")

y_h=ifft(Y);
y_h=2*y_h;

figure
subplot(2,1,1)
plot(real(y_h))
title("y_h real")
subplot(2,1,2)
plot(imag(y_h))
title("y_h imag")


%% gen analytic signal by hilbert
y=hilbert(y);
y_r=real(y);
y_i=imag(y);
figure
plot3(t,y_r,zeros(1,size(t,2)));
hold on
plot3(t,zeros(1,size(t,2)),y_i);
figure
subplot(2,1,1)
plot(y_r)
title("y_r")
subplot(2,1,2)
plot(y_i)
title("y_i")

figure
subplot(3,2,1)
plot3(ff,real(fftshift(fft(y_r))),zeros(1,size(ff,2)))
hold on
plot3(ff,zeros(1,size(ff,2)),imag(fftshift(fft(y_r))))
xlabel('f'); ylabel('r') ;zlabel('i');title('y_r')
axis([min(ff) max(ff) -100 100 -100 100])
subplot(3,2,2)
plot3(ff,real(fftshift(fft(y_i))),zeros(1,size(ff,2)))
hold on
plot3(ff,zeros(1,size(ff,2)),imag(fftshift(fft(y_i))))
axis([min(ff) max(ff) -100 100 -100 100])
xlabel('f'); ylabel('r') ;zlabel('i');title('y_i (y_r by hilbert)')
subplot(3,2,3)
plot3(ff,real(fftshift(fft(y_i*j))),zeros(1,size(ff,2)))
hold on
plot3(ff,zeros(1,size(ff,2)),imag(fftshift(fft(y_i*j))))
axis([min(ff) max(ff) -100 100 -100 100])
xlabel('f'); ylabel('r') ;zlabel('i');title('y_i*j')
subplot(3,2,4)
plot3(ff,real(fftshift(fft(y))),zeros(1,size(ff,2)))
hold on
plot3(ff,zeros(1,size(ff,2)),imag(fftshift(fft(y))))
axis([min(ff) max(ff) -200 200 -200 200])
xlabel('f'); ylabel('r') ;zlabel('i');title('y=y_r+y_i*j')
subplot(3,2,5)
plot(ff,abs(fftshift(fft(y))))
axis([min(ff) max(ff) -200 200])
xlabel('f'); ylabel('Y');title('abs(Y)')

figure
plot(abs(y))

angle_y=angle(y);
figure
plot(angle_y)

