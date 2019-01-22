%carrier_estimate,page 267,(5-299),it only be used to estimate frequency of
%signal which has symmetry spectrum
%s:modulate signal
%y:carrier frequency
%fs:sample frequency
function y=carrier_estimate(s,fs)
S=fft(s)/length(s);
N_half=length(s)/2;
k=1:N_half;
y=fs/length(s)*sum(abs(S(1:N_half)).^2.*k)/sum(abs(S(1:N_half)).^2);
end