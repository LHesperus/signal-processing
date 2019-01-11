%Generating AM signal
clc
clear all;
close all;
%use orthogonal modulation generate modulated siganl
%You can see the original signal v in the code.
fc=1e4;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
T=1/fs;                                                 %sample time
L=1000;                                                 %length of signal
t=(0:L-1)*T;                                            %time vector
A=1;                                                    %%Ampltitude
v=A*cos(2*pi*1000*t);                                   %modulation signal
xs=sin(2*pi*fc*t);
xc=cos(2*pi*fc*t);

%AM
m_a=0.3;                                               %modulation index,|m_a|<1
I_AM=A+m_a*v;
Q_AM=0;
y_AM=I_AM.*xc+Q_AM.*xs;
figure(1)
plot(y_AM)
title('m_a=0.3');
figure(2)
plotSpectral(y_AM,fs)

m_a=0.5;                                      
I_AM=A+m_a*v;
Q_AM=0;
y_AM=I_AM.*xc+Q_AM.*xs;
figure(3)
plot(y_AM)
title('m_a=0.5');

m_a=1;                                            
I_AM=A+m_a*v;
Q_AM=0;
y_AM=I_AM.*xc+Q_AM.*xs;
figure(4)
plot(y_AM)
title('m_a=1');