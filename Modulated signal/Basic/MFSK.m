%Generating FM signal
clc
clear all;
close all;
%use orthogonal modulation generate modulated siganl
%You can see the original signal v in the code.
fc=1e4;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
T=1/fs;                                                 %sample time
Rs=2e3;                                                 %symbol rate of digital signal
L=500;                                                 %length of signal
t=(0:L-1)*T;                                            %time vector
A=1;                                                    %%Ampltitude
v=A*cos(2*pi*1000*t);                                   %modulation signal
xs=sin(2*pi*fc*t);
xc=cos(2*pi*fc*t);

%FM                                                 
M=4;
fc_M=(1:M)*5e3;                                       %M groups of carrier frequency
xsM=sin(2*pi*fc_M'*t);
xcM=cos(2*pi*fc_M'*t);
T_MFSK=1/Rs;
a_n=round((M-1)*rand(1,round(L/(T_MFSK*fs))))*(1/M);
a_mfsk=repmat(a_n,T_MFSK*fs,1);
a_mfsk=a_mfsk(:)';
%stairs(a_mfsk)                                       
a_mfsk_M=zeros(M,L);
for i=1:M
    a_mfsk_M(i,:)=(a_mfsk==(i-1)/M);
end
I_mfsk=0;
Q_mfsk=a_mfsk_M;
y_MFSK=I_mfsk.*xcM+Q_mfsk.*xsM;
y_MFSK=sum(y_MFSK,1);

figure(1)
plot(y_MFSK)

figure(2)
plotSpectral(y_MFSK,fs)
