%非弱信号段零中心瞬时相位非线性的方差，page 261,(5-287)
%This code is unfinished, and more precise carrier frequency needs to be estimated later.
% a_t is threshold
function y=sigma_dp(a,a_t,fs,fc)
a_h=hilbert(a);
angle_a=angle(a_h);
%fc=carrier_estimate(a,fs);                              %Only when the carrier frequency 
                                                        %estimation is very accurate can 
                                                        %the following algorithm be implemented
%fc=1e4;
angle_a=unwrap(angle_a);
for i=1:length(angle_a)
  angle_a(i)=mod(angle_a(i)-2*pi*fc*i/fs,2*pi);          %(5-295)
end
angle_a=angle_a-mean(angle_a);

Ns=length(a);
amp_a=sqrt(real(a_h).*real(a_h)+imag(a_h).*imag(a_h));   %Envelope calculation from the Hilbert transform
m_a=mean(amp_a);
a_n=amp_a/m_a;
k=1;
for i=1:Ns
    if(a_n(i)>a_t)
        phi(k)=angle_a(i);
        k=k+1;
    end
end
if(k==1)                                                  % aviod a_t so large that phi without element
    phi=0;
end
sigma_ap=sqrt(mean(phi.*phi)-mean(phi)*mean(phi));
y=sigma_ap;
end