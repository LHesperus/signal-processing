%plot Spectral
%signal:row vector
%fs:sample rate
function [f,Y1]=plotSpectral(signal,fs)
NFFT = 2^nextpow2(size(signal,2));
Y=fft(signal,NFFT)/size(signal,2);
f = fs/2*linspace(0,1,NFFT/2+1)   ;
Y1=2*abs(Y(1:NFFT/2+1));
plot(f,Y1);
xlabel('Hz');
end