%Generating MASK signal
clc
clear all;
close all;
%use orthogonal modulation generate modulated siganl
%You can see the original signal v in the code.
fc=1e4;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
Rs=2e3;                                                 %symbol rate of digital signal
T=1/fs;                                                 %sample time
L=1000;                                                 %length of signal
t=(0:L-1)*T;                                            %time vector
A=1;                                                    %%Ampltitude
v=A*cos(2*pi*1000*t);                                   %modulation signal
xs=sin(2*pi*fc*t);
xc=cos(2*pi*fc*t);

                                                 
T_mask=1/Rs;
M=4;                                                  %M-ary
a_n=round((M-1)*rand(1,round(L/(T_mask*fs))))*(1/M);  %region 0 to 1 by 1/M.
a_mask=repmat(a_n,T_mask*fs,1);
a_mask=a_mask(:)';
%stairs(a_mask)                                       %figure mask,unuse plot
I_mask=0;
Q_mask=a_mask;
y_mask=I_mask.*xc+Q_mask.*xs;

figure(1)
plot(y_mask)

figure(2)
plotSpectral(y_mask,fs)
