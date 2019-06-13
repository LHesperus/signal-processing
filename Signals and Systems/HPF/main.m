clc
clear
close all

%% gen HPF h(n)
L=64;
n=-L/2:L/2-1;
h=zeros(1,L);

omega=0.5*pi;
h=-sin(omega*n)./(pi*n);
h(L/2+1)=1-omega/pi;
H=fftshift(fft(h));

figure
subplot(2,1,1)
stem(h)
subplot(2,1,2)
plot(abs(H))

%% gen HPF H
H1=zeros(1,L);
H1(1:round(1/8*L))=1;
H1(round(7/8*L):end)=1;
h1=ifft(ifftshift(H1));
H11=fftshift(fft(h1));
h11=ifft(ifftshift(H11));

figure
subplot(2,2,1)
plot(H1)
subplot(2,2,2)
stem(real(h1))
subplot(2,2,3)
plot(abs(H11))
subplot(2,2,4)
stem(real(h11))


%%
H1=H;
h1=ifft(ifftshift(H1));
H11=fftshift(fft(h1));
h11=ifft(ifftshift(H11));

figure
subplot(2,2,1)
plot(abs(H1))
subplot(2,2,2)
stem(real(h1))
subplot(2,2,3)
plot(abs(H11))
subplot(2,2,4)
stem(real(h11))