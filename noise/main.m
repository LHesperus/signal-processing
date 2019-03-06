%%

f=1e2;                  %signal frequency
N=1000;
fs=1e4;                 %sampling frequency
Ts=1/fs;                
t=(0:N-1)*Ts;

s=20*sin(2*pi*f*t);          %signal
s=awgn(s,10,'measured');

figure
plot(t,s)

figure
plotSpectral2(s,fs)


