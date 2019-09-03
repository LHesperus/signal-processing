%Generating FM signal
clc
clear all;
close all;
%use orthogonal modulation generate modulated siganl
%You can see the original signal v in the code.
fc=1e4;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
Rs=5e3;                                                 %symbol rate of digital signal
T=1/fs;                                                 %sample time
L=1000;                                                 %length of signal
t=(0:L-1)*T;                                            %time vector
A=1;                                                    %%Ampltitude
v=A*cos(2*pi*1000*t);                                   %modulation signal
xs=sin(2*pi*fc*t);
xc=cos(2*pi*fc*t);

fc1=1.1e4;                                              %|fc1-fc|<Rs
fc1=3e4;                                                %|fc1-fc|>Rs
xs1=sin(2*pi*fc1*t);
xc1=cos(2*pi*fc1*t);
T_fsk=1/Rs;                                        
a_n=round(rand(1,round(L/(T_fsk*fs))));
a_fsk1=repmat(a_n,T_fsk*fs,1);
a_fsk1=a_fsk1(:)';
a_fsk2=a_fsk1<1;                                      %0->1,1->0
%stairs(a_fsk1)
I_fsk1=0;
Q_fsk1=a_fsk1;
I_fsk2=0;
Q_fsk2=a_fsk2;
y_fsk=I_fsk1.*xc+Q_fsk1.*xs+I_fsk2.*xc1+Q_fsk2.*xs1;  %equal to add two ask
figure(1)
plot(y_fsk)
figure(2)
plotSpectral(y_fsk,fs)
