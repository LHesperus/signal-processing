%Generating FM signal
clc
clear all;
close all;
%use orthogonal modulation generate modulated siganl
%You can see the original signal v in the code.
fc=1e4;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
T=1/fs;                                                 %sample time
L=500;                                                 %length of signal
t=(0:L-1)*T;                                            %time vector
A=1;                                                    %%Ampltitude
v=A*cos(2*pi*1000*t);                                   %modulation signal
xs=sin(2*pi*fc*t);
xc=cos(2*pi*fc*t);

%FM                                                 
K_omega=0.5;                                            %freq offet index
phi_fm=zeros(1,length(v));
for n=3:length(v)
 phi_fm(n)=K_omega/(2)*(v(1)+v(n)+2*sum(v(2:n-1)));     
end
y_fm=cos(2*pi*fc.*t+phi_fm);
figure(1)
plot(y_fm)
title('K_omega=0.3');
figure(2)
plotSpectral(y_fm,fs)
