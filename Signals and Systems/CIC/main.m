clc
clear
close all
%%
D=6;
L=100;
h=[ones(1,D),zeros(1,L-D)];
H=fftshift(fft(h));
ff=(-L/2:L/2-1)*(2*pi/L);

figure
subplot(4,1,1)
stem(h);title('h')
subplot(4,1,2)
plot(ff,abs(H));title('H,you can see the max amp is D')


%% multi-stage CIC filters 
h_m=conv(h,h);
H_m=fftshift(fft(h_m));
L=length(h_m);
ff=(-L/2:L/2-1)*(2*pi/L);
subplot(4,1,3)
stem(h_m);title('conv(h,h)')
subplot(4,1,4)
plot(ff,abs(H_m));title('Spectrum of conv(h,h)')
suptitle( 'CIC')