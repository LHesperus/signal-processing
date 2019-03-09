%plot Power Spectral
%signal:row vector
%fs:sample rate
function [f,power_spectrum]=plotPowerSpectrum(signal,fs)
NFFT = 2^nextpow2(size(signal,2));
Y=fft(signal,NFFT)/size(signal,2);
Y_shift=fftshift(Y);
f = fs/2*linspace(-1,1,NFFT)   ;
power_spectrum=2*abs(Y_shift).^2;
plot(f,power_spectrum);
xlabel('Hz');
end