%impulse response
clc
clear


Rs=1e3;                                        %bit ratio
Ts=1/Rs;
N=10;                                          %Number of bits to process
fc=40e2;                                        %carrier frequency
fs=10e4;                                        %sample frequency
T=1/fs;
t=(0:(round(N*Ts/T)-1))*T;
ts=(0:N-1)*Ts;
r=round(Ts/T);

%% Gaussian Filter
BTs=[0.1,0.3,0.5,1.0,10000];
B=BTs/Ts;

%alpha=sqrt(log(2)/2)/B;
%h=sqrt(pi)/alpha*exp(-(pi/alpha*t).^2);

%I couldn't do it with h convolution, and then I used qunc function.
gt=qfunc(2*pi*B'*(t-Ts/2-4.5*Ts)/sqrt(log(2)))-qfunc(2*pi*B'*(t+Ts/2-4.5*Ts)/sqrt(log(2)));%4,5Ts is used to display all g_t
for ii =1:length(B)
     plot(t/Ts,gt(ii,:))
hold on 
end
title('Rectangular impulse response of Gauss filter')
legend('BT=0.1','BT=0.3','BT=0.5','BT=1.0','BT=10000')
xlabel('t/Tb')
ylabel('g(t)')
grid on