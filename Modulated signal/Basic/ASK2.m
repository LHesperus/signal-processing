%Generating 2ASK signal
clc
clear all;
close all;
%use orthogonal modulation generate modulated siganl
%You can see the original signal v in the code.
fc=1e4;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
Rs=1e3;                                                 %symbol rate of digital signal
T=1/fs;                                                 %sample time
L=10000;                                                  %length of signal
t=(0:L-1)*T;                                            %time vector
A=1;                                                    %%Ampltitude
v=A*cos(2*pi*1000*t);                                   %modulation signal
xs=sin(2*pi*fc*t);
xc=cos(2*pi*fc*t);

%2ASK
%           _________          ______
%   signal |         |        |      |      
%----------|         |________|      |  so L/fs/T_ask is the length of a_n
%           <-T_ask->                       
%<-----------L points --------------->
T_ask=1/Rs;                                          
a_n=round(rand(1,round(L/(T_ask*fs))));
a_ask=repmat(a_n,T_ask*fs,1);
a_ask=a_ask(:)';
%stairs(a_ask)                                        %figure 2ask,unuse plot
I_ask=0;
Q_ask=a_ask;
y_2ask=I_ask.*xc+Q_ask.*xs;
figure(1)
plot(y_2ask);title('y_ask')
figure(2)
plotSpectral(y_2ask,fs)

y_2ask=awgn(y_2ask,10,'measured');

ff=(-L/2:L/2-1)*(fs/L);
f_offset=0.001*fc
[I,Q]=DDC_filter(fs,fc+f_offset,4000,15,y_2ask);
figure
subplot(2,1,1)
plot(I);title('DDC I')
subplot(2,1,2)
plot(Q);title('DDC Q')
IQ=I+Q*j;
figure
subplot(2,1,1)
plot(abs(IQ));title('abs(IQ)')
subplot(2,1,2)
plot(angle(IQ)./pi*180);title('angle DDC IQ')
figure
Y=abs(fftshift(fft(IQ)));
plot(ff,Y);title('spectrum of DDC IQ')

%%
% 
IQ_adjust=IQ.*exp(j*2*pi*f_offset*t);
hold on
Y_adjust=abs(fftshift(fft(IQ_adjust)));
plot(ff,Y_adjust);title('Y_adjust')
f_adjust=ff(find(Y_adjust==max(Y_adjust)))
legend('IQ','IQ_adjust')
figure
subplot(2,1,1)
plot(real(IQ_adjust));title('I Y_adjust')
subplot(2,1,2)
plot(imag(IQ_adjust));title('Q Y_adjust')

figure
subplot(2,1,1)
plot(abs(IQ_adjust));title('abs IQ adjust')
subplot(2,1,2)
plot(angle(IQ_adjust)./pi*180);title('ansgle IQ adjust')