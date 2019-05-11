clc 
clear all
close all
%% parameter
fc=1e4;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
Rs=1e3;                                                 %symbol rate of digital signal
T=1/fs;                                                 %sample time
L=1000;                                                 %length of signal
t=(0:L-1)*T;                                            %time vector
A=1;                                                    %%Ampltitude 
m_a=0.3;   
SNR=20;
%% AM
v=A*cos(2*pi*1000*t);    
y_AM=gen_AM(A,fc,fs,L,m_a,v);
y_AM=awgn(y_AM,SNR,'measured');
figure
plot(y_AM)
title('AM')

%% ASK2
y_2ask=gen_ASK2(A,fc,fs,Rs,L);
y_2ask=awgn(y_2ask,SNR,'measured');
figure
plot(y_2ask)
title('2ask')

%% OQPSK
 [OQPSK_signal,s_complex,s]=gen_OQPSK(A,fc,fs,Rs,L);
 figure
 subplot(3,1,1)
 plot(OQPSK_signal);title('OQPSK');
 subplot(3,1,2);
 plot(s_complex,'o');
  subplot(3,1,3);
 plot(s,'o');
 
 %%