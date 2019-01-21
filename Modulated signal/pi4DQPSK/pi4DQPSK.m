% pi/4DQPSK
clc
clear

Rs=10e2;                                        %bit ratio
Ts=1/Rs;
N=500;                                          %Number of bits to process
fc=20e2;                                        %carrier frequency
fs=10e4;                                        %sample frequency
T=1/fs;
t=(0:(round(N*Ts/T)-1))*T;
r=Ts/T;

a=rand(1,N)>0.5;                               %bit symbol

%% serial-to-paralle
Idata=a(1:2:end);
Idata=repmat(Idata,2,1);
Idata=Idata(:)';

Qdata=a(2:2:end);
Qdata=repmat(Qdata,2,1);
Qdata=Qdata(:)';

%% Qdata delay one bit
Qdata=[0,Qdata(1:end-1)];

%% Gray coded
% 00->0->  pi/4
% 01->1-> 3pi/4
% 10->2-> -pi/4
% 11->3->-3pi/4
two_bits_decimal = [2,1]*[Qdata;Idata];
phase_code=pi*[1/4,3/4,-1/4,-3/4];
phi=phase_code(two_bits_decimal+1);
phi=cumsum(phi);
%From here only the phase jump of pi/4 and 3pi/4 can be seen.
figure
stem(abs(phi/pi-[phi(2:end),0]/pi));                
title('phase jump')
phi_sample=repmat(phi,r,1);
phi_sample=phi_sample(:)';
%% constellation
j=sqrt(-1);
s=cos(phi)+sin(phi)*j;
figure
plot(s,'o')
grid on;axis('equal',[-1.5 1.5 -1.5 1.5]);
title('constellation map')
figure
plot(s)
grid on;axis('equal',[-1.5 1.5 -1.5 1.5]);
title('Phase change trajectory')
%% carrier wave
xc=cos(2*pi*fc*t);
xs=sin(2*pi*fc*t);

%% OQPSK
A=1;    %amplitude
OQPSK_signal=A*(cos(phi_sample).*xc-sin(phi_sample).*xs);

figure
plotSpectral(OQPSK_signal,fs)
