%plot Bispectral or Bispectrum slice
%signal:row vector
%fs:sample rate
%mode :1--plot Bispectra,2--plot Bispectrum slice
%norm:1:normalization,
function [f,bispectra]=plotBispectra(signal,fs,mode,norm)
NFFT = 2^nextpow2(size(signal,2));
Y=fft(signal,NFFT)/size(signal,2);
f = fs/2*linspace(0,1,NFFT/2+1)  ;
%Y_1=2*abs(Y(1:NFFT/2+1));
Y_1=2*Y(1:NFFT/2+1);
Y_len_2=round((length(Y_1)-1)/2);
bis=zeros(Y_len_2,Y_len_2);
for ii=1:Y_len_2
    for jj=1:Y_len_2
        bis(ii,jj)=Y_1(ii)*Y_1(jj)*conj(Y_1(ii+jj));
    end
end
bis=abs(bis);
if mode==1
    bispectra=bis;
    [xx,yy]=meshgrid(f(1:size(bispectra,1)));
    if norm==1
        bispectra=bispectra/max(bispectra(:));
    end
   % surf(xx,yy,bispectra);
    contour(xx,yy,bispectra)
    xlabel('Hz');
elseif mode==2
    bispectra=diag(bis);
    if norm==1
        bispectra=bispectra/max(bispectra);
    end
    plot(f(1:size(bis,1)),bispectra);
     xlabel('Hz');
end
end

