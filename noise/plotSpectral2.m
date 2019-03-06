%plot Spectral
%signal:row vector
%fs:sample rate
function plotSpectral2(signal,fs)
NFFT = 2^nextpow2(size(signal,2));
Y=fft(signal,NFFT)/size(signal,2);
Y_shift=fftshift(Y);
f = fs/2*linspace(-1,1,NFFT)   ;
plot(f,2*abs(Y_shift));
xlabel('Hz');
end