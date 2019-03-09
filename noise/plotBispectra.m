%plot Bispectral
%signal:row vector
%fs:sample rate
function [f,bispectra]=plotBispectra(signal,fs)
NFFT = 2^nextpow2(size(signal,2));
Y=fft(signal,NFFT)/size(signal,2);
f = fs/2*linspace(0,1,NFFT/2+1)  ;
Y_1=2*abs(Y(1:NFFT/2+1));
Y_len_2=round((length(Y_1)-1)/2);
bispectra=zeros(Y_len_2,Y_len_2);
size(Y_1)
for ii=1:Y_len_2
    for jj=1:Y_len_2
        bispectra(ii,jj)=Y_1(ii)*Y_1(jj)*conj(Y_1(ii+jj));
    end
end
[xx,yy]=meshgrid(f(1:size(bispectra,1)));
surf(xx,yy,bispectra);
xlabel('Hz');
end

