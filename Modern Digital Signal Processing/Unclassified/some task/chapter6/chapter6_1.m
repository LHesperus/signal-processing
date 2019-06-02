clc
clear all
close all

j=sqrt(-1);
%% gen signal 
f=[0.15 0.25 0.30]';
N=10000;                      %length of signal
SNR=[20 25 30]';
sigma_v=1;                    %noise power
v_n=sqrt(sigma/2)*randn(1,N)+j*sqrt(sigma/2)*randn(1,N);% complex gauss noise
a_k=sqrt(10.^(SNR/10)*sigma_v);%ampltitude of envelope
    
n=(0:N-1);
phi_k=2*pi*rand(1,3)';
s_k=a_k.*exp(j*2*pi*f*n+phi_k);


u_n=sum(s_k)+v_n;