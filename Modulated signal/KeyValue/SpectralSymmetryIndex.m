%symmetrical characteristic of specturm ,page 261.
function y=SpectralSymmetryIndex(s,fs,fc)
Ns=length(s);
%fc=carrier_estimate(s,fs);                              %Only when the carrier frequency 
                                                        %estimation is very accurate can 
                                                        %the following algorithm be implemented
%fc=1e4;
f_cn=round(fc*Ns/fs-1);
S_abs=abs(fft(s))/Ns;
P_L=sum(S_abs(1:f_cn).^2);
P_U=sum(S_abs(1+f_cn+1:f_cn+f_cn+1).^2);
P=(P_L-P_U)/(P_L+P_U);
y=P;
end