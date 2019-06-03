clc
clear all
close all

j=sqrt(-1);
%% gen signal 
f=[0.15 0.25 0.30]';
N=1000;                      %length of signal
M=4;                           % filter order
SNR=[20 25 30]';
sigma_v=1;                    %noise power
v_n=sqrt(sigma_v/2)*randn(1,N)+j*sqrt(sigma_v/2)*randn(1,N);% complex gauss noise
a_k=sqrt(10.^(SNR/10)*sigma_v);%ampltitude of envelope
    
n=(0:N-1);
phi_k=2*pi*rand(1,3)';
s_k=a_k.*exp(j*2*pi*f*n+phi_k);
u_n=sum(s_k)+v_n;
u_n=u_n.';

%% SVD
A=zeros(N-M+1,M);
for ii=1:N-M+1
    A(ii,:)=u_n(M-1+ii:-1:ii)';
end
[U,S,V]=svd(A);
invphi=V*inv(S'*S)*V';

%% MVDR
w_n=1000;
w=2*pi*(-0.5:1/w_n:0.5);
a=exp(-j*(0:M-1)'*w);

for ww=1:length(w)
    P_mvdr(ww)=1/(a(:,ww)'*invphi*a(:,ww));
end
P_mvdr=abs(P_mvdr/max(abs(P_mvdr)));
figure
plot(w/(2*pi),10*log10(P_mvdr));
title('P_{MVDR}')