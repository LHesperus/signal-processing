%%  generate modulated data
clc;clear all ; close all
% parameter
j=sqrt(-1);
fc=1e4;                                                 %carrier frequency
fs=1e5;                                                 %sample frequency
Rs=1e3;                                                 %symbol rate of digital signal
T=1/fs;                                                 %sample time
L=1000;                                                 %length of signal
t=(0:L-1)*T;                                            %time vector
ff=(-L/2:L/2-1)*(fs/L);                                 %freq vector
A=1;                                                    %%Ampltitude 
m_a=0.9;   
SNR=10;
f0=Rs;                                                  %baseband frequency
M=4;
m=8;
% signal
v=A*cos(2*pi*f0*t);  
[y,I_send,Q_send]=gen_AM(A,fc,fs,L,m_a,v);
%[y,I_send,Q_send]=gen_ASK2(A,fc,fs,Rs,L);
%[y,I_send,Q_send]=gen_DPSK2(A,fc,fs,Rs,L);
%[y,I_send,Q_send]=gen_MASK(A,fc,fs,Rs,L,M);
%[y,I_send,Q_send]=gen_MFSK(A,fc,fs,Rs,L,M); %% I Q 是 多维的
%[y,I_send,Q_send]=gen_PSK2(A,fc,fs,Rs,L);
%[y,I_send,Q_send]=gen_QPSK(A,fc,fs,Rs,L);
%[y,I_send,Q_send]=gen_FSK2(A,fc,fs,Rs,L) ;%% IQ多维
%[y,I_send,Q_send]=gen_FM(A,fc,fs,L);
%[y,s_complex,s,t,ff]=gen_OQPSK(A,fc,fs,Rs,L);I_send=real(s_complex);Q_send=imag(s_complex);
%[y,s_complex,s,t,ff]=gen_pi4DQPSK(A,fc,fs,Rs,L);I_send=real(s_complex);Q_send=imag(s_complex);
y=awgn(y,SNR,'measured');
%% NCO and LPF
fpass=fc;
f_order=4;
in=y;
a=1;b=1;
phase1=0;
phase2=0.0*pi;
f_offset=0.001*fc;
fc_DDC=fc+f_offset;
[I_rec,Q_rec]=DDC_filter(fs,fc_DDC,fpass,f_order,in,a,b,phase1,phase2);
IQ_send=I_send+Q_send*j;
IQ_rec=I_rec+Q_rec*j;
% plot IQ send and IQ receive
figure
subplot(2,2,1)
plot(t,I_send);title('I send')
subplot(2,2,2)
plot(t,Q_send);title('Q send')
subplot(2,2,3)
plot(t,I_rec);title('I receive')
subplot(2,2,4)
plot(t,Q_rec);title('Q receive')


% plot Spectrum
figure
IQ_SEND=abs(fftshift(fft(IQ_send)));
IQ_REC=abs(fftshift(fft(IQ_rec)));
subplot(2,2,1)
plot(ff,IQ_SEND);title('IQ SEND');
subplot(2,2,2)
plot(angle(IQ_send)./pi*180);title('phase')
subplot(2,2,3)
plot(ff,IQ_REC);title('IQ RECEIVE');
subplot(2,2,4)
plot(angle(IQ_rec)./pi*180);title('phase')
%% to 0 IF
%f_offset=ff(find(IQ_REC==max(IQ_REC)));
f_offset=f_offset_est(IQ_rec,fs,m)
%f_offset=-0.001*fc;
IQ_adjust=IQ_rec.*exp(-j*2*pi*f_offset*t);
figure
IQ_ADJUST=abs(fftshift(fft(IQ_adjust)));
f_adjust=ff(find(IQ_ADJUST==max(IQ_ADJUST)))
plot(ff,IQ_REC)
hold on
plot(ff,IQ_ADJUST)
legend('IQ_{REC}','IQ_{ADJUST}')
% plot i q adjust
I_adjust=real(IQ_adjust);
Q_adjust=imag(IQ_adjust);
figure
subplot(2,1,1)
plot(t,I_adjust);title('I_{adjust}');
subplot(2,1,2)
plot(t,Q_adjust);title('Q_{adjust}');
figure
subplot(2,1,1)
plot(ff,abs(IQ_adjust));title('abs(I_{adjust}+Q_{adjust}j)');
subplot(2,1,2)
plot(t,angle(IQ_adjust));title('phase');

%% map
figure 
subplot(3,1,1)
plot(IQ_send,'o');
subplot(3,1,2)
plot(IQ_rec,'o');
subplot(3,1,3)
plot(IQ_adjust,'o');

%% test
figure
S=abs(fftshift(fft(IQ_rec.^m)));
plot(ff,S)
Cf=C_f(IQ_send)
Cf=C_f(IQ_rec)
Cf=C_f(IQ_adjust)
modulation_recognize(IQ_send,Rs,fc,fs)

[b,a] = butter(15,0.3,'low');
figure
freqz(b,a)
I = filter(b,a,real(IQ_adjust));
Q = filter(b,a,imag(IQ_adjust));
IQ_adjust1=I+Q*j;
figure
subplot(2,1,1)
plot(t,real(IQ_adjust1));title('I_{adjust}');
subplot(2,1,2)
plot(t,imag(IQ_adjust1));title('Q_{adjust}');
figure
subplot(2,1,1)
plot(ff,abs(IQ_adjust1));title('abs(I_{adjust}+Q_{adjust}j)');
subplot(2,1,2)
plot(t,angle(IQ_adjust1));title('phase');
figure
plot(ff,abs(fftshift(fft(IQ_adjust1))));
figure
plot(IQ_adjust1,'o');