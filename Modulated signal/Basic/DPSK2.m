%Generating 2DPSK signal
clc
clear all;
close all;
%use orthogonal modulation generate modulated siganl
%You can see the original signal v in the code.
fc=1e4;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
Rs=2e3;                                                 %symbol rate of digital signal
T=1/fs;                                                 %sample time
L=500;                                                 %length of signal
t=(0:L-1)*T;                                            %time vector
A=1;                                                    %%Ampltitude
v=A*cos(2*pi*1000*t);                                   %modulation signal
xs=sin(2*pi*fc*t);
xc=cos(2*pi*fc*t);

T_dpsk=1/Rs;                                          
a_n=round(rand(1,round(L/(T_dpsk*fs))));
%2psk to 2dpsk
for i=2:length(a_n)
    if a_n(i)==1
        a_n(i)=abs(a_n(i-1)-1);                          %if a_n=1 then 0->1,1->0
    else
        a_n(i)=a_n(i-1);
    end
end
a_n=2*(a_n>0)-1;                                         %turn 0 of a_n to -1
a_dpsk=repmat(a_n,T_dpsk*fs,1);
a_dpsk=a_dpsk(:)';
%stairs(a_dpsk)                                       
I_dpsk=a_dpsk;
Q_dpsk=0;
y_2dpsk=I_dpsk.*xc+Q_dpsk.*xs;
figure(1)
plot(y_2dpsk)

figure(2)
plotSpectral(y_2dpsk,fs)
