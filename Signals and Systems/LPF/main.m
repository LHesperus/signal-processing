clc
clear
close all

%% gen LPF h(n)->H(omega)
L=1024;
%omega=0.3*pi*(-0.5:1/L:0.5-1/L);
omega=0.1*pi;
n=(-L/2:L/2-1);
h=sin(omega.*n)./(pi*n);
%h=h+0.1*rand(1,L);

h(L/2+1)=0.1;
H=fftshift(fft(h));
figure
subplot(2,1,1)
plot(h)
subplot(2,1,2)
plot(abs(H))
suptitle('h(n)-> H(\omega)')
%% gen LPF H(omega)->h(n)
H1=zeros(1,L);
H1(round(7/16*L):round(9/16*L-1))=1;
h1=ifft(ifftshift(H1));
H11=fftshift(fft(h1));
h11=ifft(ifftshift(H11));

figure
subplot(2,2,1)
plot(abs(H1))
subplot(2,2,2)
plot(real(h1))
title('WHY?')
subplot(2,2,3)
plot(abs(H11))
subplot(2,2,4)
plot(real(h11))
suptitle(' H(\omega)-> h(n) ,:h(n) ???')
%%
H1=fftshift(fft(h)); %Similar frequency domains have different time
%domains,WHHY?
h1=ifft(ifftshift(H1));
H11=fftshift(fft(h1));
h11=ifft(ifftshift(H11));
figure
subplot(2,2,1)
plot(abs(H1))
subplot(2,2,2)
plot(real(h1))
subplot(2,2,3)
plot(abs(H11))
subplot(2,2,4)
plot(real(h11))
suptitle(' H(\omega) of fig 1-> h(n)')
%%  fft ifft test
fc=0.1*[0:L-1]/L;
x=sin(2*pi*fc.*n);
X=fftshift(fft(x));
x1=ifft(ifftshift(X));
X11=fftshift(fft(x1));

figure
subplot(2,2,1)
plot(x)
subplot(2,2,2)
plot(abs(X))
subplot(2,2,3)
plot(x1)
subplot(2,2,4)
plot(abs(X11))
suptitle('fft ,ifft ,fftshift,ifftshift test')