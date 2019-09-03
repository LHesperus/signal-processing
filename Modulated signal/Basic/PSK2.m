%Generating FM signal
clc
clear all;
close all;
%use orthogonal modulation generate modulated siganl
%You can see the original signal v in the code.
fc=5e3;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
Rs=1e3;                                                 %symbol rate of digital signal
T=1/fs;                                                 %sample time
L=1000;                                                  %length of signal
t=(0:L-1)*T;                                            %time vector
A=1;                                                    %%Ampltitude
v=A*cos(2*pi*1000*t);                                   %modulation signal
xs=sin(2*pi*fc*t);
xc=cos(2*pi*fc*t);

T_psk=1/Rs;                                          
a_n=round(rand(1,round(L/(T_psk*fs))));
a_n=2*(a_n>0)-1;
a_psk=repmat(a_n,T_psk*fs,1);
a_psk=a_psk(:)';
%stairs(a_psk)                                       
I_psk=a_psk;
Q_psk=0;
y_2psk=I_psk.*xc+Q_psk.*xs;
figure(1)
plot(y_2psk)

figure(2)
plotSpectral(y_2psk,fs)
