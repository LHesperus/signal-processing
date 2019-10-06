clc
clear all
close all
x = randi([0 1],1000,1);
y = mskmod(x,4,[],pi/2);
rccfilter=rcosdesign(0.5, 6, 4,'sqrt');
y=conv(y,rccfilter);
z = awgn(y,30,'measured');


eyediagram(z,16);
figure
plot(real(z))
figure
plot(imag(z))
figure
plot(angle(z))
figure
plot(unwrap(angle(z)))
figure
plot(fftshift(abs(fft(z))))
figure;
plot(z,'x')