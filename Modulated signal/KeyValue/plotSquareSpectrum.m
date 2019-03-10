%plot Square Spectral
%signal:row vector
%fs:sample rate
function [f,square_spectrum]=plotSquareSpectrum(signal,fs)
NFFT = 2^nextpow2(size(signal,2));
Y=fft(signal.^2,NFFT)/size(signal,2);
Y_shift=fftshift(Y);
f = fs/2*linspace(-1,1,NFFT)   ;
square_spectrum=2*abs(Y_shift).^2;
plot(f,square_spectrum);
xlabel('Hz');
end