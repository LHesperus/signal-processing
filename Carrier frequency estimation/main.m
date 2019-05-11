clc
clear all
close all
% parameter
j=sqrt(-1);
fc=1e4;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
Rs=1e3;                                                 %symbol rate of digital signal
T=1/fs;                                                 %sample time
L=10000;                                                 %length of signal
t=(0:L-1)*T;                                            %time vector
ff=(-L/2:L/2-1)*(fs/L);                                 %freq vector
A=1;                                                    %%Ampltitude 
m_a=0.9;   
SNR=10;
f0=Rs;                                                  %baseband frequency
v=A*cos(2*pi*f0*t);  

[y_AM,I_AM,Q_AM]=gen_AM(A,fc,fs,L,m_a,v);
f_est=carrier_estimate(v,fs)
f_est=carrier_estimate(y_AM,fs)