%% Gaussian Filtered Minimum Shift keying-GMSK

clc
clear
close all

Rs=1e3;                                        %bit ratio
Ts=1/Rs;
N=10;                                          %Number of bits to process
fc=40e2;                                        %carrier frequency
fs=10e4;                                        %sample frequency
T=1/fs;
t=(0:(round(N*Ts/T)-1))*T;
ts=(0:N-1)*Ts;
r=round(Ts/T);

%% Orthogonal carrier wave
xc=cos(2*pi*fc*t);
xs=sin(2*pi*fc*t);

%% Gaussian Filter
BTs=0.3;
B=BTs/Ts;


%alpha=sqrt(log(2)/2)/B;
%h=sqrt(pi)/alpha*exp(-(pi/alpha*t).^2);


%I couldn't do it with h convolution, and then I used qunc function.
g_t=qfunc(2*pi*B*(t-Ts/2-4.5*Ts)/sqrt(log(2)))-qfunc(2*pi*B*(t+Ts/2-4.5*Ts)/sqrt(log(2)));%4,5Ts is used to display all g_t
figure
plot(t,g_t)


%% gengerate bit sequence
a=2*(rand(1,N)>0.5)-1;
%a=[1,1,-1,1,-1,-1,1,1,-1,1] %%test signal
%a=[1,1,1,-1,-1,1,1,1,-1,-1,-1,-1,-1,-1,-1]
a=[1,1,1,-1,-1,1,1,1,-1,-1]
a_sample=repmat(a,r,1);
a_sample=a_sample(:)';

figure
plot(a_sample)
%% conv
a_fil=conv(a_sample,g_t)/r;%I can't explain it here./r,It seems right.
a_fil=a_fil(round(4.5*Ts/T):end);%Make up for the delays(4.5Ts) previously used
figure
plot(a_fil)
title('a_fil')


%% additive phase
for ii=1:length(t)
    theta(ii)=pi/(2*Ts)*T*trapz(a_fil(1:ii));
end
figure
%Although the trend is right, the peak value is getting smaller and I don't know what the problem is.
plot(theta)

theta1=wrapToPi(theta);
figure
plot(theta1)
%% GMSK
s=cos(theta).*xc-sin(theta).*xs;
figure
plot(s)
